import { Router } from "express";
import * as authController from "../controllers/auth.controller";
import { authenticate, validateRequest, validateWithZod } from "../middleware/auth.midlleware";
import { authorize } from "../middleware/role.middleware";
import {
  completeRegistrationSchemaZod,
  createUserByAdminSchemaJoi,
  loginSchemaJoi,
  registerSchemaJoi,
  refreshTokenSchemaJoi,
} from "../dto/validation.schemas";

const router = Router();

// Public routes
router.post("/login", validateRequest(loginSchemaJoi), authController.login);
router.post("/register", validateRequest(registerSchemaJoi), authController.register);
router.post("/refresh", validateRequest(refreshTokenSchemaJoi), authController.refreshToken);
router.post(
  "/complete-registration/:token",
  validateWithZod(completeRegistrationSchemaZod),
  authController.completeRegistration
);

// Admin protected routes
router.post(
  "/create-user",
  authenticate,
  authorize("admin"),
  validateRequest(createUserByAdminSchemaJoi),
  authController.createUserByAdmin
);

// Authenticated user routes
router.post("/logout", authenticate, authController.logout);

export default router;
