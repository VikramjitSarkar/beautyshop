import { catchAsyncError } from "../middleware/catchAsyncError.js";

import { Packages } from "../model/Packeges.js";
import cloudinary from "cloudinary";
cloudinary.v2.config({
  cloud_name: "ddu4sybue",
  api_key: "658491673268817",
  api_secret: "w35Ei6uCvbOcaN4moWBKL3BmW4Q",
});

export const Create = catchAsyncError(async (req, res, next) => {
  const data = req.body;
  let updatedFields = { ...data };

  if (req.files && req.files.image) {
    let image = req.files.image;

    const result = await cloudinary.v2.uploader.upload(image.tempFilePath, {
      folder: "images",
    });

    updatedFields.image = result.secure_url;
  } else {
    return res
      .status(400)
      .json({ message: "Please select service image", status: "fail" });
  }
  const newPackages = await Packages.create(updatedFields);
  res.status(200).json({
    status: "success",
    message: "Packages created successfully",
    data: newPackages,
  });
});

export const getPackagesById = async (req, res, next) => {
  const id = req?.params?.packageId;
  try {
    const data = await Packages.findById(id);

    res.json({
      status: "success",
      data: data,
    });
  } catch (error) {
    console.log(error);
    next(error);
  }
};

export const updatePackages = catchAsyncError(async (req, res, next) => {
  const data = req.body;
  const packageId = req?.params?.packageId;
  let updatedFields = { ...data };
  if (req.files && req.files.image) {
    let image = req.files.image;

    const result = await cloudinary.v2.uploader.upload(image.tempFilePath, {
      folder: "images",
    });

    updatedFields.image = result.secure_url;
  }
  const updatedPackages = await Packages.findByIdAndUpdate(
    packageId,
    updatedFields,
    {
      new: true,
    }
  );

  if (!updatedPackages) {
    return res.status(404).json({ message: "Package not found" });
  }

  res.status(200).json({
    status: "success",
    data: updatedPackages,
    message: "Package updated successfully!",
  });
});

export const getAllPackages = catchAsyncError(async (req, res, next) => {
  try {
    const packages = await Packages.find();
    res.status(200).json({
      status: "success",
      data: packages,
    });
  } catch (error) {
    console.error("Error fetching packages:", error);
    res.status(500).json({
      status: "fail",
      error: "Internal Server Error",
    });
  }
});

export const deletePackageById = async (req, res, next) => {
  const id = req?.params?.packageId;
  try {
    const delPackages = await Packages.findByIdAndDelete(id);
    if (!delPackages) {
      return res.json({ status: "fail", message: "Package not Found" });
    }
    res.json({
      status: "success",
      message: "Package deleted successfully!",
    });
  } catch (error) {
    console.log(error);
    next(error);
  }
};
