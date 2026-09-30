import { Request, Response } from "express";
import * as productService from "../../products/services/product.service";
import * as orderService from "../../manufacturing/services/manufacturing_order.service";
import * as eventService from "../../events/services/event.service";
import pool from "../../../config/db";

export const getDashboardData = async (req: Request, res: Response) => {
  try {
    // Fetch all three data sources concurrently for better performance.
    const [products, manufacturingOrders, events, exportPlans, productivityRecords] = await Promise.all([
      productService.getAllProducts(),
      orderService.getAllOrders(),
      eventService.getAllEvents(),
      pool.query(
        `SELECT id, calendar_week_kw, year, order_number, product_code,
                quantity, destination, status, created_by, created_at, updated_at
           FROM export_plans
          ORDER BY order_number NULLS LAST, year, calendar_week_kw, product_code, id`,
      ).then((result) => result.rows),
      pool.query(
        `SELECT calendar_week_kw, year, productivity_percentage
           FROM productivity_records
          ORDER BY year, calendar_week_kw`,
      ).then((result) => result.rows),
    ]);

    res.status(200).json({
      status: "success",
      data: {
        products,
        manufacturing_orders: manufacturingOrders,
        events,
        export_plans: exportPlans,
        productivity_records: productivityRecords,
      },
    });
  } catch (error: any) {
    res.status(500).json({ status: "error", message: error.message });
  }
};
