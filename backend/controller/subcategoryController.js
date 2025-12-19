import { catchAsyncError } from "../middleware/catchAsyncError.js";
import { SubCategory } from "../model/SubCategory.js";
import { Review } from "../model/Review.js";
import { Vendor } from "../model/Vendor.js";
import { Service } from "../model/Service.js";
import { User } from "../model/User.js";
import cloudinary from "cloudinary";
cloudinary.v2.config({
  cloud_name: "ddu4sybue",
  api_key: "658491673268817",
  api_secret: "w35Ei6uCvbOcaN4moWBKL3BmW4Q",
});

// create SubCategory
export const createSubCategory = catchAsyncError(async (req, res, next) => {
  const data = req.body;
  let updatedFields = { ...data };

  if (req.files && req.files.image) {
    let image = req.files.image;

    // Uploading to Cloudinary folder "my_app/images"
    const result = await cloudinary.v2.uploader.upload(image.tempFilePath, {
      folder: "images", // change this to your desired folder path
    });

    updatedFields.image = result.secure_url; // it's better to use secure_url
  }
  const newSubCategory = await SubCategory.create(updatedFields);
  res.status(200).json({
    status: "success",
    message: "New SubCategory created successfully!",
    data: newSubCategory,
  });
});

// get SubCategory by id
export const getSubCategoryById = async (req, res, next) => {
  const id = req?.params.id;
  try {
    const data = await SubCategory.findById(id);

    res.json({
      status: "success",
      data: data,
    });
  } catch (error) {
    console.log(error);
    res.status(500).json({
      status: "fail",
      error: "Internal Server Error",
    });
  }
};
// update SubCategory
export const updateSubCategory = catchAsyncError(async (req, res, next) => {
  const data = req.body;
  const categoryId = req.params.id;

  const updatedSubCategory = await SubCategory.findByIdAndUpdate(
    categoryId,
    data,
    {
      new: true,
    }
  );
  if (!updatedSubCategory) {
    return res.status(404).json({ message: "SubCategory not found" });
  }

  res.status(200).json({
    status: "success",
    data: updatedSubCategory,
    message: "SubCategory updated successfully!",
  });
});

// Get All SubCategory
export const getAllSubCategory = catchAsyncError(async (req, res, next) => {
  try {
    const subcategory = await SubCategory.find();
    res.status(200).json({
      status: "success",
      data: subcategory,
    });
  } catch (error) {
    console.error("Error fetching users:", error);
    res.status(500).json({
      status: "fail",
      error: "Internal Server Error",
    });
  }
});
export const getCategoryById = catchAsyncError(async (req, res, next) => {
  const categoryId = req?.params.categoryId;
  try {
    const subcategory = await SubCategory.find({ categoryId: categoryId });
    res.status(200).json({
      status: "success",
      data: subcategory,
    });
  } catch (error) {
    console.error("Error fetching users:", error);
    res.status(500).json({
      status: "fail",
      error: "Internal Server Error",
    });
  }
});
// delete SubCategory
export const deleteSubCategoryById = async (req, res, next) => {
  const id = req.params.id;
  try {
    const delSubCategory = await SubCategory.findByIdAndDelete(id);
    if (!delSubCategory) {
      return res.json({ status: "fail", message: "SubCategory not Found" });
    }
    res.json({
      status: "success",
      message: "SubCategory deleted successfully!",
    });
  } catch (error) {
    console.log(error);
    next(error);
  }
};
const haversineDistance = (lat1, lon1, lat2, lon2) => {
  const R = 6371; // Earth radius in km
  const dLat = (lat2 - lat1) * (Math.PI / 180);
  const dLon = (lon2 - lon1) * (Math.PI / 180);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * (Math.PI / 180)) *
      Math.cos(lat2 * (Math.PI / 180)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
};

export const getVendorsByCategory = async (req, res, next) => {
  try {
    const { userLat, userLong, categoryId } = req.body;
    const { minPrice, maxPrice } = req.query;

    let filter = {};

    if (req.query.status) {
      filter.status = req.query.status;
    }

    if (req.query.homeVisit) {
      filter.homeServiceAvailable =
        req.query.homeVisit === "true" || req.query.homeVisit === "on";
    }

    if (req.query.hasSalon) {
      filter.hasPhysicalShop =
        req.query.hasSalon === "true" || req.query.hasSalon === "on";
    }

    console.log("[FILTER] Vendor query filter:", filter);
    console.log("[PARAMS] categoryId:", categoryId, "userLat:", userLat, "userLong:", userLong);
    console.log("[PARAMS] minPrice:", minPrice, "maxPrice:", maxPrice);

    if (!categoryId) {
      return res.status(400).json({
        status: "error",
        message: "User location and category ID are required",
      });
    }

    if (!userLat || !userLong) {
      return res.status(400).json({
        status: "error",
        message: "User location is not available",
      });
    }

    const vendors = await Vendor.find(filter);
    console.log(`[VENDOR] Total vendors after filter: ${vendors.length}`);

    const vendorsWithFullData = await Promise.all(
      vendors.map(async (vendor) => {
        const distance = haversineDistance(
          userLat,
          userLong,
          vendor.vendorLat,
          vendor.vendorLong
        );

        if (distance > 30) {
          console.log(`[SKIP] Vendor ${vendor._id} skipped due to distance (${distance} km)`);
          return null;
        }

        const service = await Service.findOne({
          createdBy: vendor._id,
          categoryId,
        }).sort({ charges: 1 });

        if (!service) {
          console.log(`[SKIP] Vendor ${vendor._id} has no service in category ${categoryId}`);
          return null;
        }

        const min = parseFloat(minPrice);
        const max = parseFloat(maxPrice);

        if (
          (!isNaN(min) && service.charges < min) ||
          (!isNaN(max) && service.charges > max)
        ) {
          console.log(`[SKIP] Vendor ${vendor._id} service price ${service.charges} out of range`);
          return null;
        }

        const reviews = await Review.find({ vendor: vendor._id });
        const avgRating =
          reviews.length > 0
            ? reviews.reduce((acc, r) => acc + r.rating, 0) / reviews.length
            : 0;

        console.log(`[PASS] Vendor ${vendor._id} included — distance: ${distance.toFixed(2)}, price: ${service.charges}, rating: ${avgRating.toFixed(1)}`);

        return {
          ...vendor.toObject(),
          distance: distance.toFixed(2),
          avgRating: avgRating.toFixed(1),
          charges: service.charges,
        };
      })
    );

    const filteredVendors = vendorsWithFullData.filter((v) => v !== null);

    if (!filteredVendors.length) {
      console.log("[RESULT] No vendors passed all filters.");
      return res.status(404).json({
        status: "error",
        message: "No vendors found matching the criteria",
      });
    }

    const sortedVendors = filteredVendors.sort(
      (a, b) => b.avgRating - a.avgRating
    );

    console.log(`[RESULT] ${sortedVendors.length} vendors returned.`);

    res.status(200).json({
      status: "success",
      message: "Vendors fetched successfully",
      data: sortedVendors,
    });
  } catch (error) {
    console.error("[ERROR] getVendorsByCategory failed:", error);
    next(error);
  }
};


