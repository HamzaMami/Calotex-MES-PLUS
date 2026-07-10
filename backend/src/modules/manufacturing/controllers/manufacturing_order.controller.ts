import { Request, Response } from "express";
import * as orderService from "../services/manufacturing_order.service";

export const getAllOrders = async (req: Request, res: Response) => {
  try {
    const orders = await orderService.getAllOrders();
    res.status(200).json({ status: "success", data: orders });
  } catch (error: any) {
    res.status(500).json({ status: "error", message: error.message });
  }
};

export const getOrderById = async (req: Request, res: Response) => {
  try {
    const id = parseInt(req.params.id as string, 10);
    const order = await orderService.getOrderById(id);
    if (!order) {
      return res.status(404).json({ status: "error", message: "Manufacturing order not found" });
    }
    res.status(200).json({ status: "success", data: order });
  } catch (error: any) {
    res.status(500).json({ status: "error", message: error.message });
  }
};

export const createOrder = async (req: Request, res: Response) => {
  try {
    const order = await orderService.createOrder(req.body);
    res.status(201).json({ status: "success", data: order });
  } catch (error: any) {
    res.status(500).json({ status: "error", message: error.message });
  }
};

export const updateOrder = async (req: Request, res: Response) => {
  try {
    const id = parseInt(req.params.id as string, 10);
    const order = await orderService.updateOrder(id, req.body);
    if (!order) {
      return res.status(404).json({ status: "error", message: "Manufacturing order not found" });
    }
    res.status(200).json({ status: "success", data: order });
  } catch (error: any) {
    res.status(500).json({ status: "error", message: error.message });
  }
};

export const deleteOrder = async (req: Request, res: Response) => {
  try {
    const id = parseInt(req.params.id as string, 10);
    const success = await orderService.deleteOrder(id);
    if (!success) {
      return res.status(404).json({ status: "error", message: "Manufacturing order not found" });
    }
    res.status(200).json({ status: "success", message: "Manufacturing order deleted successfully" });
  } catch (error: any) {
    res.status(500).json({ status: "error", message: error.message });
  }
};
