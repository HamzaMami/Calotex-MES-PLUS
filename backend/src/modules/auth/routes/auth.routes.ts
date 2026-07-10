import { Router } from "express";
import * as authController from "../controllers/auth.controller";
import { authenticate, validateRequest, validateWithZod } from "../middleware/auth.midlleware";
import { authorize } from "../middleware/role.middleware";
import {
  completeRegistrationSchemaZod,
  createUserByAdminSchemaJoi,
  loginSchemaJoi,
  registerSchemaJoi,
} from "../dto/validation.schemas";

const router = Router();

// Public routes
router.post("/login", validateRequest(loginSchemaJoi), authController.login);
router.post("/register", validateRequest(registerSchemaJoi), authController.register);
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

// Protected routes example (uncomment when needed)
// router.get("/profile", authenticate, authController.getProfile);
// router.post("/logout", authenticate, authController.logout);

export default router;
