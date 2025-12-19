import express from "express";
import { Chat } from "../model/Chat.js";
import { Message } from "../model/Message.js";
import { User } from "../model/User.js";
import { Vendor } from "../model/Vendor.js";
import notify from "../utils/notification.js";
const chatRouter = express.Router();

chatRouter.post("/create", async (req, res) => {
  const { userId, vendorId } = req.body;

  try {
    const user = await User.findById(userId);
    const vendor = await Vendor.findById(vendorId);

    if (!user || !vendor) {
      return res.status(400).json({ message: "Invalid user or vendor ID" });
    }

    let chat = await Chat.findOne({
      $or: [
        { user: user._id, other: vendor._id },
        { user: vendor._id, other: user._id },
      ],
    });

    if (!chat) {
      chat = await Chat.create({
        user: user._id,    // always user
        other: vendor._id, // always vendor
      });
    }

    res.status(200).json({ data: chat });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Failed to create or find chat" });
  }
});

chatRouter.get("/allChats/:userId", async (req, res) => {
  const { userId } = req.params;

  try {
    const chats = await Chat.find({
      $or: [{ user: userId }, { other: userId }],
    }).sort({ updatedAt: -1 });

    const chatsWithData = await Promise.all(
      chats.map(async (data) => {
        if (data.user == userId) {
          const findPerson1 =
            (await User.findById(data.other)) ||
            (await Vendor.findById(data.other));

          const chatWithPersonData = {
            chatId: data._id,
            senderId: data.user,
            receiverId: data.other,
            other: findPerson1,
            lastMessage: data.lastMessage,
            unread: data.myUnread, // send actual unread first
          };

          if (data.myUnread !== 0) {
            data.myUnread = 0;
            await data.save();
          }

          return chatWithPersonData;
        } else {
          const findPerson1 =
            (await User.findById(data.user)) ||
            (await Vendor.findById(data.user));

          const chatWithPersonData = {
            chatId: data._id,
            senderId: data.other,
            receiverId: data.user,
            other: findPerson1,
            lastMessage: data.lastMessage,
            unread: data.otherUnread, // send actual unread first
          };

          if (data.otherUnread !== 0) {
            data.otherUnread = 0;
            await data.save();
          }

          return chatWithPersonData;
        }
      })
    );

    console.log("response from chats data ===", chatsWithData);
    res.json({
      status: "success1",
      data: chatsWithData,
    });
  } catch (err) {
    console.log(err);
    res.status(400).json({
      status: "error",
      message: "invalid parameters",
    });
  }
});


chatRouter.post("/message", async (req, res) => {
  const { content, senderId, receiverId, chatId, type } = req.body;

  try {
    const message = await Message.create({
      content,
      senderId,
      receiverId,
      chatId,
      type,
    });

    const chat = await Chat.findById(chatId);
    if (!chat) return res.status(404).json({ error: "Chat not found" });

    chat.lastMessage = message._id;

    if (chat.user.toString() === senderId.toString()) {
      chat.otherUnread = (chat.otherUnread || 0) + 1;
    } else {
      chat.myUnread = (chat.myUnread || 0) + 1;
    }

    await chat.save();

    const receiverUser = await User.findById(receiverId);
    const receiverVendor = await Vendor.findById(receiverId);
    const fcmToken = receiverUser?.fcmToken || receiverVendor?.fcmToken;

    console.log("Receiver found: ", receiverUser ? "User" : receiverVendor ? "Vendor" : "None");
    console.log("Receiver FCM Token: ", fcmToken);

    if (fcmToken) {
      const title = "New Message";
      const body = content;

      await notify(fcmToken, title, body);
      console.log("Notification sent successfully");

      await Notification.create({
        receiver: receiverId,
        sender: senderId,
        title,
        body,
        type: "message",
        reference: chatId,
      });
    } else {
      console.log("No FCM Token found. Notification skipped.");
    }

    res.status(200).json({ status: "success", data: message });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Failed to send message" });
  }
});



chatRouter.get("/allMessages/:chatId", async (req, res) => {
  const { chatId } = req.params;

  const messages = await Message.find({ chatId }).sort({ createdAt: 1 });

  res.status(200).json({ status: "success", data: messages });
});
chatRouter.get("/vendorChats/:vendorId", async (req, res) => {
  const { vendorId } = req.params;

  try {
    const chats = await Chat.find({
      $or: [{ user: vendorId }, { other: vendorId }],
    }).sort({ updatedAt: -1 });

    const chatsWithData = await Promise.all(
      chats.map(async (data) => {
        if (data.user == vendorId) {
          const findPerson1 =
            (await User.findById(data.other)) ||
            (await Vendor.findById(data.other));

          const chatWithPersonData = {
            chatId: data._id,
            senderId: data.user,
            receiverId: data.other,
            other: findPerson1,
            lastMessage: data.lastMessage,
            unread: data.myUnread,  // send unread first
          };

          // reset after sending actual unread value
          if (data.myUnread !== 0) {
            data.myUnread = 0;
            await data.save();
          }

          return chatWithPersonData;
        } else {
          const findPerson1 =
            (await User.findById(data.user)) ||
            (await Vendor.findById(data.user));

          const chatWithPersonData = {
            chatId: data._id,
            senderId: data.other,
            receiverId: data.user,
            other: findPerson1,
            lastMessage: data.lastMessage,
            unread: data.otherUnread,  // send unread first
          };

          if (data.otherUnread !== 0) {
            data.otherUnread = 0;
            await data.save();
          }

          return chatWithPersonData;
        }
      })
    );

    res.json({
      status: "success",
      data: chatsWithData,
    });
  } catch (err) {
    console.log(err);
    res.status(400).json({
      status: "error",
      message: "invalid parameters",
    });
  }
});



export default chatRouter;
