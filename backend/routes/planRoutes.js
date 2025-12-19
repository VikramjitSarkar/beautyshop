import express from "express";
import {
  createPlan,
  getPlans,
  getPlanById,
  updatePlan,
  deletePlan,
} from "../controller/planController.js";

const planRouter = express.Router();

planRouter.route("/create").post(createPlan);
planRouter.route("/getAll").get(getPlans);
planRouter.route("/get/:id").get(getPlanById);
planRouter.route("/update/:id").put(updatePlan);
planRouter.route("/delete/:id").delete(deletePlan);

export default planRouter;
