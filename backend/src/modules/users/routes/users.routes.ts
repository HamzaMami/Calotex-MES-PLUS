import { Router } from "express";
import * as usersController from "../controllers/users.controller";
import { authenticate, validateRequest } from "../../auth/middleware/auth.midlleware";
import { authorize } from "../../auth/middleware/role.middleware";
import {
  createUserSchemaJoi,
  updateUserSchemaJoi,
  setStatusSchemaJoi,
} from "../dto/users.dto";

const router = Router();

// All user management is admin-only.
router.use(authenticate);
router.use(authorize("admin"));

router.get("/", usersController.getAllUsers);
router.post("/", validateRequest(createUserSchemaJoi), usersController.createUser);
router.get("/:id", usersController.getUserById);
router.patch("/:id", validateRequest(updateUserSchemaJoi), usersController.updateUser);
router.patch(
  "/:id/status",
  validateRequest(setStatusSchemaJoi),
  usersController.setUserStatus
);
router.delete("/:id", usersController.deleteUser);

export default router;
