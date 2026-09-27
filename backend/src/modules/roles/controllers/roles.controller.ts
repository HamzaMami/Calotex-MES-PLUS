import { Request, Response } from "express";
import * as rolesService from "../services/roles.service";
import { authenticate, validateRequest } from "../../auth/middleware/auth.midlleware";
import { authorize } from "../../auth/middleware/role.middleware";
import { asyncHandler } from "../../../shared/utils/asyncHandler";

export const getAllRoles = asyncHandler(async (req: Request, res: Response) => {
  const roles = await rolesService.getAllRoles();
  res.status(200).json({ success: true, data: roles });
});

export const getRoleById = asyncHandler(async (req: Request, res: Response) => {
  const id = parseInt(req.params.id as string, 10);
  const data = await rolesService.getRoleWithPermissions(id);
  if (!data) {
    return res.status(404).json({ success: false, message: "Role not found" });
  }
  res.status(200).json({ success: true, data });
});

export const createRole = asyncHandler(async (req: Request, res: Response) => {
  const { name, description } = req.body;
  const role = await rolesService.createRole(name, description ?? null);
  res.status(201).json({ success: true, message: "Role created", data: role });
});

export const updateRole = asyncHandler(async (req: Request, res: Response) => {
  const id = parseInt(req.params.id as string, 10);
  const role = await rolesService.updateRole(id, req.body);
  res.status(200).json({ success: true, message: "Role updated", data: role });
});

export const deleteRole = asyncHandler(async (req: Request, res: Response) => {
  const id = parseInt(req.params.id as string, 10);
  await rolesService.deleteRole(id);
  res.status(200).json({ success: true, message: "Role deleted" });
});

export const setRolePermissions = asyncHandler(async (req: Request, res: Response) => {
  const id = parseInt(req.params.id as string, 10);
  const { permission_ids } = req.body;
  await rolesService.setRolePermissions(id, permission_ids);
  res.status(200).json({ success: true, message: "Role permissions updated" });
});

export { authenticate, authorize, validateRequest };
