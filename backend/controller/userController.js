import { catchAsyncError } from "../middleware/catchAsyncError.js";
// import { Customer } from "../model/customer.js";
import { User } from "../model/User.js";
import { Vendor } from "../model/Vendor.js";
import jwt from "jsonwebtoken";
import crypto from "crypto";
import cloudinary from "cloudinary";
cloudinary.v2.config({
  cloud_name: "ddu4sybue",
  api_key: "658491673268817",
  api_secret: "w35Ei6uCvbOcaN4moWBKL3BmW4Q",
});
import { Review } from "../model/Review.js";
import transporter from "../utils/mailer.js";
// register user
export const register = catchAsyncError(async (req, res, next) => {
  const data = req.body;
  const email = data?.email;
  const existingUser = await User.findOne({ email });
  if (existingUser) {
    res.status(400).json({ message: "Email already exist", status: "fail" });
  } else {
    const newUser = await User.create(data);
    const token = jwt.sign(
      {
        userId: newUser._id.toString(),
      },
      "somesecretsecret",
      { expiresIn: "30d" }
    );
    res.status(200).json({
      status: "success",
      message: "User registered successfully",
      data: newUser,
      token: token,
    });
  }
});

// login user
export const login = catchAsyncError(async (req, res, next) => {
  const { email, password, fcmToken } = req.body;

  const existingUser = await User.findOne({ email });
  if (!existingUser) {
    return res.status(400).json({ status: "fail", message: "Email not registered" });
  }

  if (existingUser.password !== password) {
    return res.status(400).json({ status: "fail", message: "Incorrect password" });
  }

  // New: block login if this user is blocked
  if (existingUser.status === "blocked") {
    return res.status(403).json({ status: "fail", message: "Your account is blocked. Contact support." });
  }

  // Update FCM token
  await User.findByIdAndUpdate(existingUser._id, { fcmToken }, { new: true });

  // Generate JWT
  const token = jwt.sign(
    { userId: existingUser._id.toString(), role: existingUser.role },
    process.env.JWT_SECRET || "somesecretsecret",
    { expiresIn: "30d" }
  );

  res.status(200).json({
    status: "success",
    message: "User logged in successfully",
    data: existingUser,
    token
  });
});



// get user by id
export const getUserById = async (req, res, next) => {
  const id = req?.user?.userId;
  try {
    const data = await User.findById(id);

    res.json({
      status: "success",
      data: data,
    });
  } catch (error) {
    console.log(error);
    next(error);
  }
};
// Update Profile
// userController.js
export const UpdateProfile = catchAsyncError(async (req, res, next) => {
  const userId = req?.user?.userId;

  // Start with a whitelist to avoid arbitrary updates
  const allowed = [
    "userName","email","phone","locationAdress","userLat","userLong",
    "gender","dateOfBirth","isPhoneVerified"
  ];
  const body = req.body || {};
  const updatedFields = {};

  // Accept both casings and normalize
  if (typeof body.gender === "string") {
    updatedFields.gender = body.gender.trim().toLowerCase(); // male/female/other
  }
  if (body.dateOfBirth) {
    updatedFields.dateOfBirth = body.dateOfBirth;    // preferred
  } else if (body.dateofBirth) {
    updatedFields.dateOfBirth = body.dateofBirth;    // legacy from app
  }

  // Copy remaining allowed fields if present
  for (const k of allowed) {
    if (k in body && !(k in updatedFields)) updatedFields[k] = body[k];
  }

  // Handle image if present (express-fileupload/multer)
  if (req.files && req.files.profileImage) {
    const image = req.files.profileImage;
    const result = await cloudinary.v2.uploader.upload(image.tempFilePath, { folder: "images" });
    updatedFields.profileImage = result.secure_url;
  }

  const updatedUser = await User.findByIdAndUpdate(userId, updatedFields, { new: true });
  if (!updatedUser) return res.status(404).json({ message: "User not found" });

  return res.status(200).json({
    status: "success",
    data: updatedUser,
    message: "user updated successfully!",
  });
});

export const updatePassword = catchAsyncError(async (req, res, next) => {
  const data = req.body;
  const userId = req.params.userId;
  const password = data.password;
  const data1 = {
    password: data.newPassword,
  };
  if (!password) {
    return res.status(400).json({ message: "Password is required" });
  }
  const updatedUser = await User.findByIdAndUpdate(userId, data1, {
    new: true,
  });

  if (!updatedUser) {
    return res.status(404).json({ message: "User not found" });
  }

  res.status(200).json({
    status: "success",
    data: updatedUser,
    message: "password updated successfully!",
  });
});
export const UpdateStatus = catchAsyncError(async (req, res, next) => {
  const data = req.body;
  const userId = req.params.id;

  const updatedUser = await User.findByIdAndUpdate(
    userId,
    { status: data?.status },
    {
      new: true,
    }
  );

  if (!updatedUser) {
    return res.status(404).json({ message: "User not found" });
  }

  res.status(200).json({
    status: "success",
    data: updatedUser,
    message: "user status updated successfully!",
  });
});

// Get All User
export const getAllUsers = catchAsyncError(async (req, res, next) => {
  try {
    const users = await User.find();
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
export const deleteCustomerById = async (req, res, next) => {
  const id = req?.user?.userId;
  try {
    const delCustomer = await User.findByIdAndDelete(id);
    if (!delCustomer) {
      return res.json({ status: "fail", message: "Customer not Found" });
    }
    res.json({
      status: "success",
      message: "User deleted successfully!",
    });
  } catch (error) {
    console.log(error);
    next(error);
  }
};
export const markFavorite = async (req, res, next) => {
  const userId = req.user.userId; // Assuming you're using auth
  const vendorId = req.params.vendorId;

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: "User not found" });

    if (user.favoriteVendors.includes(vendorId)) {
      return res.status(400).json({ message: "Vendor already favorited" });
    }

    // Add vendor to user's favorites
    user.favoriteVendors.push(vendorId);
    await user.save();

    // Increment vendor's favoriteCount
    await Vendor.findByIdAndUpdate(
      vendorId,
      { $inc: { favoriteCount: 1 } },
      { new: true }
    );

    res.json({ status: "success", message: "Vendor favorited!" });
  } catch (error) {
    next(error);
  }
};

// ❌ Remove from favorites
export const unmarkFavorite = async (req, res, next) => {
  const userId = req.user.userId;
  const vendorId = req.params.vendorId;

  try {
    const user = await User.findByIdAndUpdate(
      userId,
      { $pull: { favoriteVendors: vendorId } },
      { new: true }
    );

    if (!user) return res.status(404).json({ message: "User not found" });

    // Decrement vendor's favoriteCount (don't go below 0)
    await Vendor.findByIdAndUpdate(
      vendorId,
      { $inc: { favoriteCount: -1 } },
      { new: true }
    );

    // Ensure favoriteCount doesn't go below 0
    await Vendor.findOneAndUpdate(
      { _id: vendorId, favoriteCount: { $lt: 0 } },
      { $set: { favoriteCount: 0 } }
    );

    res.json({ status: "success", message: "Vendor unfavorited!" });
  } catch (error) {
    next(error);
  }
};

// 📄 Get all favorite vendors
export const getFavoriteVendors = async (req, res, next) => {
  const userId = req.user.userId;

  try {
    const user = await User.findById(userId).populate("favoriteVendors");
    if (!user) return res.status(404).json({ message: "User not found" });

    const enrichedVendors = await Promise.all(
      user.favoriteVendors.map(async (vendor) => {
        return {
          ...vendor._doc,
          avgRating: parseFloat((vendor.shopRating || 0).toFixed(1)),
        };
      })
    );

    res.json({
      status: "success",
      data: enrichedVendors,
    });
  } catch (error) {
    next(error);
  }
  


};

/* -------------------------------------password change logic last min change----------------------------------------------- */

  const _findModel = async (email) => {
  let user = await User.findOne({ email });
  if (user) return { doc: user, type: "User" };
  let vendor = await Vendor.findOne({ email });
  if (vendor) return { doc: vendor, type: "Vendor" };
  return {};
};

export const forgotPassword = async (req, res) => {
  const { email } = req.body;
  const { doc } = await _findModel(email);
  if (!doc) return res.status(404).json({ error: "Not found" });

  const token = crypto.randomBytes(32).toString("hex");
  doc.resetPasswordToken    = token;
  doc.resetPasswordExpires  = Date.now() + 3600_000; // 1 hr
  await doc.save();

  // verify once
  await transporter.verify();
  console.log("✅ SMTP connection OK");

  // send and capture result
 const info = await transporter.sendMail({
  from: `"Beauty Shop Support" <noreply@thebeautyshop.io>`,
  to: email,
  subject: "Your Salon App password reset token",
  text: `Your reset token is: ${token}
  
Please copy & paste this into the app to reset your password.
This token expires in 1 hour.`,
  html: `
    <p>Your reset token is:</p>
    <h2>${token}</h2>
    <p>Please copy &amp; paste it into the app.</p>
    <p><small>Expires in 1 hour.</small></p>
  `
});
console.log("📧 Message sent:", info.messageId);

  console.log("📧 Message sent:", info.messageId, "|", info.response);

  return res.json({ message: "Password reset link sent." });
};


export const  resetOrUpdatePassword = async (req, res) => {
  const { token, oldPassword, newPassword } = req.body;
  let doc, type;

  if (oldPassword) {
    // in-session update
    const auth = req.headers.authorization?.split(" ")[1];
    if (!auth) return res.status(401).json({ error: "Unauthorized" });
    const payload = jwt.verify(auth, process.env.JWT_SECRET);
    ({ doc, type } = payload.model==="Vendor"
      ? { doc: await Vendor.findById(payload.id), type: "Vendor" }
      : { doc: await User.findById(payload.id), type: "User" });
    if (!doc) return res.status(404).json({ error: "User not found" });
    const ok = await bcrypt.compare(oldPassword, doc.password);
    if (!ok) return res.status(400).json({ error: "Wrong password" });
  } else if (token) {
    // reset via email
    doc = await User.findOne({
      resetPasswordToken: token,
      resetPasswordExpires: { $gt: Date.now() }
    }) || await Vendor.findOne({
      resetPasswordToken: token,
      resetPasswordExpires: { $gt: Date.now() }
    });
    if (!doc) return res.status(400).json({ error: "Invalid or expired token" });
  } else {
    return res.status(400).json({ error: "Bad request" });
  }

  doc.password = newPassword;
  doc.resetPasswordToken = undefined;
  doc.resetPasswordExpires = undefined;
  await doc.save();
  return res.json({ message: "Password updated." });
};
/*                   google sign in last min change                            */

export const socialLogin = catchAsyncError(async (req, res) => {
  const {
    socialId,
    email,
    name,
    profileImage,
    deviceToken,
    type,           // "user" or "vendor"
  } = req.body;

  if (
    !socialId ||
    !email ||
    !["user", "vendor"].includes(type)
  ) {
    return res
      .status(400)
      .json({ message: "Require socialId, email and type:user|vendor" });
  }

  let account;

  if (type === "vendor") {
    account =
      (await Vendor.findOne({ socialId })) ||
      (await Vendor.findOne({ email }));
    if (!account) {
      account = await Vendor.create({
        socialId,
        email,
        userName: name,
        profileImage,
        password: socialId,      // one‐time secret
        fcmToken: deviceToken,
      });
    }

  } else {
    account =
      (await User.findOne({ socialId })) ||
      (await User.findOne({ email }));
    if (!account) {
      account = await User.create({
        socialId,
        email,
        userName: name,
        profileImage,
        password: socialId,
        fcmToken: deviceToken,
      });
    }
  }

  account.fcmToken = deviceToken;
  await account.save();

  const token = jwt.sign(
    { userId: account._id.toString(), role: type },
    process.env.JWT_SECRET|| "somesecretsecret",
    { expiresIn: "30d" }
  );

  res.json({
    status: "success",
    role: type,
    token,
    user: account,
  });
});