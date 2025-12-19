// models/Plan.js
import mongoose from "mongoose";

const planSchema = new mongoose.Schema({
  price: { type: Number, required: true }, // used to charge manually
  durationInDays: { type: Number, required: true },
});

export const Plan = mongoose.model("Plan", planSchema);
