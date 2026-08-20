import { Router } from "express";
import * as rolesController from "../controllers/roles.controller";
import { authenticate, validateRequest } from "../../auth/middleware/auth.midlleware";
import { authorize } from "../../auth/middleware/role.middleware";
import {
  createRoleSchemaJoi,
  updateRoleSchemaJoi,
  setPermissionsSchemaJoi,
} from "../dto/roles.dto";

const router = Router();

router.use(authenticate);
router.use(authorize("admin"));

router.get("/", rolesController.getAllRoles);
router.post("/", validateRequest(createRoleSchemaJoi), rolesController.createRole);
router.get("/:id", rolesController.getRoleById);
router.patch("/:id", validateRequest(updateRoleSchemaJoi), rolesController.updateRole);
router.delete("/:id", rolesController.deleteRole);
router.put(
  "/:id/permissions",
  validateRequest(setPermissionsSchemaJoi),
  rolesController.setRolePermissions
);

export default router;
