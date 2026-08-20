import { Request, Response } from "express";
import * as usersService from "../services/users.service";
import { authenticate, validateRequest } from "../../auth/middleware/auth.midlleware";
import { authorize } from "../../auth/middleware/role.middleware";
import {
  createUserSchemaJoi,
  updateUserSchemaJoi,
  setStatusSchemaJoi,
} from "../dto/users.dto";

export const getAllUsers = async (req: Request, res: Response) => {
  try {
    const users = await usersService.getAllUsers();
    res.status(200).json({ success: true, data: users });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getUserById = async (req: Request, res: Response) => {
  try {
    const id = parseInt(req.params.id as string, 10);
    const user = await usersService.getUserById(id);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }
    res.status(200).json({ success: true, data: user });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const createUser = async (req: Request, res: Response) => {
  try {
    const { name, email, role_id } = req.body;
    const baseUrl = `${req.protocol}://${req.get("host")}/api/auth`;
    const user = await usersService.createUser(name, email, role_id, baseUrl);
    res.status(201).json({
      success: true,
      message: "User created. Registration email sent.",
      data: user,
    });
  } catch (error: any) {
    res.status(400).json({ success: false, message: error.message });
  }
};

export const updateUser = async (req: Request, res: Response) => {
  try {
    const id = parseInt(req.params.id as string, 10);
    const user = await usersService.updateUser(id, req.body);
    res.status(200).json({ success: true, message: "User updated", data: user });
  } catch (error: any) {
    const status = error.message === "User not found" ? 404 : 400;
    res.status(status).json({ success: false, message: error.message });
  }
};

export const setUserStatus = async (req: Request, res: Response) => {
  try {
    const id = parseInt(req.params.id as string, 10);
    const { status } = req.body;
    await usersService.setUserStatus(id, status);
    res.status(200).json({ success: true, message: "User status updated" });
  } catch (error: any) {
    const status = error.message === "User not found" ? 404 : 400;
    res.status(status).json({ success: false, message: error.message });
  }
};

export const deleteUser = async (req: Request, res: Response) => {
  try {
    const id = parseInt(req.params.id as string, 10);
    await usersService.deleteUser(id);
    res.status(200).json({ success: true, message: "User deleted" });
  } catch (error: any) {
    const status = error.message === "User not found" ? 404 : 400;
    res.status(status).json({ success: false, message: error.message });
  }
};

export { authenticate, authorize, validateRequest };
