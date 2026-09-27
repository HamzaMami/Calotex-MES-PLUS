import { Request, Response } from "express";
import * as usersService from "../services/users.service";
import { authenticate, validateRequest } from "../../auth/middleware/auth.midlleware";
import { authorize } from "../../auth/middleware/role.middleware";
import { asyncHandler } from "../../../shared/utils/asyncHandler";

export const getAllUsers = asyncHandler(async (req: Request, res: Response) => {
  const page = req.query.page ? parseInt(req.query.page as string, 10) : undefined;
  const limit = req.query.limit ? parseInt(req.query.limit as string, 10) : undefined;

  const users = await usersService.getAllUsers(page, limit);
  res.status(200).json({ success: true, data: users });
});

export const getUserById = asyncHandler(async (req: Request, res: Response) => {
  const id = parseInt(req.params.id as string, 10);
  const user = await usersService.getUserById(id);
  if (!user) {
    return res.status(404).json({ success: false, message: "User not found" });
  }
  res.status(200).json({ success: true, data: user });
});

export const createUser = asyncHandler(async (req: Request, res: Response) => {
  const { name, email, role_id } = req.body;
  const baseUrl = `${req.protocol}://${req.get("host")}/api/auth`;
  const user = await usersService.createUser(name, email, role_id, baseUrl);
  res.status(201).json({
    success: true,
    message: "User created. Registration email sent.",
    data: user,
  });
});

export const updateUser = asyncHandler(async (req: Request, res: Response) => {
  const id = parseInt(req.params.id as string, 10);
  const user = await usersService.updateUser(id, req.body);
  res.status(200).json({ success: true, message: "User updated", data: user });
});

export const setUserStatus = asyncHandler(async (req: Request, res: Response) => {
  const id = parseInt(req.params.id as string, 10);
  const { status } = req.body;
  await usersService.setUserStatus(id, status);
  res.status(200).json({ success: true, message: "User status updated" });
});

export const deleteUser = asyncHandler(async (req: Request, res: Response) => {
  const id = parseInt(req.params.id as string, 10);
  await usersService.deleteUser(id);
  res.status(200).json({ success: true, message: "User deleted" });
});

export { authenticate, authorize, validateRequest };
