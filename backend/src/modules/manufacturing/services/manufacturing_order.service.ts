import * as orderRepository from "../repositories/manufacturing_order.repository";
import { ManufacturingOrder } from "../interfaces/manufacturing_order.interface";

export const getAllOrders = async (page?: number, limit?: number) => {
  return await orderRepository.findAll(page, limit);
};

export const getOrderById = async (id: number): Promise<ManufacturingOrder | null> => {
  return await orderRepository.findById(id);
};

export const createOrder = async (
  orderData: Omit<ManufacturingOrder, "id" | "created_at" | "updated_at">
): Promise<ManufacturingOrder> => {
  return await orderRepository.create(orderData);
};

export const updateOrder = async (
  id: number,
  orderData: Partial<ManufacturingOrder>
): Promise<ManufacturingOrder | null> => {
  return await orderRepository.update(id, orderData);
};

export const deleteOrder = async (id: number): Promise<boolean> => {
  return await orderRepository.deleteOrder(id);
};
