// controllers/referral.controller.js
import { ReferralCode } from "../model/ReferralCode.js";
import { generateReferralCodes } from "../utils/generateCodes.js";
import { Subscription } from "../model/Subscription.js";
import mongoose from "mongoose";
import notify from "../utils/notification.js";

export const createReferralCodes = async (req, res, next) => {
  try {
    const codes = generateReferralCodes(1000); // Generates 1k unique codes
    const data = codes.map(code => ({
      code,
      isUsed: false,
      usedBy: null,
      createdAt: new Date()
    }));

    await ReferralCode.insertMany(data);

    res.status(201).json({
      status: "success",
      message: "1000 referral codes created and saved to DB",
      sample: data.slice(0, 5) // Show first 5 as a preview
    });
  } catch (err) {
    next(err);
  }
};

// 300 unused codes
export const getAllReferralCodes = async (req, res, next) => {
  try {
    const codes = await ReferralCode.find({ isUsed: false })
      .select("code createdAt")
      .sort({ createdAt: 1 }) // oldest first
      .limit(300);            // cap at 300 only

    res.status(200).json({
      status: "success",
      count: codes.length,
      data: codes,
    });
  } catch (err) {
    next(err);
  }
};


export const redeemReferralCode = async (req, res, next) => {
  try {
    const { vendorId, referralCode } = req.body;
    const vendorObjectId = mongoose.Types.ObjectId.isValid(vendorId)
      ? new mongoose.Types.ObjectId(vendorId)
      : vendorId;

    const vendorAlreadyUsed = await ReferralCode.findOne({ usedBy: vendorObjectId });
    if (vendorAlreadyUsed) {
      await notify({
        userId: vendorObjectId,
        type: "referral_failed",
        title: "Referral Redemption Failed",
        body: "You have already redeemed a referral code.",
      });
      return res.status(400).json({
        status: "error",
        message: "Vendor has already redeemed a referral code",
      });
    }

    const referral = await ReferralCode.findOne({ code: referralCode, isUsed: false });
    if (!referral) {
      await notify({
        userId: vendorObjectId,
        type: "referral_failed",
        title: "Referral Redemption Failed",
        body: "The referral code is either invalid or already used.",
      });
      return res.status(400).json({
        status: "error",
        message: "Referral code is invalid or already used",
      });
    }

    // Hardcoded 3-month planId
    const planId = "68266d846c717a3a35bb317c";

    const startDate = new Date();
    const endDate = new Date(startDate.getTime() + 90 * 24 * 60 * 60 * 1000);

    const subscription = await Subscription.create({
      vendorId: vendorObjectId,
      planId,
      price: 0,
      stripePaymentId: null,
      status: "active",
      startDate,
      endDate,
    });

    referral.isUsed = true;
    referral.usedBy = vendorObjectId;
    referral.redeemedAt = new Date();
    await referral.save();

    await Vendor.findByIdAndUpdate(vendorObjectId, { listingPlan: "paid" });

    await notify({
      userId: vendorObjectId,
      type: "referral_redeemed",
      title: "Referral Redeemed",
      body: "You have successfully redeemed a referral code. You’ve got a 3-month free subscription!",
    });

    res.status(201).json({
      status: "success",
      message: "Referral redeemed successfully",
      data: subscription,
    });
  } catch (err) {
    next(err);
  }
};
