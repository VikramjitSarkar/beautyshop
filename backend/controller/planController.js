import { Plan } from "../model/Plan.js";

// Create Plan
export const createPlan = async (req, res, next) => {
  try {
    const plan = await Plan.create(req.body);
    res.status(201).json({ status: "success", data: plan });
  } catch (error) {
    next(error);
  }
};

// Get All Plans
export const getPlans = async (req, res, next) => {
  try {
    const plans = await Plan.find();
    res.json({ status: "success", data: plans });
  } catch (error) {
    next(error);
  }
};

// Get Single Plan
export const getPlanById = async (req, res, next) => {
  try {
    const plan = await Plan.findById(req.params.id);
    if (!plan) {
      return res
        .status(404)
        .json({ status: "error", message: "Plan not found" });
    }
    res.json({ status: "success", data: plan });
  } catch (error) {
    next(error);
  }
};

// Update Plan
export const updatePlan = async (req, res, next) => {
  try {
    const plan = await Plan.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
    });
    if (!plan) {
      return res
        .status(404)
        .json({ status: "error", message: "Plan not found" });
    }
    res.json({ status: "success", data: plan });
  } catch (error) {
    next(error);
  }
};

// Delete Plan
export const deletePlan = async (req, res, next) => {
  try {
    const plan = await Plan.findByIdAndDelete(req.params.id);
    if (!plan) {
      return res
        .status(404)
        .json({ status: "error", message: "Plan not found" });
    }
    res.json({ status: "success", message: "Plan deleted successfully" });
  } catch (error) {
    next(error);
  }
};
