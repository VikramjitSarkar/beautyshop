import mongoose from "mongoose";
const { Schema } = mongoose;

const vendorSchema = new Schema({
  name: { type: String },
  gallery: { type: [String], default: [] },
  video: { type: String },
  surname: { type: String },
  gender: { type: String, enum: ["male", "female", "other"], default: "male" },
  age: { type: String },
  
  cnic: { type: String },
  cnicImage: { type: String },

  certificateImage: { type: String },

  profileImage: { type: String },
  title: { type: String },
  shopName: { type: String },
  description: { type: String },

  userName: { type: String, required: true },
  email:    { type: String, required: true, unique: true },

  password:            { type: String, required: true },
  resetPasswordToken:  { type: String },
  resetPasswordExpires:{ type: Date   },

  locationAddress:     { type: String },
  vendorLat:           { type: String },
  vendorLong:          { type: String },
  phone:               { type: String },
  whatsapp:            { type: String },

  hasPhysicalShop:     { type: Boolean, default: false },
  location:            { type: String, enum: ["on", "off"], default: "off" },
  listingPlan:         { type: String, enum: ["free", "paid"], default: "free" },
  status:              { type: String, enum: ["offline","online"], default: "offline" },
  accountStatus:       { type: String, enum: ["pending","approved","blocked"], default: "pending" },

  shopBanner:          { type: String },
  homeServiceAvailable:{ type: Boolean, default: false },
  isProfileComplete:   { type: Boolean, default: false },
  isIDVerified:      { type: Boolean, default: false },
  isCertificateVerified:   { type: Boolean, default: false },
  socialId: { type: String, unique: true, index: true },



  fcmToken:            { type: String },
  openingTime: {
    weekdays: {
      from: { type: String },
      to:   { type: String }
    },
    weekends: {
      from: { type: String },
      to:   { type: String }
    }
  },
  blockedDates: [{
    date: { type: Date },
    reason: { type: String }
  }],
  maxServiceRadius: {
    type: Number,
    default: 50,
    comment: "Maximum service radius in km for home services"
  },

  favoriteCount: {
    type: Number,
    default: 0,
    comment: "Number of times this vendor has been added to favorites"
  },

  shopRating: {
    type: Number,
    default: 0,
    min: 0,
    max: 5,
    comment: "Average rating based on customer reviews"
  },

  paymentMethods: {
    type: [String],
    default: [],
    comment: "Accepted payment methods: paypal, stripe, razorpay, cash, card, bank_transfer"
  },

  createdAt:           { type: Date, default: Date.now }
});

export const Vendor = mongoose.model("Vendor", vendorSchema);
