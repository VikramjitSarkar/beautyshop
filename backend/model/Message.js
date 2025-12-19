import mongoose from "mongoose";

const msgSchema = new mongoose.Schema(
  {
    content: { type: String },
    senderId: { type: String, required: true },
    receiverId: { type: String, required: true },
    chatId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Chat",
      required: true,
    },
    type: { type: String, default: "text" }, // text, image, etc.
    groupId: { type: mongoose.Schema.Types.ObjectId, ref: "Group" }, // optional
  },
  { timestamps: true }
);

export const Message = mongoose.model("Message", msgSchema);
