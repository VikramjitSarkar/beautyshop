import mongoose from "mongoose";
const Schema = mongoose.Schema;

const subcategorySchema = new Schema({
  image: {
    type: String,
    require: true,
  },
  categoryId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Category",
    required: true,
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

export const SubCategory = mongoose.model("SubCategory", subcategorySchema);
