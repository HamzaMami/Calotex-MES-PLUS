import { Request, Response } from "express";
import * as inventoryService from "../services/inventory.service";
import { asyncHandler } from "../../../shared/utils/asyncHandler";

export const getAllItems = asyncHandler(async (req: Request, res: Response) => {
  const page = req.query.page ? parseInt(req.query.page as string, 10) : undefined;
  const limit = req.query.limit ? parseInt(req.query.limit as string, 10) : undefined;

  const items = await inventoryService.getAllItems(page, limit);
  res.status(200).json({ status: "success", data: items });
});

export const getItemById = asyncHandler(async (req: Request, res: Response) => {
  const id = parseInt(req.params.id as string, 10);
  const item = await inventoryService.getItemById(id);
  if (!item) {
    return res.status(404).json({ status: "error", message: "Inventory item not found" });
  }
  res.status(200).json({ status: "success", data: item });
});

export const createItem = asyncHandler(async (req: Request, res: Response) => {
  const item = await inventoryService.createItem(req.body);
  res.status(201).json({ status: "success", data: item });
});

export const updateItem = asyncHandler(async (req: Request, res: Response) => {
  const id = parseInt(req.params.id as string, 10);
  const item = await inventoryService.updateItem(id, req.body);
  if (!item) {
    return res.status(404).json({ status: "error", message: "Inventory item not found" });
  }
  res.status(200).json({ status: "success", data: item });
});

export const deleteItem = asyncHandler(async (req: Request, res: Response) => {
  const id = parseInt(req.params.id as string, 10);
  const success = await inventoryService.deleteItem(id);
  if (!success) {
    return res.status(404).json({ status: "error", message: "Inventory item not found" });
  }
  res.status(200).json({ status: "success", message: "Inventory item deleted successfully" });
});
