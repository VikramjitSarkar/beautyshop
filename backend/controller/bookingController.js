import { Booking } from "../model/booking.js";
import QRCode from "qrcode";
import { Notification } from "../model/Notification.js";
import { User } from "../model/User.js";
import { Vendor } from "../model/Vendor.js";
import notify from "../utils/notification.js";
import { Review } from "../model/Review.js";

// Helper function to calculate distance between two coordinates (Haversine formula)
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Earth's radius in km
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLon/2) * Math.sin(dLon/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  return R * c;
}

export const createBooking = async (req, res, next) => {
  try {
    const { vendor, services, userName, userLocation, specialRequests, serviceLocationType, bookingDate } = req.body;
    const user = req.user.userId;
    
    // Debug: Log incoming request data
    console.log('🔵 BOOKING REQUEST RECEIVED:', {
      specialRequests,
      serviceLocationType,
      userName,
      hasUserLocation: !!userLocation
    });
    
    if (services?.length === 0) {
      return res.status(400).json({
        status: "fail",
        message: "Please provide services",
      });
    }

    // Validate booking date is not in the past
    const requestedDate = new Date(bookingDate);
    const now = new Date();
    if (requestedDate < now) {
      return res.status(400).json({
        status: "fail",
        message: "Cannot book appointments in the past",
      });
    }

    // Convert services IDs to strings
    const serviceIds = services.map((id) => id.toString());
    
    // Fetch vendor details
    const vendorData = await Vendor.findById(vendor);
    if (!vendorData) {
      return res.status(404).json({
        status: "fail",
        message: "Vendor not found",
      });
    }

    // Check if vendor accepts the requested service location type
    if (serviceLocationType === "home") {
      if (!vendorData.homeServiceAvailable) {
        return res.status(400).json({
          status: "fail",
          message: "Vendor does not offer home services",
        });
      }
      
      // Validate distance for home service
      if (userLocation?.latitude && userLocation?.longitude && 
          vendorData.vendorLat && vendorData.vendorLong) {
        const distance = calculateDistance(
          parseFloat(vendorData.vendorLat),
          parseFloat(vendorData.vendorLong),
          userLocation.latitude,
          userLocation.longitude
        );
        
        const maxServiceRadius = 50; // Maximum 50km service radius
        
        if (distance > maxServiceRadius) {
          return res.status(400).json({
            status: "fail",
            message: `Location is ${distance.toFixed(1)}km away. Vendor only serves within ${maxServiceRadius}km radius.`,
            distance: distance.toFixed(1)
          });
        }
      }
    }
    if (serviceLocationType === "salon" && !vendorData.hasPhysicalShop) {
      return res.status(400).json({
        status: "fail",
        message: "Vendor does not have a physical shop",
      });
    }

    // Validate working hours
    if (vendorData.openingTime) {
      const bookingDay = requestedDate.getDay(); // 0=Sunday, 6=Saturday
      const isWeekend = bookingDay === 0 || bookingDay === 6;
      const hours = isWeekend ? vendorData.openingTime.weekends : vendorData.openingTime.weekdays;
      
      if (hours && hours.from && hours.to) {
        const [openHour, openMin] = hours.from.split(':').map(Number);
        const [closeHour, closeMin] = hours.to.split(':').map(Number);
        const bookingHour = requestedDate.getHours();
        const bookingMin = requestedDate.getMinutes();
        
        const bookingMinutes = bookingHour * 60 + bookingMin;
        const openMinutes = openHour * 60 + openMin;
        const closeMinutes = closeHour * 60 + closeMin;
        
        if (bookingMinutes < openMinutes || bookingMinutes >= closeMinutes) {
          return res.status(400).json({
            status: "fail",
            message: `Vendor is closed at this time. Working hours: ${hours.from} - ${hours.to}`,
          });
        }
      }
    }

    // Check vendor online status - ONLY for immediate bookings (within 2 hours)
    // For scheduled/future bookings, allow booking even if vendor is currently offline
    const TWO_HOURS_MS = 2 * 60 * 60 * 1000;
    const isImmediateBooking = (requestedDate.getTime() - now.getTime()) < TWO_HOURS_MS;
    
    if (isImmediateBooking && vendorData.status === "offline") {
      return res.status(400).json({
        status: "fail",
        message: "Vendor is currently offline and not accepting immediate bookings. Try scheduling for a later time.",
      });
    }

    // Fetch services to get total duration for overlap check
    const serviceDetails = await Promise.all(
      serviceIds.map(id => import('../model/Service.js').then(m => m.Service.findById(id)))
    );
    const estimatedDuration = serviceDetails.reduce((sum, s) => sum + (Number(s?.duration) || 30), 0);
    
    // Add 1 hour buffer time for mobile services (vendor can be late, service can run over)
    const BUFFER_TIME_MINUTES = 60;
    const totalTimeNeeded = estimatedDuration + BUFFER_TIME_MINUTES;
    const estimatedEndTime = new Date(requestedDate.getTime() + totalTimeNeeded * 60000);

    // Check for overlapping bookings with buffer time (1-hour gap between bookings)
    const bufferStart = new Date(requestedDate.getTime() - BUFFER_TIME_MINUTES * 60000);
    const bufferEnd = new Date(estimatedEndTime.getTime());
    
    const overlappingBookings = await Booking.find({
      vendor: vendor,
      status: { $in: ['pending', 'accept', 'active'] },
      $or: [
        {
          // Existing booking overlaps with new booking window (including buffer)
          bookingDate: { $lte: bufferEnd },
          estimatedEndTime: { $gt: bufferStart }
        }
      ]
    });

    if (overlappingBookings.length > 0) {
      const existingTime = new Date(overlappingBookings[0].bookingDate).toLocaleTimeString('en-US', { 
        hour: '2-digit', 
        minute: '2-digit' 
      });
      return res.status(400).json({
        status: "fail",
        message: `This time slot conflicts with another booking at ${existingTime}. Please allow at least 1 hour gap between appointments.`,
      });
    }

    const booking = await Booking.create({
      user,
      vendor: vendor.toString(),
      services: serviceIds,
      status: "pending",
      userName: userName || "",
      userLocation: userLocation || {},
      specialRequests: specialRequests || "",
      serviceLocationType: serviceLocationType || "salon",
      bookingDate: requestedDate,
    });
    
    // Debug: Log what was saved to database
    console.log('🟢 BOOKING CREATED:', {
      specialRequests: booking.specialRequests,
      serviceLocationType: booking.serviceLocationType,
      bookingDate: booking.bookingDate
    });

    const qrData = booking._id.toString();
    // const qrData = booking._id.toString();
    const qrCode = await QRCode.toDataURL(qrData);
    booking.qrId = qrData;
    // Save to booking
    booking.qrCode = qrCode;
    
    // Populate services to calculate duration
    await booking.populate('services');
    
    // Calculate total duration and estimated end time
    const totalDuration = booking.services.reduce((sum, s) => sum + (Number(s.duration) || 30), 0);
    booking.totalDuration = totalDuration;
    booking.estimatedEndTime = new Date(requestedDate.getTime() + totalDuration * 60000);
    
    await booking.save();
    const userData = await Vendor.findById(vendor);
    const title = "New Booking";
    const body = "You have a new booking";
    if (userData?.fcmToken) {
      await notify(userData.fcmToken, title, body);
    }
    await Notification.create({
      receiver: vendor,
      sender: user,
      reference: booking?._id,
      type: "booking",
      title,
      body,
    });
    const populatedBooking = await Booking.findById(booking._id).populate("services");

   const totalCharges = populatedBooking.services.reduce((sum, s) => sum + Number(s.charges || 0), 0);

  res.status(201).json({
  status: "success",
  message: "Booking created successfully",
  data: {
    ...populatedBooking.toObject(),
    totalServices: serviceIds.length,
    totalCharges,
    totalDuration: populatedBooking.totalDuration,
    estimatedEndTime: populatedBooking.estimatedEndTime,
  },
});
  } catch (error) {
    next(error);
  }
};

export const scanQrAndConfirmBooking = async (req, res, next) => {
  try {
    const { qrCode } = req.body;
    if (!qrCode) {
      return res.status(400).json({ status: "error", message: "QR code is required" });
    }

    const booking = await Booking.findOne({ qrId: qrCode })
      .populate("user")
      .populate("vendor")
      .populate("services"); // ✅ Needed to calculate charges

    if (!booking) {
      return res.status(404).json({ status: "error", message: "Invalid or expired QR code" });
    }

    if (booking.status !== "pending") {
      return res.status(400).json({ status: "error", message: "Booking is already activated or completed" });
    }

    booking.status = "active";
    await booking.save();

    const totalCharges = booking.services.reduce((sum, s) => sum + Number(s.charges || 0), 0); // ✅ Correct placement

    // 🔔 Notify
    const title = "Booking Activated";
    const body = "Your booking has been activated successfully";

    if (booking.user?.fcmToken) {
      await notify(booking.user.fcmToken, title, body);
    }
    if (booking.vendor?.fcmToken) {
      await notify(booking.vendor.fcmToken, title, body);
    }

    await Notification.create([
      {
        receiver: booking.user._id,
        sender: booking.vendor._id,
        reference: booking._id,
        type: "booking",
        title,
        body,
      },
      {
        receiver: booking.vendor._id,
        sender: booking.user._id,
        reference: booking._id,
        type: "booking",
        title,
        body,
      },
    ]);

    io.emit("bookingActivated", {
      status: "success",
      message: body,
      data: booking,
    });

    res.status(200).json({
      status: "success",
      message: body,
      data: {
        ...booking.toObject(),
        totalServices: booking.services.length,
        totalCharges
      }
    });
  } catch (error) {
    console.error("QR Scan Error:", error);
    res.status(500).json({
      status: "error",
      message: "Failed to scan QR code",
    });
  }
};


export const updateBooking = async (req, res, next) => {
  try {
    const bookingId = req.params.bookingId;
    const updated = await Booking.findByIdAndUpdate(bookingId, req.body, {
      new: true,
    });

    if (!updated) return res.status(404).json({ message: "Booking not found" });

    res.json({
      status: "success",
      data: updated,
      message: "Booking updated successfully",
    });
  } catch (error) {
    next(error);
  }
};

export const deleteBooking = async (req, res, next) => {
  try {
    const deleted = await Booking.findByIdAndDelete(req?.params?.bookingId);

    if (!deleted) return res.status(404).json({ message: "Booking not found" });

    res.json({
      status: "success",
      message: "Booking deleted successfully",
    });
  } catch (error) {
    next(error);
  }
};

export const getAllBookings = async (req, res, next) => {
  try {
    const bookings = await Booking.find()
      .populate("user")
      .populate("vendor")
      .populate({
        path: "services",
        populate: { path: "subcategoryId", select: "name" }
      });

    const enriched = bookings.map((booking) => {
      const enrichedServices = booking.services.map((s) => ({
        ...s.toObject(),
        serviceName: s.subcategoryId?.name || "",
      }));

      const totalCharges = enrichedServices.reduce((sum, s) => sum + Number(s.charges || 0), 0);

      return {
        ...booking.toObject(),
        services: enrichedServices,
        totalServices: enrichedServices.length,
        totalCharges
      };
    });

    res.json({ status: "success", data: enriched });
  } catch (error) {
    next(error);
  }
};


export const acceptBooking = async (req, res, next) => {
  try {
    const booking = await Booking.findByIdAndUpdate(
      req.params.bookingId,
      { status: "accept" },
      { new: true }
    );

    if (!booking) return res.status(404).json({ message: "Booking not found" });
    if (booking) {
      const userData = await User.findById(booking.user);
      const title = "Booking Accepted";
      const body = "Your booking has been accepted";
      if (userData?.fcmToken) {
        await notify(userData.fcmToken, title, body);
      }
      await Notification.create({
        receiver: booking.user,
        sender: booking.vendor,
        type: "booking",
        title,
        body,
      });
    }
    res.json({
      status: "success",
      data: booking,
      message: "Booking accepted successfully",
    });
  } catch (error) {
    next(error);
  }
};

export const rejectBooking = async (req, res, next) => {
  try {
    const booking = await Booking.findById(req.params.bookingId);
    
    if (!booking) return res.status(404).json({ message: "Booking not found" });
    
    // Cancellation policy: Cannot cancel within 24 hours for accepted bookings
    if (booking.status === 'accept') {
      const hoursUntilBooking = (new Date(booking.bookingDate) - Date.now()) / (1000 * 60 * 60);
      
      if (hoursUntilBooking < 24) {
        return res.status(400).json({
          status: "fail",
          message: "Cannot cancel within 24 hours of appointment. Please contact vendor directly."
        });
      }
    }
    
    // Update booking status and record cancellation
    booking.status = "reject";
    booking.cancelledAt = new Date();
    booking.cancellationReason = req.body.reason || "";
    await booking.save();
    if (booking) {
      const userData = await User.findById(booking.user);
      const title = "Booking Rejected";
      const body = "Your booking has been rejected";
      if (userData?.fcmToken) {
        await notify(userData.fcmToken, title, body);
      }
      await Notification.create({
        receiver: booking.user,
        sender: booking.vendor,
        type: "booking",
        title,
        body,
      });
    }
      const vendor = await Vendor.findById(booking.vendor);
      if (vendor?.fcmToken) {
        await notify(
          vendor.fcmToken,
          "Booking Cancelled",
          "A booking has been cancelled by the user."
        );
      }

    res.json({
      status: "success",
      data: booking,
      message: "Booking rejected successfully",
    });
  } catch (error) {
    next(error);
  }
};

export const rescheduleBooking = async (req, res, next) => {
  try {
    const bookingId = req.params.bookingId;
    const { newDate } = req.body;
    const parsedDate = new Date(newDate);

    if (isNaN(parsedDate)) {
      return res.status(400).json({ message: "Invalid date format" });
    }
    const booking = await Booking.findByIdAndUpdate(
      bookingId,
      {
        status: "reschedule",
        bookingDate: parsedDate, // rescheduling date
      },
      { new: true }
    );

    if (!booking) return res.status(404).json({ message: "Booking not found" });
    if (booking) {
      const userData = await User.findById(booking.user);
      const title = "Booking Rescheduled";
      const body = "Your booking has been rescheduled";
      if (userData?.fcmToken) {
        await notify(userData.fcmToken, title, body);
      }
      await Notification.create({
        receiver: booking.user,
        sender: booking.vendor,
        type: "booking",
        title,
        body,
        reference: booking?._id,
      });
    }

    res.json({
      status: "success",
      data: booking,
      message: "Booking rescheduled successfully",
    });
  } catch (error) {
    next(error);
  }
};

export const getBookingsByUser = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const { status } = req.query;

    const filter = { user: userId };
    if (status) filter.status = status;

    const bookings = await Booking.find(filter)
      .populate("vendor")
      .populate("user")
      .populate({
        path: "services",
        populate: { path: "subcategoryId", select: "name" },
      });

    const enrichedBookings = await Promise.all(
  bookings.map(async (booking) => {
    const enrichedServices = booking.services.map((s) => ({
      ...s.toObject(),
      serviceName: s.subcategoryId?.name || "",
    }));

    const totalCharges = enrichedServices.reduce(
      (sum, s) => sum + Number(s.charges || 0),
      0
    );

    // Get vendor rating
    let avgRating = 0;
    const vendorId = booking.vendor?._id;
    if (vendorId) {
      const vendor = await Vendor.findById(vendorId);
      if (vendor) {
        avgRating = vendor.shopRating || 0;
      }
    }

    return {
      ...booking.toObject(),
      services: enrichedServices,
      totalServices: enrichedServices.length,
      totalCharges,
      vendorRating: parseFloat(avgRating.toFixed(1)),
      vendorProfileImage: booking.vendor?.profileImage || "",
      vendorShopName: booking.vendor?.shopName || "",
      vendorLocationAddress: booking.vendor?.locationAddress || "",
      vendorLat: booking.vendor?.vendorLat || 0,
      vendorLong: booking.vendor?.vendorLong || 0,
    };
  })
);

    res.json({ status: "success", data: enrichedBookings });
  } catch (error) {
    next(error);
  }
};


export const getBookingsByVendor = async (req, res, next) => {
  try {
    const vendorId = req.params.vendorId;
    const { status } = req.query;

    const filter = { vendor: vendorId };
    if (status) filter.status = status;

    const bookings = await Booking.find(filter)
      .populate("user")
      .populate({
        path: "services",
        populate: { path: "subcategoryId", select: "name" },
      });

    const enrichedBookings = bookings.map((booking) => {
  const enrichedServices = booking.services.map((s) => ({
    ...s.toObject(),
    serviceName: s.subcategoryId?.name || "",
  }));

  const totalCharges = enrichedServices.reduce(
    (sum, s) => sum + Number(s.charges || 0),
    0
  );

  return {
    ...booking.toObject(),
    services: enrichedServices,
    totalServices: enrichedServices.length,
    totalCharges,
    userName: booking.userName || booking.user?.username || "",
    userProfilePic: booking.user?.profile_picture || "",
    userLocation: booking.userLocation || {},
    bookingDate: booking.bookingDate,
    serviceLocationType: booking.serviceLocationType || "salon",
    specialRequests: booking.specialRequests || "",
  };
});

    res.json({ status: "success", data: enrichedBookings });
  } catch (error) {
    next(error);
  }
};


export const bookingById = async (req, res, next) => {
  const bookingId = req.params.bookingId;
  try {
    const booking = await Booking.findById(bookingId)
      .populate("user")
      .populate("vendor")
      .populate({
        path: "services",
        populate: { path: "subcategoryId", select: "name" },
      });

    if (!booking) {
      return res.json({ status: "success", message: "Booking not found" });
    }

    const enrichedServices = booking.services.map((s) => ({
      ...s.toObject(),
      serviceName: s.subcategoryId?.name || "",
    }));
const totalCharges = enrichedServices.reduce((sum, s) => sum + Number(s.charges || 0), 0);

    res.json({
      status: "success",
      data: {
        ...booking.toObject(),
        services: enrichedServices,
        totalCharges
      },
    });
  } catch (error) {
    next(error);
  }
};

