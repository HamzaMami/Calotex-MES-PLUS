import express from "express";
import cors, { CorsOptions } from "cors";
import helmet from "helmet";
import rateLimit from "express-rate-limit";
import { env } from "./config/env";
import authRoutes from "./modules/auth/routes/auth.routes";
import productRoutes from "./modules/products/routes/product.routes";
import manufacturingRoutes from "./modules/manufacturing/routes/manufacturing_order.routes";
import eventRoutes from "./modules/events/routes/event.routes";
import inventoryRoutes from "./modules/inventory/routes/inventory.routes";
import usersRoutes from "./modules/users/routes/users.routes";
import rolesRoutes from "./modules/roles/routes/roles.routes";
import permissionsRoutes from "./modules/permissions/routes/permissions.routes";
import dashboardRoutes from "./modules/dashboard/routes/dashboard.routes";

const app = express();

// Security headers
app.use(helmet());

// CORS: restrict to configured origins in production; allow all when the
// allowlist is empty (development convenience).
const corsOptions: CorsOptions = {
  origin: env.cors.origins.length > 0 ? env.cors.origins : true,
  credentials: true,
};
app.use(cors(corsOptions));

// Body parsing
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rate limiting to mitigate brute-force / credential-stuffing on auth routes.
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 20, // per IP per window
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: "Too many authentication attempts. Please try again later.",
  },
});

// Routes
app.use("/api/auth", authLimiter, authRoutes);
app.use("/api/products", productRoutes);
app.use("/api/manufacturing-orders", manufacturingRoutes);
app.use("/api/events", eventRoutes);
app.use("/api/inventory", inventoryRoutes);
app.use("/api/users", usersRoutes);
app.use("/api/roles", rolesRoutes);
app.use("/api/permissions", permissionsRoutes);
app.use("/api/dashboard", dashboardRoutes);

// Health check endpoint
app.get("/api/health", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Server is running",
  });
});

// Error handling middleware
app.use((err: any, req: express.Request, res: express.Response, _next: express.NextFunction) => {
  console.error(`[Error] ${req.method} ${req.path}:`, err);

  const statusCode = typeof err.statusCode === "number" ? err.statusCode : 500;
  const message = err.message && statusCode < 500
    ? err.message
    : env.isProduction
    ? "Internal server error"
    : err.message || "Internal server error";

  res.status(statusCode).json({
    success: false,
    message,
    ...(env.isProduction ? {} : { stack: err.stack }),
  });
});

export default app;
