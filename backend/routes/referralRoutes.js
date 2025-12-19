import express from "express";
import {
  createReferralCodes,
  getAllReferralCodes,
  redeemReferralCode,
} from "../controller/referralController.js";

const referralRouter = express.Router();
referralRouter.route("/generate").post(createReferralCodes);
referralRouter.route("/redeem").post(redeemReferralCode);
referralRouter.route("/all").get(getAllReferralCodes);

export default referralRouter;
