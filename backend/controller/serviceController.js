import { catchAsyncError } from "../middleware/catchAsyncError.js";
import { Service } from "../model/Service.js";
import cloudinary from "cloudinary";
import { Review } from "../model/Review.js";

cloudinary.v2.config({
  cloud_name: "ddu4sybue",
  api_key: "658491673268817",
  api_secret: "w35Ei6uCvbOcaN4moWBKL3BmW4Q",
});

export const Create = catchAsyncError(async (req, res, next) => {
  const data = req.body;

  const newService = await Service.create(data);
  res.status(200).json({
    status: "success",
    message: "Service created successfully",
    data: newService,
  });
});

export const getServiceById = async (req, res, next) => {
  const id = req?.params?.serviceId;
  try {
    const data = await Service.findById(id)
      .populate("categoryId", "name")
      .populate("subcategoryId", "name");

    res.json({
      status: "success",
      data,
    });
  } catch (error) {
    console.log(error);
    next(error);
  }
};


export const getServiceByUserId = async (req, res, next) => {
  const id = req?.params?.vendorId;
  try {
    const data = await Service.find({ createdBy: id })
      .populate("categoryId")
      .populate("subcategoryId");

    const enhancedData = await Promise.all(
      data.map(async (service) => {
        const reviews = await Review.find({ vendor: id });
        const categoryId = service.categoryId?._id?.toString();

        // Filter reviews for the same category
        const categoryReviews = reviews.filter(
          (rev) => rev?.vendor?.toString() === id
        );

        const avgRating =
          categoryReviews.length > 0
            ? (
                categoryReviews.reduce((acc, r) => acc + r.rating, 0) /
                categoryReviews.length
              ).toFixed(1)
            : "0.0";

        return {
          ...service.toObject(),
          avgRating,
        };
      })
    );

    res.json({
      status: "success",
      data: enhancedData,
    });
  } catch (error) {
    console.log(error);
    next(error);
  }
};

export const updateService = catchAsyncError(async (req, res, next) => {
  const data = req.body;
  const serviceId = req?.params?.serviceId;
  let updatedFields = { ...data };

  const updatedService = await Service.findByIdAndUpdate(
    serviceId,
    updatedFields,
    {
      new: true,
    }
  );

  if (!updatedService) {
    return res.status(404).json({ message: "Service not found" });
  }

  res.status(200).json({
    status: "success",
    data: updatedService,
    message: "Service updated successfully!",
  });
});

export const getAllService = catchAsyncError(async (req, res, next) => {
  try {
    const services = await Service.find();
    res.status(200).json({
      status: "success",
      data: services,
    });
  } catch (error) {
    console.error("Error fetching services:", error);
    res.status(500).json({
      status: "fail",
      error: "Internal Server Error",
    });
  }
});

export const deleteServiceById = async (req, res, next) => {
  const id = req?.params?.serviceId;
  try {
    const delService = await Service.findByIdAndDelete(id);
    if (!delService) {
      return res.json({ status: "fail", message: "Service not Found" });
    }
    res.json({
      status: "success",
      message: "Service deleted successfully!",
    });
  } catch (error) {
    console.log(error);
    next(error);
  }
};
