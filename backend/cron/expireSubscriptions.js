import cron from "node-cron";
import { Subscription } from "../model/Subscription.js";
import { Vendor } from "../model/Vendor.js";
import { Notification } from "../model/Notification.js";
import notify from "../utils/notification.js";
import { User } from "../model/User.js";
import { Booking } from "../model/booking.js";
import mongoose from "mongoose";

// Runs every day at 12:00 AM
cron.schedule("0 0 * * *", async () => {
  console.log("⏰ Running subscription expiry check...");

  const now = new Date();

  try {
    const expiredSubs = await Subscription.find({
      endDate: { $lt: now },
      status: { $ne: "expired" },
    });

    for (const sub of expiredSubs) {
      await Subscription.updateOne(
        { _id: sub._id },
        { $set: { status: "expired" } }
      );

      const vendor = await Vendor.findById(sub.vendorId);

      if (vendor?.fcmToken) {
        const title = "Subscription Expired";
        const body = "Your subscription has expired. Please renew it.";

        // 1. Send push notification
        await notify(vendor.fcmToken, title, body);

        // 2. Save to Notification collection
        await Notification.create({
          receiver: vendor._id.toString(),
          sender: "system", // or your admin ID if needed
          title,
          body,
          type: "other",
          reference: sub._id.toString(),
        });
      }
    }

    console.log(
      `✅ ${expiredSubs.length} subscriptions expired and notifications sent`
    );
  } catch (err) {
    console.error(
      "❌ Failed to expire subscriptions or send notifications:",
      err
    );
  }
});

/* new cron for notifying bookings */
// Runs every minute
cron.schedule("* * * * *", async () => {
  console.log("⏰ Running booking reminder check...");

  const now = new Date();
  const oneHourLater = new Date(now.getTime() + 60 * 60 * 1000);
  const oneHourLaterEnd = new Date(oneHourLater.getTime() + 60 * 1000); // 1 min window

  try {
    const upcomingBookings = await Booking.find({
      bookingDate: { $gte: oneHourLater, $lte: oneHourLaterEnd },
      status: "accept"
    }).populate("user vendor");

    for (const booking of upcomingBookings) {
      const vendor = booking.vendor;
      const user = booking.user;

      const title = "Booking Reminder";
      const body = "Your booking is scheduled in 1 hour.";

      // Notify vendor
      if (vendor?.fcmToken) {
        await notify(vendor.fcmToken, title, body);
        await Notification.create({
          receiver: vendor._id.toString(),
          sender: "system",
          title,
          body,
          type: "booking",
          reference: booking._id.toString(),
        });
      }

      // Notify user
      if (user?.fcmToken) {
        await notify(user.fcmToken, title, body);
        await Notification.create({
          receiver: user._id.toString(),
          sender: "system",
          title,
          body,
          type: "booking",
          reference: booking._id.toString(),
        });
      }
    }

    console.log(`✅ ${upcomingBookings.length} booking reminders sent`);
  } catch (err) {
    console.error("❌ Failed to send booking reminders:", err);
  }
});