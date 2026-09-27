import { Request, Response } from "express";
import * as permissionsService from "../services/permissions.service";
import { authenticate, validateRequest } from "../../auth/middleware/auth.midlleware";
import { authorize } from "../../auth/middleware/role.middleware";
import { asyncHandler } from "../../../shared/utils/asyncHandler";

export const getAllPermissions = asyncHandler(async (req: Request, res: Response) => {
  const permissions = await permissionsService.getAllPermissions();
  res.status(200).json({ success: true, data: permissions });
});

export const createPermission = asyncHandler(async (req: Request, res: Response) => {
  const { name, description } = req.body;
  const permission = await permissionsService.createPermission(name, description ?? null);
  res.status(201).json({ success: true, message: "Permission created", data: permission });
});

export { authenticate, authorize, validateRequest };
