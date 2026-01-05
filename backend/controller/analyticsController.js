import { Booking } from "../model/Booking.js";
import { Payment } from "../model/Payment.js";

// Helper function to get date range based on period
const getDateRange = (period) => {
  const now = new Date();
  let startDate;

  switch (period) {
    case 'today':
      startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      break;
    case 'week':
      const weekStart = new Date(now);
      weekStart.setDate(now.getDate() - now.getDay()); // Start of week (Sunday)
      weekStart.setHours(0, 0, 0, 0);
      startDate = weekStart;
      break;
    case 'month':
      startDate = new Date(now.getFullYear(), now.getMonth(), 1);
      break;
    case 'year':
      startDate = new Date(now.getFullYear(), 0, 1);
      break;
    default:
      startDate = new Date(0); // All time
  }

  return { startDate, endDate: now };
};

// Calculate total amount from services
const calculateTotalAmount = (services) => {
  if (!services || !Array.isArray(services)) return 0;
  return services.reduce((total, service) => {
    const charge = parseFloat(service.charges) || 0;
    return total + charge;
  }, 0);
};

// GET /booking/user-spending/:userId
export const getUserSpending = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const { period } = req.query; // today, week, month, year

    const { startDate, endDate } = getDateRange(period);

    // Find completed bookings for user in date range
    const bookings = await Booking.find({
      user: userId,
      status: { $in: ['completed', 'accept'] },
      createdAt: { $gte: startDate, $lte: endDate }
    })
      .populate('vendor', 'shopName locationAddres')
      .populate('services.serviceId', 'serviceName')
      .sort({ createdAt: -1 });

    // Calculate total spending
    let totalAmount = 0;
    const breakdown = bookings.map(booking => {
      const amount = calculateTotalAmount(booking.services);
      totalAmount += amount;

      return {
        bookingId: booking._id,
        vendorName: booking.vendor?.shopName || 'Unknown',
        vendorAddress: booking.vendor?.locationAddres || 'Unknown',
        services: booking.services.map(s => ({
          name: s.serviceId?.serviceName || s.serviceName || 'Unknown',
          charge: parseFloat(s.charges) || 0
        })),
        totalAmount: amount,
        bookingDate: booking.bookingDate,
        status: booking.status,
        createdAt: booking.createdAt
      };
    });

    res.json({
      status: 'success',
      data: {
        period: period || 'all',
        totalAmount: parseFloat(totalAmount.toFixed(2)),
        totalBookings: bookings.length,
        breakdown
      }
    });
  } catch (error) {
    next(error);
  }
};

// GET /booking/vendor-earnings/:vendorId
export const getVendorEarnings = async (req, res, next) => {
  try {
    const { vendorId } = req.params;
    const { period } = req.query; // today, week, month, year

    const { startDate, endDate } = getDateRange(period);

    // Find completed bookings for vendor in date range
    const bookings = await Booking.find({
      vendor: vendorId,
      status: { $in: ['completed', 'accept'] },
      createdAt: { $gte: startDate, $lte: endDate }
    })
      .populate('user', 'userName location profileImage')
      .populate('services.serviceId', 'serviceName')
      .sort({ createdAt: -1 });

    // Calculate total earnings
    let totalEarnings = 0;
    const breakdown = bookings.map(booking => {
      const amount = calculateTotalAmount(booking.services);
      totalEarnings += amount;

      return {
        bookingId: booking._id,
        userName: booking.user?.userName || 'Unknown',
        userLocation: booking.user?.location || 'Unknown',
        userImage: booking.user?.profileImage || '',
        services: booking.services.map(s => ({
          name: s.serviceId?.serviceName || s.serviceName || 'Unknown',
          charge: parseFloat(s.charges) || 0
        })),
        totalAmount: amount,
        bookingDate: booking.bookingDate,
        status: booking.status,
        serviceLocationType: booking.serviceLocationType,
        createdAt: booking.createdAt
      };
    });

    // Calculate average per booking
    const averagePerBooking = bookings.length > 0 
      ? parseFloat((totalEarnings / bookings.length).toFixed(2))
      : 0;

    // Get payment records if available
    const payments = await Payment.find({
      vendor: vendorId,
      status: 'completed',
      createdAt: { $gte: startDate, $lte: endDate }
    }).sort({ createdAt: -1 });

    const paymentTotal = payments.reduce((sum, p) => sum + (p.amount || 0), 0);

    res.json({
      status: 'success',
      data: {
        period: period || 'all',
        totalEarnings: parseFloat(totalEarnings.toFixed(2)),
        totalBookings: bookings.length,
        averagePerBooking,
        paymentRecords: parseFloat(paymentTotal.toFixed(2)),
        breakdown
      }
    });
  } catch (error) {
    next(error);
  }
};
