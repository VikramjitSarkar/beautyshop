import mongoose from "mongoose";

const reportSchema = new mongoose.Schema({
  type: { type: String, enum: ['user', 'vendor'], required: true },
  reportedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  reportedUser: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  reportedVendor: { type: mongoose.Schema.Types.ObjectId, ref: 'Vendor' },
  reason: String,
  createdAt: { type: Date, default: Date.now }
});

export const Report = mongoose.model("Report", reportSchema);
