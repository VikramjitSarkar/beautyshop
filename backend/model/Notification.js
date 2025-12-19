import mongoose from "mongoose";

const notificationSchema = new mongoose.Schema({
  receiver: {
    type: String,
  },
  sender: {
  type: mongoose.Schema.Types.ObjectId,
  ref: "Vendor",
  },
  title: {
    type: String,
    default: "",
  },
  body: {
    type: String,
    default: "",
  },
  type: {
    type: String,
    enum: ["message", "booking", "other"],
    default: "other",
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  reference: {
    type: String,
  },
});

export const Notification = mongoose.model("Notification", notificationSchema);
