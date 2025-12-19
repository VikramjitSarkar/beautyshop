// User.js
import mongoose from "mongoose";
const Schema = mongoose.Schema;

const userSchema = new Schema({
  profileImage: { type: String },
  userName: { type: String },

  isPhoneVerified: { type: Boolean, default: false },

  email: { type: String, required: true, index: true, unique: true },

  // Prefer storing dates as String "yyyy-MM-dd" or real Date.
  // If you want a real Date: { type: Date }
  dateOfBirth: { type: String, default: "" },        // NEW

  gender: { type: String, enum: ["male","female","other",""], default: "" }, // NEW

  password: { type: String, required: true },        // keep only ONE password

  locationAdress: { type: String },                  // keep spelling or fix across project
  userLat: { type: String },
  userLong: { type: String },

  phone: { type: String, default: "" },

  fcmToken: { type: String },

  favoriteVendors: [{ type: mongoose.Schema.Types.ObjectId, ref: "Vendor" }],

  status: { type: String, enum: ["pending", "approved", "blocked"], default: "pending" },
  role: { type: String, enum: ["user","admin"], default: "user" },

  socialId: { type: String, unique: true, index: true },

  createdAt: { type: Date, default: Date.now },
}, { timestamps: true });

export const User = mongoose.model("User", userSchema);
