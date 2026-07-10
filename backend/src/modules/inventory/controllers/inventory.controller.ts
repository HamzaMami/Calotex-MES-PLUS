import { Request, Response } from "express";
import * as inventoryService from "../services/inventory.service";

export const getAllItems = async (req: Request, res: Response) => {
  try {
    const items = await inventoryService.getAllItems();
    res.status(200).json({ status: "success", data: items });
  } catch (error: any) {
    res.status(500).json({ status: "error", message: error.message });
  }
};

export const getItemById = async (req: Request, res: Response) => {
  try {
    const id = parseInt(req.params.id as string, 10);
    const item = await inventoryService.getItemById(id);
    if (!item) {
      return res.status(404).json({ status: "error", message: "Inventory item not found" });
    }
    res.status(200).json({ status: "success", data: item });
  } catch (error: any) {
    res.status(500).json({ status: "error", message: error.message });
  }
};

export const createItem = async (req: Request, res: Response) => {
  try {
    const item = await inventoryService.createItem(req.body);
    res.status(201).json({ status: "success", data: item });
  } catch (error: any) {
    res.status(500).json({ status: "error", message: error.message });
  }
};

export const updateItem = async (req: Request, res: Response) => {
  try {
    const id = parseInt(req.params.id as string, 10);
    const item = await inventoryService.updateItem(id, req.body);
    if (!item) {
      return res.status(404).json({ status: "error", message: "Inventory item not found" });
    }
    res.status(200).json({ status: "success", data: item });
  } catch (error: any) {
    res.status(500).json({ status: "error", message: error.message });
  }
};

export const deleteItem = async (req: Request, res: Response) => {
  try {
    const id = parseInt(req.params.id as string, 10);
    const success = await inventoryService.deleteItem(id);
    if (!success) {
      return res.status(404).json({ status: "error", message: "Inventory item not found" });
    }
    res.status(200).json({ status: "success", message: "Inventory item deleted successfully" });
  } catch (error: any) {
    res.status(500).json({ status: "error", message: error.message });
  }
};
