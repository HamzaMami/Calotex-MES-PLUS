import { Request, Response } from "express";
import * as permissionsService from "../services/permissions.service";
import { authenticate, validateRequest } from "../../auth/middleware/auth.midlleware";
import { authorize } from "../../auth/middleware/role.middleware";
import { createPermissionSchemaJoi } from "../dto/permissions.dto";

export const getAllPermissions = async (req: Request, res: Response) => {
  try {
    const permissions = await permissionsService.getAllPermissions();
    res.status(200).json({ success: true, data: permissions });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const createPermission = async (req: Request, res: Response) => {
  try {
    const { name, description } = req.body;
    const permission = await permissionsService.createPermission(name, description ?? null);
    res.status(201).json({ success: true, message: "Permission created", data: permission });
  } catch (error: any) {
    res.status(400).json({ success: false, message: error.message });
  }
};
