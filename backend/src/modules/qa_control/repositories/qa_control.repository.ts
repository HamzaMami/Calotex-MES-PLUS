import pool from "../../../config/db";
import { QaControl, QaWeeklyProduct } from "../interfaces/qa_control.interface";

export const findWeeklyProducts = async (
  year: number,
  week: number,
): Promise<QaWeeklyProduct[]> => {
  const januaryFourth = new Date(Date.UTC(year, 0, 4));
  const mondayOffset = januaryFourth.getUTCDay() === 0
    ? -6
    : 1 - januaryFourth.getUTCDay();
  const weekStart = new Date(januaryFourth);
  weekStart.setUTCDate(januaryFourth.getUTCDate() + mondayOffset + (week - 1) * 7);
  const weekEnd = new Date(weekStart);
  weekEnd.setUTCDate(weekStart.getUTCDate() + 7);

  const result = await pool.query(
    `WITH weekly_products AS (
       SELECT product_code, MIN(order_number) AS order_number,
              SUM(quantity)::int AS quantity
         FROM export_plans
        WHERE year = $1 AND calendar_week_kw = $2
        GROUP BY product_code
       UNION ALL
       SELECT COALESCE(p.product_code, p.name) AS product_code, MIN(mo.id::text) AS order_number,
              SUM(mo.target_quantity)::int AS quantity
         FROM manufacturing_orders mo
         JOIN products p ON p.id = mo.product_id
        WHERE (
          (mo.start_date IS NOT NULL AND mo.start_date < $4 AND
           (mo.end_date IS NULL OR mo.end_date >= $3))
          OR (mo.start_date IS NULL AND mo.end_date IS NOT NULL AND
              mo.end_date >= $3 AND mo.end_date < $4)
        )
        GROUP BY COALESCE(p.product_code, p.name)
     ),
     grouped_products AS (
       SELECT product_code, MIN(order_number) AS order_number,
              SUM(quantity)::int AS quantity
         FROM weekly_products
        GROUP BY product_code
     )
    SELECT gp.product_code, gp.order_number, gp.quantity,
           COALESCE(json_agg(qc ORDER BY qc.created_at)
             FILTER (WHERE qc.id IS NOT NULL), '[]') AS controls
      FROM grouped_products gp
       LEFT JOIN qa_controls qc
        ON qc.product_code = gp.product_code
       AND qc.year = $1
       AND qc.calendar_week_kw = $2
     GROUP BY gp.product_code, gp.order_number, gp.quantity
     ORDER BY gp.product_code`,
    [year, week, weekStart, weekEnd],
  );
  return result.rows;
};

export const create = async (
  data: Omit<QaControl, "id" | "created_at" | "created_by">,
  createdBy: number | null,
): Promise<QaControl> => {
  // Ensure control IDs have safe fallback defaults
  const firstControlId = data.first_control_id || '1';
  const lastControlId = data.last_control_id || '';

  // If last serial number is omitted or empty, default to first serial number (1 single item)
  if (!data.last_serial_number || data.last_serial_number.trim() === '') {
    data.last_serial_number = data.first_serial_number;
  }

  // 1. Fetch planned quantity for this product in this year/week to validate fencepost range
  const products = await findWeeklyProducts(data.year, data.calendar_week_kw);
  const product = products.find((p) => p.product_code === data.product_code);

  if (product && product.quantity > 0) {
    const firstMatch = data.first_serial_number.match(/\d+/);
    if (firstMatch) {
      const startId = parseInt(firstMatch[0], 10);
      const plannedQty = product.quantity;
      const maxEndId = (startId + plannedQty) - 1;

      if (data.last_serial_number) {
        const lastMatch = data.last_serial_number.match(/\d+/);
        if (lastMatch) {
          const endId = parseInt(lastMatch[0], 10);
          if (endId > maxEndId) {
            throw new Error(
              `Serial range upper bound (${endId}) exceeds planned quantity limit (${maxEndId}). Correct formula: (Start ID + Planned Quantity) - 1.`
            );
          }
        }
      }
    }
  }

  const result = await pool.query(
    `INSERT INTO qa_controls
      (product_code, year, calendar_week_kw, first_control_id, last_control_id,
       first_serial_number, last_serial_number, created_by)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
     RETURNING *`,
    [
      data.product_code, data.year, data.calendar_week_kw,
      firstControlId, lastControlId,
      data.first_serial_number, data.last_serial_number, createdBy,
    ],
  );

  const createdControl = result.rows[0];

  // 2. Automatically update production order & export plan status and quantities on QA Control pass
  try {
    const updatedProducts = await findWeeklyProducts(data.year, data.calendar_week_kw);
    const currentProduct = updatedProducts.find((p) => p.product_code === data.product_code);
    if (currentProduct) {
      let totalInspected = 0;
      for (const c of currentProduct.controls) {
        const fMatch = c.first_serial_number.match(/\d+/);
        const lMatch = c.last_serial_number ? c.last_serial_number.match(/\d+/) : fMatch;
        if (fMatch && lMatch) {
          const start = parseInt(fMatch[0], 10);
          const end = parseInt(lMatch[0], 10);
          totalInspected += (end >= start) ? (end - start + 1) : 1;
        } else {
          totalInspected += 1;
        }
      }

      // Update good_quantity and qa_quantity on matching manufacturing orders
      await pool.query(
        `UPDATE manufacturing_orders mo
            SET good_quantity = GREATEST(mo.good_quantity, $2),
                qa_quantity = GREATEST(mo.qa_quantity, $2),
                status = CASE WHEN $2 >= mo.target_quantity THEN 'completed' ELSE 'in_production' END,
                updated_at = NOW()
           FROM products p
          WHERE mo.product_id = p.id
            AND (p.product_code = $1 OR p.name = $1 OR mo.id::text = $1)`,
        [data.product_code, totalInspected]
      );

      // Update export plans
      await pool.query(
        `UPDATE export_plans
            SET status = CASE WHEN $3 >= quantity THEN 'completed' ELSE 'in_production' END,
                updated_at = NOW()
          WHERE (product_code = $1 OR order_number = $1)
            AND year = $2 AND calendar_week_kw = $4`,
        [data.product_code, data.year, totalInspected, data.calendar_week_kw]
      );
    }
  } catch (err) {
    // eslint-disable-next-line no-console
    console.error("[qa_control] Failed to auto-update order status on pass:", err);
  }

  return createdControl;
};
