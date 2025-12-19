// middleware/AuthMiddleware.js

import jwt from "jsonwebtoken";

const AuthMiddleware = (req, res, next) => {
  const authHeader = req.get("Authorization");
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res
      .status(401)
      .json({ message: "Not authorized — token missing" });
  }

  const token = authHeader.split(" ")[1];
  let payload;
  try {
    payload = jwt.verify(token, process.env.JWT_SECRET || "somesecretsecret");
  } catch (err) {
    return res
      .status(401)
      .json({ message: "Not authorized — invalid or expired token" });
  }

  // Must be an admin
  if (payload.role !== "admin") {
    return res
      .status(403)
      .json({ message: "Forbidden — admins only" });
  }

  // Attach for downstream handlers
  req.userId   = payload.userId;
  req.userRole = payload.role;
  next();
};

export default AuthMiddleware;
