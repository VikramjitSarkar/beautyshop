import express from "express";
import { Booking }      from "../model/booking.js";
import {
  createBooking,
  updateBooking,
  deleteBooking,
  getAllBookings,
  getBookingsByUser,
  getBookingsByVendor,
  acceptBooking,
  rejectBooking,
  rescheduleBooking,
  scanQrAndConfirmBooking,
  bookingById,
} from "../controller/bookingController.js";
import { getUserSpending, getVendorEarnings } from "../controller/analyticsController.js";
import jwt from "jsonwebtoken";
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];
  if (token == null) return res.sendStatus(401);

  jwt.verify(token, "somesecretsecret", (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
};

const bookingRoute = express.Router();

bookingRoute.route("/create").post(authenticateToken, createBooking);
bookingRoute.route("/update/:bookingId").put(updateBooking);
bookingRoute.route("/delete/:bookingId").delete(deleteBooking);
bookingRoute.route("/getAll").get(getAllBookings);
bookingRoute.route("/vendor/:vendorId").get(getBookingsByVendor);
bookingRoute.route("/user").get(authenticateToken, getBookingsByUser);
bookingRoute.route("/accept/:bookingId").put(acceptBooking);
bookingRoute.route("/reject/:bookingId").put(rejectBooking);
bookingRoute.route("/reschedule/:bookingId").put(rescheduleBooking);
bookingRoute.route("/scanQrCode").put(scanQrAndConfirmBooking);
bookingRoute.route("/get/:bookingId").get(bookingById);

// Analytics routes
bookingRoute.get("/user-spending/:userId", getUserSpending);
bookingRoute.get("/vendor-earnings/:vendorId", getVendorEarnings);

bookingRoute.get("/user/:userId/bookings", async (req, res) => {
  const { userId } = req.params;
  try {
    const bookings = await Booking.find({ user: userId })
      .populate("vendor", "shopName")
      .populate("services", "name price")
      .sort({ bookingDate: -1 });
    return res.status(200).json(bookings);
  } catch (err) {
    console.error("Fetch bookings error:", err);
    return res.status(500).json({ message: "Failed to fetch bookings" });
  }
});
export default bookingRoute;
