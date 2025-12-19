import express from "express";
import { Notification } from "../model/Notification.js";
import { User }         from "../model/User.js";
import { Vendor }       from "../model/Vendor.js";
const notifyRouter = express.Router();

// For Users
notifyRouter.get("/forUser/:userId", async (req, res) => {
  const user = req.params?.userId;

  const notifications = await Notification.find({ receiver: user })
    .sort({ updatedAt: -1 })
    .populate({ path: "sender", select: "shopName shopBanner userName profileImage" });

  const enriched = notifications.map(n => ({
    ...n.toObject(),
    shopName: n.sender?.shopName || n.sender?.userName || "",
    shopBanner: n.sender?.shopBanner || n.sender?.profileImage || ""
  }));

  res.status(200).json({ status: "success", data: enriched });
});

// For Vendors
notifyRouter.get("/forVendor/:vendorId", async (req, res) => {
  const vendor = req.params?.vendorId;

  const notifications = await Notification.find({ receiver: vendor })
    .sort({ updatedAt: -1 })
    .populate({ path: "sender", select: "shopName shopBanner userName profileImage" });

  const enriched = notifications.map(n => ({
    ...n.toObject(),
    shopName: n.sender?.shopName || n.sender?.userName || "",
    shopBanner: n.sender?.shopBanner || n.sender?.profileImage || ""
  }));

  res.status(200).json({ status: "success", data: enriched });
});
notifyRouter.post("/send", async (req, res, next) => {
  try {
    const { broadcast, receiver, title, body, type, reference } = req.body;
    let targets = [];

    if (broadcast === "all") {
      // everyone
      const users   = await User.find().select("_id");
      const vendors = await Vendor.find().select("_id");
      targets = [
        ...users.map(u => u._id.toString()),
        ...vendors.map(v => v._id.toString())
      ];
    } else if (broadcast === "user") {
      // all users
      const users = await User.find().select("_id");
      targets = users.map(u => u._id.toString());
    } else if (broadcast === "vendor") {
      // all vendors
      const vendors = await Vendor.find().select("_id");
      targets = vendors.map(v => v._id.toString());
    } else if (receiver) {
      // single user *or* single vendor
      targets = [receiver];
    } else {
      return res.status(400).json({ error: "No target specified" });
    }

    const docs = targets.map(r => ({
      receiver:  r,
      sender:    null,
      title,
      body,
      type,
      reference
    }));
    const created = await Notification.insertMany(docs);
    res.status(201).json({ success: true, count: created.length });
  } catch (err) {
    next(err);
  }
});

export default notifyRouter;
