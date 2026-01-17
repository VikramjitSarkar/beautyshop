import express from "express";
import { Vendor } from "../model/Vendor.js";

import {
  registerVendor,
  loginVendor,
  getAllVendor,
  getVendorById,
  deleteVendorById,
  UpdateProfile,
  UpdateStatus,
  ProfileSetup,
  getVendorById2,
  getNearbyVendors,
} from "../controller/vendorController.js";

import jwt from "jsonwebtoken";
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];
  if (token == null) return res.sendStatus(401);

  jwt.verify(token, "somesecretsecret", (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
};
const vendorRoute = express.Router();

vendorRoute.route("/register").post(registerVendor);
vendorRoute.route("/login").post(loginVendor);
vendorRoute.route("/getAll").get(getAllVendor);
vendorRoute.route("/get").get(authenticateToken, getVendorById);
vendorRoute.route("/update").put(authenticateToken, UpdateProfile);
vendorRoute.route("/updateStatus/:id").put(UpdateStatus);
vendorRoute.route("/byVendorId/:vendorId").get(getVendorById2);
vendorRoute.route("/profileSetup").put(authenticateToken, ProfileSetup);
vendorRoute.route("/delete").delete(authenticateToken, deleteVendorById);
vendorRoute.route("/nearBy").post(getNearbyVendors);
vendorRoute.route("/verifyID/:vendorId").put(async (req, res) => {
  await Vendor.findByIdAndUpdate(req.params.vendorId, { isIDVerified: true });
  res.json({ success: true });
});

vendorRoute.route("/verifyCertificate/:vendorId").put(async (req, res) => {
  await Vendor.findByIdAndUpdate(req.params.vendorId, { isCertificateVerified: true });
  res.json({ success: true });
});

vendorRoute.route("/updateLocation/:vendorId").put(async (req, res) => {
  const { vendorLat, vendorLong, locationAddress } = req.body;
  await Vendor.findByIdAndUpdate(req.params.vendorId, { vendorLat, vendorLong, locationAddress });
  res.json({ success: true });
});

export default vendorRoute;
// 91867769407
