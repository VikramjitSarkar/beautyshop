import { User } from "../model/User.js";
import twilio from "twilio";

const client = twilio(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN
);

// Send OTP
export const sendOTP = async (req, res) => {
  try {
    const { phone } = req.body;
    await client.verify.v2.services(process.env.TWILIO_SERVICE_SID)
      .verifications.create({ to: `+${phone}`, channel: "sms" });

    res.json({ status: "success", message: "OTP sent" });
  } catch (err) {
    res.status(400).json({ status: "error", message: err.message });
  }
};

// Verify OTP
export const checkOTP = async (req, res) => {
  try {
    const { phone, code } = req.body;

    const verificationCheck = await client.verify.v2
      .services(process.env.TWILIO_SERVICE_SID)
      .verificationChecks.create({ to: `+${phone}`, code });

    if (verificationCheck.status === "approved") {
      await User.findOneAndUpdate({ phone }, { isPhoneVerified: true });
      return res.json({ status: "success", message: "Phone verified" });
    }

    res.status(400).json({ status: "error", message: "Invalid OTP" });
  } catch (err) {
    res.status(400).json({ status: "error", message: err.message });
  }
};
