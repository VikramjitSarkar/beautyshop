import { Review } from "../model/Review.js";
import { Vendor } from "../model/Vendor.js";

export const createReview = async (req, res, next) => {
  try {
    const { vendor, rating, comment } = req.body;
    const user = req.user.userId;

    const numericRating = Number(rating);
    if (isNaN(numericRating) || numericRating < 1 || numericRating > 5) {
      return res.status(400).json({
        message: "Rating must be a number between 1 and 5",
      });
    }

    // If you want to allow multiple reviews, comment this block
    // const existingReview = await Review.findOne({ user, vendor });
    // if (existingReview) {
    //   return res
    //     .status(400)
    //     .json({ message: "You already reviewed this vendor" });
    // }

    let review = await Review.create({ user, vendor, rating: numericRating, comment });
    review = await review.populate("user", "userName profileImage");

    // Update vendor's average rating
    const allReviews = await Review.find({ vendor });
    const avgRating = allReviews.reduce((sum, r) => sum + r.rating, 0) / allReviews.length;
    await Vendor.findByIdAndUpdate(vendor, { shopRating: avgRating });

    res.status(201).json({ status: "success", data: review });
  } catch (error) {
    next(error);
  }
};


export const updateReview = async (req, res, next) => {
  try {
    const reviewId = req.params.id;
    const user = req.user.userId;

    let review = await Review.findOneAndUpdate(
      { _id: reviewId, user },
      req.body,
      { new: true }
    ).populate("user", "userName profileImage");

    if (!review) {
      return res
        .status(404)
        .json({ message: "Review not found or not authorized" });
    }

    // Update vendor's average rating
    const allReviews = await Review.find({ vendor: review.vendor });
    const avgRating = allReviews.reduce((sum, r) => sum + r.rating, 0) / allReviews.length;
    await Vendor.findByIdAndUpdate(review.vendor, { shopRating: avgRating });

    res.json({ status: "success", data: review });
  } catch (error) {
    next(error);
  }
};

export const deleteReview = async (req, res, next) => {
  try {
    const reviewId = req.params.reviewId;

    const review = await Review.findOneAndDelete({ _id: reviewId }).populate("user", "userName profileImage");

    if (!review) {
      return res.status(404).json({ message: "Review not found" });
    }

    // Update vendor's average rating after deletion
    const allReviews = await Review.find({ vendor: review.vendor });
    const avgRating = allReviews.length > 0 
      ? allReviews.reduce((sum, r) => sum + r.rating, 0) / allReviews.length 
      : 0;
    await Vendor.findByIdAndUpdate(review.vendor, { shopRating: avgRating });

    res.json({ status: "success", message: "Review deleted", data: review });
  } catch (error) {
    next(error);
  }
};

export const getReviewsByUser = async (req, res, next) => {
  try {
    const userId = req.user.userId;

    const reviews = await Review.find({ user: userId })
      .populate("user", "userName profileImage");

    res.status(200).json({ status: "success", data: reviews });
  } catch (error) {
    next(error);
  }
};

export const getUserReview = async (req, res, next) => {
  try {
    const user = req.user.userId;

    const review = await Review.find({ user }).populate("user", "userName profileImage");

    res.json({ status: "success", data: review });
  } catch (error) {
    next(error);
  }
};

export const getReviewsByVendor = async (req, res, next) => {
  try {
    const vendorId = req.params.vendorId;

const reviews = await Review.find({ vendor: vendorId }).populate("user", "userName profileImage");

    res.json({ status: "success", data: reviews });
  } catch (error) {
    next(error);
  }
};