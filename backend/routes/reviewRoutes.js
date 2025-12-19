import express from "express";
import {
  createReview,
  getReviewsByVendor,
  getUserReview,
  deleteReview,
  updateReview,
} from "../controller/reviewController.js";
import jwt from "jsonwebtoken";
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];
  if (token == null) return res.sendStatus(401);

  jwt.verify(token, "somesecretsecret", (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
};

const reviewRoute = express.Router();

reviewRoute.route("/create").post(authenticateToken, createReview);
reviewRoute.route("/update/:reviewId").put(updateReview);
reviewRoute.route("/delete/:reviewId").delete(deleteReview);
reviewRoute.route("/vendor/:vendorId").get(getReviewsByVendor);
reviewRoute.route("/user").get(authenticateToken, getUserReview);

export default reviewRoute;
