import express from "express";
import {
  Create,
  deleteServiceById,
  getAllService,
  getServiceById,
  updateService,
  getServiceByUserId,
} from "../controller/serviceController.js";
const serviceRoute = express.Router();

serviceRoute.route("/create").post(Create);
serviceRoute.route("/getAll").get(getAllService);
serviceRoute.route("/get/:serviceId").get(getServiceById);
serviceRoute.route("/update/:serviceId").put(updateService);
serviceRoute.route("/byVendorId/:vendorId").get(getServiceByUserId);
serviceRoute.route("/delete/:serviceId").delete(deleteServiceById);

export default serviceRoute;
