import { Chat } from "../model/Chat.js";
import { Message } from "../model/Message.js";
import { Booking } from "../model/booking.js";
import { User } from "../model/User.js";
import { Vendor } from "../model/Vendor.js";
import { Notification } from "../model/Notification.js";  
import notify from "../utils/notification.js";

export const handleSocketConnections = (io) => {
  const users = {};

  io.on("connection", (socket) => {
    socket.on("register", ({ id, type }) => {
      users[socket.id] = { id, type };
    });
    
    socket.on("scanQrCode", async ({ qrCode }, cb) => {
      try {
        if (!qrCode) return cb?.({ status: "error", message: "QR code is required" });

        const booking = await Booking.findOne({ qrId: qrCode }).populate("user").populate("vendor");
        if (!booking) return cb?.({ status: "error", message: "Invalid or expired QR code" });

        const status = booking.status?.trim().toLowerCase();
        if (!["active", "past", "cancelled"].includes(status)) {
          booking.status = "active";
          await booking.save();
        }

        const payload = {
          status: "success",
          message: "Booking activated!",
          data: {
            _id: booking._id,
            status: booking.status,
            user: booking.user?._id,
            vendor: booking.vendor?._id,
          },
        };

        if (booking.vendor?.fcmToken) {
          await notify(
            booking.vendor.fcmToken,
            "Booking Activated",
            `${booking._id}`
          );
        }
  console.log(`✅ Notification sent: Booking Activated to Vendor (${booking.vendor._id})`);

        Object.entries(users).forEach(([socketId, info]) => {
          if (info.id === booking.vendor?._id.toString()) {
            io.to(socketId).emit("bookingActivated", payload);
          }
        });

        cb?.(payload);
      } catch {
        cb?.({ status: "error", message: "Scan failed" });
      }
    });

socket.on("complete-booking", async ({ bookingId }, cb) => {
  try {

    const updated = await Booking.findByIdAndUpdate(
      bookingId,
      { status: "past" },
      { new: true }
    ).populate("vendor");

    if (!updated) {
      return cb?.({ status: "fail", message: "Booking not found" });
    }


    

    // Notify user
    const user = await User.findById(updated.user);
    if (user?.fcmToken) {
      try {
        await notify(
          user.fcmToken,
          "Booking Completed",
          `${updated._id}`
        );
            console.log(`✅ Notification sent: Booking Completed to User (${user._id})`);

      } catch (err) {
      }
    } else {
    }

    const payload = {
      status: "success",
      message: "Booking completed",
      data: updated,
    };

    let sent = false;
    Object.entries(users).forEach(([socketId, info]) => {
      if (
        info.id === updated.user?.toString() ||
        info.id === updated.vendor?._id.toString()
      ) {
        io.to(socketId).emit("booking-completed", payload);
        sent = true;
      }
    });

    if (!sent) {
    }

    cb?.(payload);
  } catch (err) {
    cb?.({ status: "fail", message: "Error completing booking" });
  }
});



    socket.on("join-chat", async ({ senderId, chatId }, cb) => {
  users[socket.id] = { id: senderId };
  const chat = await Chat.findById(chatId);
  if (chat && !chat.joinedUsers.includes(senderId)) {
    chat.joinedUsers.push(senderId);
    await chat.save();
  }
  cb?.({ status: "success", message: "Joined chat" });
});

socket.on("send_message", async (data, cb) => {
  try {
    const { content, senderId, receiverId, chatId, type } = data;

    const message = await Message.create({
      content,
      senderId,
      receiverId,
      chatId,
      type: type || "text",
    });

    const chat = await Chat.findById(chatId);
    if (!chat) return cb?.({ status: "error", message: "Chat not found" });

    // Update last message and unread count
    chat.lastMessage = {
      content,
      senderId,
      type: type || "text",
      createdAt: new Date(),
    };

    if (chat.user.toString() === senderId.toString()) {
      chat.otherUnread = (chat.otherUnread || 0) + 1; // going to vendor
    } else {
      chat.myUnread = (chat.myUnread || 0) + 1; // going to user
    }

    await chat.save();

    // 🔔 Send notification here
    const receiverUser = await User.findById(receiverId);
    const receiverVendor = await Vendor.findById(receiverId);
    const fcmToken = receiverUser?.fcmToken || receiverVendor?.fcmToken;

    if (fcmToken) {
      const title = "New Message";
      const body = content;

      await notify(fcmToken, title, body);
      await Notification.create({
        receiver: receiverId,
        sender: senderId,
        title,
        body,
        type: "message",
        reference: chatId,
      });
    }

    // Emit to receiver if online
    Object.entries(users).forEach(([socketId, info]) => {
      if (info.id === receiverId) {
        io.to(socketId).emit("new_message", {
          status: "success",
          data: message,
        });
      }
    });

    cb?.({ status: "success", data: message });
  } catch (err) {
    console.error("Socket send_message error:", err);
    cb?.({ status: "error", message: "Message send failed" });
  }
});


socket.on("leave-chat", async ({ senderId, chatId }, cb) => {
  try {
    const chat = await Chat.findById(chatId);
    if (chat) {
      chat.joinedUsers = chat.joinedUsers.filter(
        (id) => id.toString() !== senderId.toString()
      );
      await chat.save();
    }
    cb?.({ status: "success", message: "Left chat" });
  } catch (err) {
    cb?.({ status: "error", message: "Failed to leave chat" });
  }
});


    socket.on("disconnect", () => {
      delete users[socket.id];
    });
  });
};
