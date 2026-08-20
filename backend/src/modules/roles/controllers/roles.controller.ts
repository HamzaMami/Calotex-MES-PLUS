import { Request, Response } from "express";
import * as rolesService from "../services/roles.service";
import { authenticate, validateRequest } from "../../auth/middleware/auth.midlleware";
import { authorize } from "../../auth/middleware/role.middleware";
import {
  createRoleSchemaJoi,
  updateRoleSchemaJoi,
  setPermissionsSchemaJoi,
} from "../dto/roles.dto";

export const getAllRoles = async (req: Request, res: Response) => {
  try {
    const roles = await rolesService.getAllRoles();
    res.status(200).json({ success: true, data: roles });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getRoleById = async (req: Request, res: Response) => {
  try {
    const id = parseInt(req.params.id as string, 10);
    const data = await rolesService.getRoleWithPermissions(id);
    if (!data) {
      return res.status(404).json({ success: false, message: "Role not found" });
    }
    res.status(200).json({ success: true, data });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const createRole = async (req: Request, res: Response) => {
  try {
    const { name, description } = req.body;
    const role = await rolesService.createRole(name, description ?? null);
    res.status(201).json({ success: true, message: "Role created", data: role });
  } catch (error: any) {
    res.status(400).json({ success: false, message: error.message });
  }
};

export const updateRole = async (req: Request, res: Response) => {
  try {
    const id = parseInt(req.params.id as string, 10);
    const role = await rolesService.updateRole(id, req.body);
    res.status(200).json({ success: true, message: "Role updated", data: role });
  } catch (error: any) {
    const status = error.message === "Role not found" ? 404 : 400;
    res.status(status).json({ success: false, message: error.message });
  }
};

export const deleteRole = async (req: Request, res: Response) => {
  try {
    const id = parseInt(req.params.id as string, 10);
    await rolesService.deleteRole(id);
    res.status(200).json({ success: true, message: "Role deleted" });
  } catch (error: any) {
    const status = error.message === "Role not found" ? 404 : 400;
    res.status(status).json({ success: false, message: error.message });
  }
};

export const setRolePermissions = async (req: Request, res: Response) => {
  try {
    const id = parseInt(req.params.id as string, 10);
    const { permission_ids } = req.body;
    await rolesService.setRolePermissions(id, permission_ids);
    res.status(200).json({ success: true, message: "Role permissions updated" });
  } catch (error: any) {
    const status =
      error.message === "Role not found" || error.message.includes("System")
        ? error.message.includes("System")
          ? 400
          : 404
        : 400;
    res.status(status).json({ success: false, message: error.message });
  }
};

export { authenticate, authorize, validateRequest };
