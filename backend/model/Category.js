import mongoose from "mongoose";
const Schema = mongoose.Schema;

const categorySchema = new Schema({
  image: {
    type: String,
    require: true,
  },
  name: {
    type: String,
    require: true,
  },

  createdAt: {
    type: Date,
    default: Date.now,
  },
  status: {
    type: String,
    enum: ["pending", "approved", "blocked"],
    default: "pending",
  },
});

export const Category = mongoose.model("Category", categorySchema);
