import express from "express";
import cors from "cors";
import authRoutes from "./modules/auth/routes/auth.routes";
import productRoutes from "./modules/products/routes/product.routes";
import manufacturingRoutes from "./modules/manufacturing/routes/manufacturing_order.routes";
import eventRoutes from "./modules/events/routes/event.routes";
import inventoryRoutes from "./modules/inventory/routes/inventory.routes";

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use("/api/auth", authRoutes);
app.use("/api/products", productRoutes);
app.use("/api/manufacturing-orders", manufacturingRoutes);
app.use("/api/events", eventRoutes);
app.use("/api/inventory", inventoryRoutes);

// Health check endpoint
app.get("/api/health", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Server is running",
  });
});

// Error handling middleware
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: "Internal server error",
  });
});

export default app;
