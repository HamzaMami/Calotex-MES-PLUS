import { Request, Response } from "express";
import * as productService from "../../products/services/product.service";
import * as orderService from "../../manufacturing/services/manufacturing_order.service";
import * as eventService from "../../events/services/event.service";

export const getDashboardData = async (req: Request, res: Response) => {
  try {
    // Fetch all three data sources concurrently for better performance.
    const [products, manufacturingOrders, events] = await Promise.all([
      productService.getAllProducts(),
      orderService.getAllOrders(),
      eventService.getAllEvents(),
    ]);

    res.status(200).json({
      status: "success",
      data: {
        products,
        manufacturing_orders: manufacturingOrders,
        events,
      },
    });
  } catch (error: any) {
    res.status(500).json({ status: "error", message: error.message });
  }
};
