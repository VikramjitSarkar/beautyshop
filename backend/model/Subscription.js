import mongoose from "mongoose";

const subscriptionSchema = new mongoose.Schema({
  vendorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Vendor",
    required: true,
  },
  planId: { type: mongoose.Schema.Types.ObjectId, ref: "Plan", required: true },
  stripePaymentId: { type: String }, // store Stripe charge/payment intent ID
  price: { type: Number, required: true },
  status: { type: String, enum: ["active", "expired", "canceled"], default: "active" },
  startDate: { type: Date, required: true },
  endDate: { type: Date, required: true },
});

export const Subscription = mongoose.model("Subscription", subscriptionSchema);
