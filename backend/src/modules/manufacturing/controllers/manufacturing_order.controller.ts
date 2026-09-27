import { Request, Response } from "express";
import * as orderService from "../services/manufacturing_order.service";
import { asyncHandler } from "../../../shared/utils/asyncHandler";

export const getAllOrders = asyncHandler(async (req: Request, res: Response) => {
  const page = req.query.page ? parseInt(req.query.page as string, 10) : undefined;
  const limit = req.query.limit ? parseInt(req.query.limit as string, 10) : undefined;

  const orders = await orderService.getAllOrders(page, limit);
  res.status(200).json({ status: "success", data: orders });
});

export const getOrderById = asyncHandler(async (req: Request, res: Response) => {
  const id = parseInt(req.params.id as string, 10);
  const order = await orderService.getOrderById(id);
  if (!order) {
    return res.status(404).json({ status: "error", message: "Manufacturing order not found" });
  }
  res.status(200).json({ status: "success", data: order });
});

export const createOrder = asyncHandler(async (req: Request, res: Response) => {
  const order = await orderService.createOrder(req.body);
  res.status(201).json({ status: "success", data: order });
});

export const updateOrder = asyncHandler(async (req: Request, res: Response) => {
  const id = parseInt(req.params.id as string, 10);
  const order = await orderService.updateOrder(id, req.body);
  if (!order) {
    return res.status(404).json({ status: "error", message: "Manufacturing order not found" });
  }
  res.status(200).json({ status: "success", data: order });
});

export const deleteOrder = asyncHandler(async (req: Request, res: Response) => {
  const id = parseInt(req.params.id as string, 10);
  const success = await orderService.deleteOrder(id);
  if (!success) {
    return res.status(404).json({ status: "error", message: "Manufacturing order not found" });
  }
  res.status(200).json({ status: "success", message: "Manufacturing order deleted successfully" });
});
