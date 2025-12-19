import express from "express";
import {
  Create,
  getAllPackages,
  getPackagesById,
  deletePackageById,
  updatePackages,
} from "../controller/packagesController.js";
const packageRoute = express.Router();

packageRoute.route("/register").post(Create);
packageRoute.route("/getAll").get(getAllPackages);
packageRoute.route("/get/:packageId").get(getPackagesById);
packageRoute.route("/update/:packageId").put(updatePackages);
packageRoute.route("/delete/:id").delete(deletePackageById);

export default packageRoute;
