import express from "express";
import jwt from "jsonwebtoken";
import AuthMiddleware from "../middleware/isAuth.js";
import transporter from "../utils/mailer.js";
import Imap from "imap";
import { simpleParser } from "mailparser";
import { User }         from "../model/User.js";
import { Vendor }       from "../model/Vendor.js";
import { Booking }      from "../model/booking.js";
import { Subscription } from "../model/Subscription.js";
import { Report }       from "../model/reports.js";
import { Notification } from "../model/Notification.js";
import { Service } from '../model/Service.js';
import { Review } from '../model/Review.js';
import { Payment } from '../model/Payment.js';
import dotenv from "dotenv";
import { deleteVendorById } from '../controller/vendorController.js';

dotenv.config();

const adminRoute = express.Router();

// ─── PUBLIC: LOGIN ─────────────────────────────────────────────────────────────
adminRoute.post("/login", async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ message: "Email and password required" });
  }

  // find admin user
  const user = await User.findOne({ email, role: "admin" });
  if (!user || user.password !== password) {
    return res.status(401).json({ message: "Invalid credentials" });
  }

  // sign token with userId + role
  const token = jwt.sign(
    { userId: user._id.toString(), role: user.role },
    process.env.JWT_SECRET || "somesecretsecret",
    { expiresIn: "2h" }
  );

  res.json({ token });
});

// ─── PROTECTED: ALL ADMIN ROUTES ────────────────────────────────────────────────


// Dashboard stats
adminRoute.get("/dashboardStats", async (req, res) => {
  const totalUsers = await User.countDocuments();
  const totalVendors = await Vendor.countDocuments();
  const totalBookings = await Booking.countDocuments();
  const totalSubscriptions = await Subscription.countDocuments();
  res.json({ totalUsers, totalVendors, totalBookings, totalSubscriptions });
});

adminRoute.get("/support/all", (req, res) => {
  const { IMAP_HOST, IMAP_USER, IMAP_PASS } = process.env;
  const imap = new Imap({ user: IMAP_USER, password: IMAP_PASS, host: IMAP_HOST, port: 993, tls: true });

  imap.once("ready", () => {
    imap.openBox("INBOX", true, (err, box) => {
      if (err) return res.status(500).json({ error: "OpenBox failed", details: err.message });
      imap.search(["UNSEEN"], (err, results) => {
        console.log("IMAP search results:", results);
        if (err) return res.status(500).json({ error: "Search failed", details: err.message });
        if (!results.length) {
          imap.end();
          return res.json([]); 
        }

        const emails = [];
        const f = imap.fetch(results, { bodies: "" });
        f.on("message", msg =>
          msg.on("body", stream =>
            simpleParser(stream, (err, parsed) => {
              if (!err) emails.push({
                from: parsed.from.text,
                subject: parsed.subject,
                date: parsed.date,
                text: parsed.text
              });
            })
          )
        );
        f.once("end", () => {
          imap.end();
          res.json(emails);
        });
      });
    });
  });

  imap.once("error", err => {
    console.error("IMAP error:", err);
    res.status(500).json({ error: "IMAP connection error", details: err.message });
  });

  imap.connect();
});


adminRoute.post("/support/reply", async (req, res) => {
  const { to, subject, reply } = req.body;
  await transporter.sendMail({
    from: "support@beautician.com",
    to,
    subject: `Reply: ${subject}`,
    text: reply
  });
  res.json({ success: true });
});

adminRoute.get("/reports/all", async (req, res) => {
  const reports = await Report.find()
    .populate("reportedBy", "email")
    .populate("reportedUser", "email")
    .populate("reportedVendor", "email");
  res.json(reports);
});

adminRoute.post("/notifications/send", async (req, res) => {
  const { receiver, title, body, type, reference } = req.body;
  const notification = await Notification.create({
    receiver,
    sender: null,
    title,
    body,
    type,
    reference
  });
  res.json({ success: true, notification });
});
adminRoute.get("/notifications/all", async (req, res) => {
  const notifications = await Notification.find().sort({ createdAt: -1 });
  res.json(notifications);
});
adminRoute.get("/user/:id/bookings", async (req, res) => {
  try {
    const userId = req.params.id;
    const bookings = await Booking.find({ user: userId })
      .populate("vendor", "shopName")       // show vendor name
      .populate("service", "name price")    // if you have service refs
      .sort({ createdAt: -1 });
    res.json(bookings);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch bookings" });
  }
});

adminRoute.get('/vendor/:vendorId/details', async (req, res) => {
  try {
    const { vendorId } = req.params;

    const vendor = await Vendor.findById(vendorId).lean();
    if (!vendor) {
      return res.status(404).json({ message: 'Vendor not found' });
    }

   const services = await Service.find({ createdBy: vendorId }).lean();

    const reviews = await Review.find({ vendor: vendorId })
      .populate({ path: 'user', select: 'userName profileImage' })
      .lean();

    return res.json({
      status: 'success',
      data: { vendor, services, reviews }
    });
  } catch (err) {
    console.error('Fetch vendor details error:', err);
    return res.status(500).json({ message: 'Server error' });
  }
});
adminRoute.delete('/vendor/:id', deleteVendorById);

// GET /admin/payments
adminRoute.get('/payments', async (req, res) => {
  const logs = await Payment.find()
    .populate('vendor','shopName')
    .populate('user','userName')
    .sort('-createdAt');
  res.json({ status:'success', data: logs });
});

// Quick fix endpoint for vendor flags (temporary debug endpoint)
adminRoute.post('/quickFixVendor', async (req, res) => {
  try {
    const { vendorId, hasPhysicalShop, homeServiceAvailable } = req.body;
    
    if (!vendorId) {
      return res.status(400).json({ message: 'vendorId is required' });
    }
    
    const updateData = {};
    if (hasPhysicalShop !== undefined) updateData.hasPhysicalShop = hasPhysicalShop;
    if (homeServiceAvailable !== undefined) updateData.homeServiceAvailable = homeServiceAvailable;
    
    const vendor = await Vendor.findByIdAndUpdate(
      vendorId,
      { $set: updateData },
      { new: true }
    );
    
    if (!vendor) {
      return res.status(404).json({ message: 'Vendor not found' });
    }
    
    res.json({ 
      status: 'success', 
      message: 'Vendor updated',
      data: {
        vendorId: vendor._id,
        shopName: vendor.shopName,
        hasPhysicalShop: vendor.hasPhysicalShop,
        homeServiceAvailable: vendor.homeServiceAvailable
      }
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

export default adminRoute;
