import { Router } from "express";
import * as permissionsController from "../controllers/permissions.controller";
import { authenticate, validateRequest } from "../../auth/middleware/auth.midlleware";
import { authorize } from "../../auth/middleware/role.middleware";
import { createPermissionSchemaJoi } from "../dto/permissions.dto";

const router = Router();

router.use(authenticate);
router.use(authorize("admin"));

router.get("/", permissionsController.getAllPermissions);
router.post(
  "/",
  validateRequest(createPermissionSchemaJoi),
  permissionsController.createPermission
);

export default router;
