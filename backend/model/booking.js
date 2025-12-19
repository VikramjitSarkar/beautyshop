import mongoose from "mongoose";

const bookingSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },
  vendor: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Vendor",
    required: true,
  },
  services: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Service",
    },
  ],
  qrId: {
    type: String,
  },
  status: {
    type: String,
    enum: ["pending", "past", "active", "reschedule", "accept", "reject"],
    default: "pending",
  },
  bookingDate: {
    type: Date,
    default: Date.now,
  },
  qrCode: { type: String },
});

export const Booking = mongoose.model("Booking", bookingSchema);
