import express from "express";
import { sendOTP, checkOTP } from "../controller/verify.controller.js";

const router = express.Router();
router.post("/send-otp", sendOTP);
router.post("/check-otp", checkOTP);

export default router;
