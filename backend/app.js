import express from "express";
import { connectDB } from "./config/database.js";
import ErrorMiddleware from "./middleware/Error.js";
import fileupload from "express-fileupload";
import { Server } from "socket.io";
import cors from "cors";
import http from "http";

import userRoute from "./routes/userRoute.js";
import vendorRoute from "./routes/vendorRoute.js";
import serviceRoute from "./routes/serviceRoute.js";
import categoryRouter from "./routes/categoryRoute.js";
import subcategoryRouter from "./routes/subcategoryRoute.js";
import bookingRouter from "./routes/bookingRoute.js";
import reviewRoute from "./routes/reviewRoutes.js";
import chatRouter from "./routes/chatRoute.js";
import notifyRouter from "./routes/notificationRoute.js";
import planRouter from "./routes/planRoutes.js";
import referralRouter from "./routes/referralRoutes.js";
import subscriptionRouter from "./routes/subscription.js";
import verifyRouter from "./routes/verify.routes.js";
import adminRoute from "./routes/adminRoute.js";  // <-- import your adminRoute

import "./cron/expireSubscriptions.js";
import { handleSocketConnections } from "./utils/socketHandlers.js";

connectDB();

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: "*" },
});

// ✅ Single source of socket logic
handleSocketConnections(io);

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(fileupload({ useTempFiles: true }));

app.use("/user", userRoute);
app.use("/vendor", vendorRoute);
app.use("/service", serviceRoute);
app.use("/category", categoryRouter);
app.use("/subcategory", subcategoryRouter);
app.use("/booking", bookingRouter);
app.use("/review", reviewRoute);
app.use("/chat", chatRouter);
app.use("/notification", notifyRouter);
app.use("/plans", planRouter);
app.use("/subscription", subscriptionRouter);
app.use("/referral", referralRouter);
app.use("/verify", verifyRouter);
app.use("/admin", adminRoute);

app.get("/", (req, res) => {
  res.send("App is running");
});

server.listen(process.env.PORT || 8080, () => {
  console.log("Server running on port", process.env.PORT || 4000);
});

app.use(ErrorMiddleware);
