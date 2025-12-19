import express from "express";
import {
  createSubscription,
  getSubscriptions,
  getSubscriptionById,
  cancelSubscription,
  updateSubscription,
  renewSubscription
} from "../controller/subscriptionController.js";

const subscriptionRouter = express.Router();
subscriptionRouter.post("/", createSubscription);
subscriptionRouter.get("/", getSubscriptions);
subscriptionRouter.get("/:id", getSubscriptionById);
subscriptionRouter.put("/:id", updateSubscription);
subscriptionRouter.delete("/:id", cancelSubscription);
subscriptionRouter.post("/renew", renewSubscription);

export default subscriptionRouter;
