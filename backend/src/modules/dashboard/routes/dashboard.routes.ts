import { Router } from "express";
import * as dashboardController from "../controllers/dashboard.controller";
import { authenticate } from "../../auth/middleware/auth.midlleware";

const router = Router();

// Apply authentication middleware to all dashboard routes.
router.use(authenticate);

// Single aggregated endpoint for the dashboard.
router.get("/", dashboardController.getDashboardData);

export default router;