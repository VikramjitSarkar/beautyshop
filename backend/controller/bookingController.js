import { Booking } from "../model/booking.js";
import QRCode from "qrcode";
import { Notification } from "../model/Notification.js";
import { User } from "../model/User.js";
import { Vendor } from "../model/Vendor.js";
import notify from "../utils/notification.js";
import { Review } from "../model/Review.js";

export const createBooking = async (req, res, next) => {
  try {
    const { vendor, services, userName, userLocation } = req.body;
    const user = req.user.userId;
    if (services?.length === 0) {
      return res.status(400).json({
        status: "fail",
        message: "Please provide services",
      });
    }
    // Convert services IDs to strings
    const serviceIds = services.map((id) => id.toString());
    // console.log("serivice ids ===", serviceIds);
    const booking = await Booking.create({
      user,
      vendor: vendor.toString(),
      services: serviceIds, // use converted strings here
      status: "pending",
      userName: userName || "",
      userLocation: userLocation || {},
    });

    const qrData = booking._id.toString();
    // const qrData = booking._id.toString();
    const qrCode = await QRCode.toDataURL(qrData);
    booking.qrId = qrData;
    // Save to booking
    booking.qrCode = qrCode;
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
    const booking = await Booking.findByIdAndUpdate(
      req.params.bookingId,
      { status: "reject" },
      { new: true }
    );

    if (!booking) return res.status(404).json({ message: "Booking not found" });
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
      const reviews = await Review.find({ vendor: vendorId });
      if (reviews.length > 0) {
        avgRating =
          reviews.reduce((sum, r) => sum + r.rating, 0) / reviews.length;
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
      vendorLocationAddress: booking.vendor?.locationAddres || "",
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

