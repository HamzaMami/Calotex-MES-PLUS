import * as inventoryRepository from "../repositories/inventory.repository";
import { InventoryItem } from "../interfaces/inventory.interface";

export const getAllItems = async (page?: number, limit?: number) => {
  return await inventoryRepository.findAll(page, limit);
};

export const getItemById = async (id: number): Promise<InventoryItem | null> => {
  return await inventoryRepository.findById(id);
};

export const createItem = async (
  itemData: Omit<InventoryItem, "id" | "created_at" | "updated_at">
): Promise<InventoryItem> => {
  return await inventoryRepository.create(itemData);
};

export const updateItem = async (
  id: number,
  itemData: Partial<InventoryItem>
): Promise<InventoryItem | null> => {
  return await inventoryRepository.update(id, itemData);
};

export const deleteItem = async (id: number): Promise<boolean> => {
  return await inventoryRepository.deleteItem(id);
};
