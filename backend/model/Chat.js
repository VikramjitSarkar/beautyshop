import mongoose from "mongoose";

const chatSchema = new mongoose.Schema(
  {
    user: { type: String, required: true }, // e.g., buyer
    other: { type: String, required: true }, // e.g., vendor
    lastMessage: {},
    myUnread: { type: Number, default: 0 },
    otherUnread: { type: Number, default: 0 },
    joinedUsers: [{ type: String }],
  },
  { timestamps: true }
);

export const Chat = mongoose.model("Chat", chatSchema);
