// models/ReferralCode.js
import mongoose from "mongoose";

const referralCodeSchema = new mongoose.Schema({
  code: { type: String, required: true, unique: true },
  isUsed: { type: Boolean, default: false },
  usedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Vendor",
    default: null,
  },
  createdAt: { type: Date, default: Date.now },
});

export const ReferralCode = mongoose.model("ReferralCode", referralCodeSchema);
