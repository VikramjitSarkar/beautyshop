import { catchAsyncError } from "../middleware/catchAsyncError.js";
// import { Customer } from "../model/customer.js";
import { Vendor } from "../model/Vendor.js";
import { User } from "../model/User.js";
import { Service } from "../model/Service.js";
import { Review } from "../model/Review.js";
import jwt from "jsonwebtoken";
import cloudinary from "cloudinary";
cloudinary.v2.config({
  cloud_name: "ddu4sybue",
  api_key: "658491673268817",
  api_secret: "w35Ei6uCvbOcaN4moWBKL3BmW4Q",
});

// login user
export const loginVendor = catchAsyncError(async (req, res) => {
  const { email, password, fcmToken } = req.body;
  if (!email || !password) {
    return res.status(400).json({ status: "fail", message: "Email and password are required" });
  }

  const vendor = await Vendor.findOne({ email });
  if (!vendor) {
    return res.status(400).json({ status: "fail", message: "Email not registered" });
  }

  if (vendor.password !== password) {
    return res.status(400).json({ status: "fail", message: "Incorrect password" });
  }

  if (vendor.accountStatus === "blocked") {
    return res
      .status(403)
      .json({ status: "fail", message: "Account blocked. Contact support." });
  }

  // update FCM
  vendor.fcmToken = fcmToken;
  await vendor.save();

  const token = jwt.sign(
    { userId: vendor._id.toString(), role: vendor.role },
    process.env.JWT_SECRET || "somesecretsecret",
    { expiresIn: "30d" }
  );

  res.status(200).json({
    status: "success",
    message: "Vendor logged in successfully",
    data: vendor,
    isProfileComplete: vendor.isProfileComplete || false,
    token,
  });
});




// get user by id
export const getVendorById = async (req, res, next) => {
  const id = req?.user?.userId;

  try {
    const vendor = await Vendor.findById(id);
    if (!vendor) {
      return res.status(404).json({ status: "fail", message: "Vendor not found" });
    }

    const reviews = await Review.find({ vendor: id });
    const avgRating =
      reviews.length > 0
        ? reviews.reduce((sum, r) => sum + r.rating, 0) / reviews.length
        : 0;

    res.json({
      status: "success",
      data: {
        ...vendor.toObject(),
        avgRating: parseFloat(avgRating.toFixed(1)),
      },
    });
  } catch (error) {
    console.log(error);
    next(error);
  }
};
export const getVendorById2 = async (req, res, next) => {
  const id = req?.params?.vendorId;
  try {
    const vendor = await Vendor.findById(id);

    if (!vendor) {
      return res.status(404).json({
        status: "error",
        message: "Vendor not found",
      });
    }

    // Get all reviews for the vendor
    const reviews = await Review.find({ vendor: id });

    // Calculate average rating
    const avgRating =
      reviews.length > 0
        ? reviews.reduce((sum, r) => sum + r.rating, 0) / reviews.length
        : 0;

    res.json({
      status: "success",
      data: {
        ...vendor.toObject(),
        avgRating: avgRating.toFixed(1),
      },
    });
  } catch (error) {
    console.log(error);
    next(error);
  }
};


export const ProfileSetup = catchAsyncError(async (req, res, next) => {
  const data = req.body;
  const userId = req?.user?.userId;
  let updatedFields = { ...data };

  console.log('=== PROFILE SETUP ENDPOINT ===');
  console.log('Received fields:', Object.keys(data));
  console.log('hasPhysicalShop in request:', data.hasPhysicalShop);
  console.log('homeServiceAvailable in request:', data.homeServiceAvailable);

  const existingUser = await Vendor.findById(userId);
  if (!existingUser) return res.status(404).json({ message: "User not found" });

  console.log('BEFORE UPDATE:');
  console.log('hasPhysicalShop:', existingUser.hasPhysicalShop);
  console.log('homeServiceAvailable:', existingUser.homeServiceAvailable);

  const uploadIfPresent = async (key, folder, options = {}) => {
    if (req.files?.[key]) {
      const result = await cloudinary.v2.uploader.upload(req.files[key].tempFilePath, {
        folder,
        ...options,
      });
      updatedFields[key] = result.secure_url;
    }
  };

  // image uploads
  await uploadIfPresent("cnicImage", "cnics");
  await uploadIfPresent("certificateImage", "certificates");
  await uploadIfPresent("profileImage", "images");
  await uploadIfPresent("shopBanner", "banners");
  await uploadIfPresent("video", "videos", { resource_type: "video" });

  // gallery
  if (req.files?.gallery) {
    const gallery = Array.isArray(req.files.gallery) ? req.files.gallery : [req.files.gallery];
    if (gallery.length > 5) {
      return res.status(400).json({ message: "You can upload a maximum of 5 images in the gallery." });
    }
    const uploadedGalleryUrls = [];
    for (let img of gallery) {
      const result = await cloudinary.v2.uploader.upload(img.tempFilePath, { folder: "gallery" });
      uploadedGalleryUrls.push(result.secure_url);
    }
    updatedFields.gallery = uploadedGalleryUrls;
  }

  // flags - convert string to boolean if provided
  if (typeof data.homeServiceAvailable !== "undefined") {
    updatedFields.homeServiceAvailable = data.homeServiceAvailable === "true";
  }
  if (typeof data.hasPhysicalShop !== "undefined") {
    updatedFields.hasPhysicalShop = data.hasPhysicalShop === "true";
  }

  // preserve existing critical fields if not provided
  if (!updatedFields.cnic && existingUser.cnic) updatedFields.cnic = existingUser.cnic;
  if (!updatedFields.license && existingUser.license) updatedFields.license = existingUser.license;
  
  // ✅ FIX: Preserve boolean flags if not explicitly provided in update request
  if (typeof data.homeServiceAvailable === "undefined") {
    updatedFields.homeServiceAvailable = existingUser.homeServiceAvailable;
  }
  if (typeof data.hasPhysicalShop === "undefined") {
    updatedFields.hasPhysicalShop = existingUser.hasPhysicalShop;
  }

  // Use $set operator to only update provided fields
  const updatedUser = await Vendor.findByIdAndUpdate(
    userId, 
    { $set: updatedFields }, 
    { new: true }
  );

  console.log('AFTER UPDATE:');
  console.log('hasPhysicalShop:', updatedUser.hasPhysicalShop);
  console.log('homeServiceAvailable:', updatedUser.homeServiceAvailable);
  console.log('updatedFields keys:', Object.keys(updatedFields));
  console.log('==============================');

  const requiredFields = [
    "age", "cnic", "description", "email", "gender", "homeServiceAvailable", "listingPlan",
    "name", "password", "phone", "profileImage", "shopName", "surname", "userName",
    "whatsapp", "hasPhysicalShop"
  ];

  const isComplete = requiredFields.every(field => {
    const value = updatedUser[field];
    return value !== undefined && value !== null && value !== "" && !(Array.isArray(value) && value.length === 0);
  });

  if (isComplete && !updatedUser.isProfileComplete) {
    updatedUser.isProfileComplete = true;
    await updatedUser.save();
  }

  res.status(200).json({
    status: "success",
    data: updatedUser,
    message: "vendor updated successfully!",
  });
});


export const UpdateStatus = catchAsyncError(async (req, res) => {
  const { id } = req.params;
  const { status, accountStatus } = req.body;

  const update = {};
  if (accountStatus !== undefined) {
    update.accountStatus = accountStatus;
  } else if (status !== undefined) {
    update.status = status;
  } else {
    return res.status(400).json({
      status: 'fail',
      message: 'Provide either "status" or "accountStatus" in body'
    });
  }

  const updated = await Vendor.findByIdAndUpdate(id, update, { new: true });
  if (!updated) {
    return res.status(404).json({ status: 'fail', message: 'Vendor not found' });
  }

  res.status(200).json({
    status: 'success',
    data: updated,
    message: `${accountStatus !== undefined ? 'accountStatus' : 'status'} updated`
  });
});


export const getAllVendor = catchAsyncError(async (req, res, next) => {
  try {
    const users = await Vendor.find();
    res.status(200).json({
      status: "success",
      data: users,
    });
  } catch (error) {
    console.error("Error fetching users:", error);
    res.status(500).json({
      status: "fail",
      error: "Internal Server Error",
    });
  }
});
// delet user
export const deleteVendorById = async (req, res, next) => {
  const id = req.params.id;
  try {
    const delVendor = await Vendor.findByIdAndDelete(id);
    if (!delVendor) {
      return res.status(404).json({ status: "fail", message: "Vendor not found" });
    }
    res.json({ status: "success", message: "Vendor deleted successfully!" });
  } catch (error) {
    console.error(error);
    next(error);
  }
};

export const getNearbyVendors = async (req, res, next) => {
  try {
    const { userLat, userLong, categoryId } = req.body;

    if (!userLat || !userLong) {
      return res
        .status(400)
        .json({ status: "error", message: "User location not available" });
    }

    // Find services filtered by category if provided
    const serviceQuery = categoryId ? { categoryId } : {};
    const services = await Service.find(serviceQuery);

    const vendorIds = [
      ...new Set(services.map((service) => service.createdBy.toString())),
    ];

    if (vendorIds.length === 0) {
      return res
        .status(404)
        .json({ status: "error", message: "No vendors found for this category" });
    }

    const vendors = await Vendor.find(
      { _id: { $in: vendorIds } },
      "profileImage shopName shopBanner vendorLat vendorLong"
    );

    const calculateDistance = (lat1, lon1, lat2, lon2) => {
      const toRad = (value) => (value * Math.PI) / 180;
      const R = 6371;
      const dLat = toRad(lat2 - lat1);
      const dLon = toRad(lon2 - lon1);
      const a =
        Math.sin(dLat / 2) ** 2 +
        Math.cos(toRad(lat1)) *
          Math.cos(toRad(lat2)) *
          Math.sin(dLon / 2) ** 2;
      const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
      return R * c;
    };

    const nearbyVendors = await Promise.all(
      vendors.map(async (vendor) => {
        if (!vendor.vendorLat || !vendor.vendorLong) return null;

        const distance = calculateDistance(
          parseFloat(userLat),
          parseFloat(userLong),
          parseFloat(vendor.vendorLat),
          parseFloat(vendor.vendorLong)
        );

        if (distance > 30) return null;

        const reviews = await Review.find({ vendor: vendor._id });
        const avgRating =
          reviews.length > 0
            ? reviews.reduce((sum, r) => sum + r.rating, 0) / reviews.length
            : 0;

        return {
          _id: vendor._id,
          profileImage: vendor.profileImage,
          shopBanner: vendor.shopBanner, 
          shopName: vendor.shopName,
          vendorLat: vendor.vendorLat,
          vendorLong: vendor.vendorLong,
          distance: parseFloat(distance.toFixed(2)),
          avgRating: parseFloat(avgRating.toFixed(1)),
        };
      })
    );

    const filteredVendors = nearbyVendors.filter((v) => v !== null);
    filteredVendors.sort((a, b) => a.distance - b.distance);

    res.status(200).json({
      status: "success",
      message: "Nearby vendors fetched successfully",
      data: filteredVendors,
    });
  } catch (error) {
    console.error(error);
    next(error);
  }
};



export const registerVendor = catchAsyncError(async (req, res, next) => {
  const data = req.body;
  const email = data?.email;

  console.log('=== REGISTER VENDOR DEBUG ===');
  console.log('hasPhysicalShop received:', data.hasPhysicalShop, 'type:', typeof data.hasPhysicalShop);
  console.log('homeServiceAvailable received:', data.homeServiceAvailable, 'type:', typeof data.homeServiceAvailable);

  const existingUser = await Vendor.findOne({ email });
  if (existingUser) {
    return res
      .status(400)
      .json({ message: "Email already exists", status: "fail" });
  }

  // start with all incoming fields
  const updatedFields = { ...data };

  // Convert string boolean values to actual booleans
  if (typeof updatedFields.hasPhysicalShop === "string") {
    updatedFields.hasPhysicalShop = updatedFields.hasPhysicalShop === "true";
  }
  if (typeof updatedFields.homeServiceAvailable === "string") {
    updatedFields.homeServiceAvailable = updatedFields.homeServiceAvailable === "true";
  }
  
  console.log('After conversion - hasPhysicalShop:', updatedFields.hasPhysicalShop, 'homeServiceAvailable:', updatedFields.homeServiceAvailable);

  // upload profileImage if provided
  if (req.files && req.files.profileImage) {
    const image = req.files.profileImage;
    const result = await cloudinary.v2.uploader.upload(
      image.tempFilePath,
      { folder: "images" }
    );
    updatedFields.profileImage = result.secure_url;
  }

  // upload shopBanner if provided
  if (req.files && req.files.shopBanner) {
    const banner = req.files.shopBanner;
    const result = await cloudinary.v2.uploader.upload(
      banner.tempFilePath,
      { folder: "banners" }
    );
    updatedFields.shopBanner = result.secure_url;
  }

  // upload CNIC image if provided
  if (req.files && req.files.cnicImage) {
    const cnic = req.files.cnicImage;
    const result = await cloudinary.v2.uploader.upload(
      cnic.tempFilePath,
      { folder: "cnics" }
    );
    updatedFields.cnicImage = result.secure_url;
  }

  // upload Certificate image if provided
  if (req.files && req.files.certificateImage) {
    const cert = req.files.certificateImage;
    const result = await cloudinary.v2.uploader.upload(
      cert.tempFilePath,
      { folder: "certificates" }
    );
    updatedFields.certificateImage = result.secure_url;
  }
  // upload gallery images (array) if provided
if (req.files && req.files.gallery) {
  const uploads = Array.isArray(req.files.gallery)
    ? req.files.gallery
    : [req.files.gallery];

  const galleryUrls = await Promise.all(
    uploads.map(f =>
      cloudinary.v2.uploader.upload(f.tempFilePath, { folder: "gallery" })
        .then(r => r.secure_url)
    )
  );

  updatedFields.gallery = galleryUrls;   // save array of URLs
}

  // create the vendor
  const createdVendor = await Vendor.create(updatedFields);
  const newVendor = await Vendor.findById(createdVendor._id);

  // sign JWT (include role if you like)
  const token = jwt.sign(
    { userId: newVendor._id.toString(), role: newVendor.role },
    process.env.JWT_SECRET || "somesecretsecret",
    { expiresIn: "30d" }
  );

  res.status(200).json({
    status: "success",
    message: "Vendor registered successfully",
    data: newVendor,
    token
  });
});



export const UpdateProfile = catchAsyncError(async (req, res, next) => {
  const data = req.body;
  const userId = req?.user?.userId;
  let updatedFields = { ...data };

  const existingUser = await Vendor.findById(userId);
  if (!existingUser) return res.status(404).json({ message: "User not found" });

  const uploadIfPresent = async (key, folder, options = {}) => {
    if (req.files?.[key]) {
      const result = await cloudinary.v2.uploader.upload(req.files[key].tempFilePath, {
        folder,
        ...options,
      });
      updatedFields[key] = result.secure_url;
    }
  };

  // image uploads
  await uploadIfPresent("profileImage", "images");
  await uploadIfPresent("shopBanner", "banners");
  await uploadIfPresent("cnicImage", "cnics");
  await uploadIfPresent("certificateImage", "certificates");
  await uploadIfPresent("video", "videos", { resource_type: "video" });

  // gallery
  if (req.files?.gallery) {
    const gallery = Array.isArray(req.files.gallery) ? req.files.gallery : [req.files.gallery];
    if (gallery.length > 5) {
      return res.status(400).json({ message: "You can upload a maximum of 5 files in the gallery." });
    }
    const uploadedGalleryUrls = [];
    for (let file of gallery) {
      const isVideo = file.mimetype.startsWith("video/");
      const result = await cloudinary.v2.uploader.upload(file.tempFilePath, {
        folder: "gallery",
        resource_type: isVideo ? "video" : "image",
      });
      uploadedGalleryUrls.push(result.secure_url);
    }
    const existingGallery = Array.isArray(existingUser.gallery) ? existingUser.gallery : [];
    updatedFields.gallery = [...existingGallery, ...uploadedGalleryUrls];
  }

  // flags - convert string to boolean if provided
  if (typeof data.homeServiceAvailable !== "undefined") {
    updatedFields.homeServiceAvailable = data.homeServiceAvailable === "true";
  }
  if (typeof data.hasPhysicalShop !== "undefined") {
    updatedFields.hasPhysicalShop = data.hasPhysicalShop === "true";
  }

  // preserve existing if not reuploaded
  if (!updatedFields.cnic && existingUser.cnic) updatedFields.cnic = existingUser.cnic;
  if (!updatedFields.license && existingUser.license) updatedFields.license = existingUser.license;
  if (!updatedFields.profileImage && existingUser.profileImage) updatedFields.profileImage = existingUser.profileImage;
  
  // ✅ FIX: Preserve boolean flags if not explicitly provided in update request
  if (typeof data.homeServiceAvailable === "undefined") {
    updatedFields.homeServiceAvailable = existingUser.homeServiceAvailable;
  }
  if (typeof data.hasPhysicalShop === "undefined") {
    updatedFields.hasPhysicalShop = existingUser.hasPhysicalShop;
  }

  // Use $set operator to only update provided fields
  const updatedUser = await Vendor.findByIdAndUpdate(
    userId, 
    { $set: updatedFields }, 
    { new: true }
  );

  const requiredFields = [
    "age", "cnic", "description", "email", "gender", "homeServiceAvailable", "listingPlan",
    "name", "password", "phone", "profileImage", "shopName", "surname", "userName",
    "whatsapp", "hasPhysicalShop"
  ];

  const isComplete = requiredFields.every(field => {
    const value = updatedUser[field];
    return value !== undefined && value !== null && value !== "" && !(Array.isArray(value) && value.length === 0);
  });

  if (isComplete && !updatedUser.isProfileComplete) {
    updatedUser.isProfileComplete = true;
    await updatedUser.save();
  }

  res.status(200).json({
    status: "success",
    data: updatedUser,
    message: "vendor updated successfully!",
  });
});




