import pool from "../../../config/db";
import { ManufacturingOrder } from "../interfaces/manufacturing_order.interface";

export const findAll = async (): Promise<ManufacturingOrder[]> => {
  const result = await pool.query(
    "SELECT * FROM manufacturing_orders ORDER BY created_at DESC"
  );
  return result.rows;
};

export const findById = async (id: number): Promise<ManufacturingOrder | null> => {
  const result = await pool.query("SELECT * FROM manufacturing_orders WHERE id = $1", [id]);
  return result.rows[0] || null;
};

export const create = async (
  orderData: Omit<ManufacturingOrder, "id" | "created_at" | "updated_at">
): Promise<ManufacturingOrder> => {
  const {
    product_id,
    status,
    target_quantity,
    good_quantity,
    reject_quantity,
    qa_quantity,
    start_date,
    end_date,
  } = orderData;
  const result = await pool.query(
    `INSERT INTO manufacturing_orders 
      (product_id, status, target_quantity, good_quantity, reject_quantity, qa_quantity, start_date, end_date)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
    [
      product_id,
      status,
      target_quantity,
      good_quantity || 0,
      reject_quantity || 0,
      qa_quantity || 0,
      start_date || null,
      end_date || null,
    ]
  );
  return result.rows[0];
};

export const update = async (
  id: number,
  orderData: Partial<ManufacturingOrder>
): Promise<ManufacturingOrder | null> => {
  const keys = Object.keys(orderData);
  if (keys.length === 0) return null;

  const setClause = keys
    .map((key, index) => `"${key}" = $${index + 2}`)
    .join(", ");
  const values = keys.map((key) => (orderData as any)[key]);

  const query = `UPDATE manufacturing_orders SET ${setClause} WHERE id = $1 RETURNING *`;
  const result = await pool.query(query, [id, ...values]);

  return result.rows[0] || null;
};

export const deleteOrder = async (id: number): Promise<boolean> => {
  const result = await pool.query("DELETE FROM manufacturing_orders WHERE id = $1", [id]);
  return (result.rowCount ?? 0) > 0;
};
