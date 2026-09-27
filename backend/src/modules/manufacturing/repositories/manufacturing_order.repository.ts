import pool from "../../../config/db";
import { ManufacturingOrder } from "../interfaces/manufacturing_order.interface";

const ALLOWED_MANUFACTURING_COLUMNS = new Set([
  "product_id",
  "status",
  "target_quantity",
  "good_quantity",
  "reject_quantity",
  "qa_quantity",
  "start_date",
  "end_date",
]);

export interface PaginatedResult<T> {
  items: T[];
  total: number;
  page: number;
  limit: number;
}

export const findAll = async (
  page?: number,
  limit?: number
): Promise<ManufacturingOrder[] | PaginatedResult<ManufacturingOrder>> => {
  if (page && limit) {
    const offset = (page - 1) * limit;
    const countResult = await pool.query(
      "SELECT COUNT(*) FROM manufacturing_orders"
    );
    const total = parseInt(countResult.rows[0].count, 10);

    const dataResult = await pool.query(
      "SELECT * FROM manufacturing_orders ORDER BY created_at DESC LIMIT $1 OFFSET $2",
      [limit, offset]
    );

    return {
      items: dataResult.rows,
      total,
      page,
      limit,
    };
  }

  const result = await pool.query(
    "SELECT * FROM manufacturing_orders ORDER BY created_at DESC"
  );
  return result.rows;
};

export const findById = async (
  id: number
): Promise<ManufacturingOrder | null> => {
  const result = await pool.query(
    "SELECT * FROM manufacturing_orders WHERE id = $1",
    [id]
  );
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
  const entries = Object.entries(orderData).filter(([key]) =>
    ALLOWED_MANUFACTURING_COLUMNS.has(key)
  );
  if (entries.length === 0) return null;

  const setClause = entries
    .map(([key], index) => `"${key}" = $${index + 2}`)
    .join(", ");
  const values = entries.map(([, value]) => value);

  const query = `UPDATE manufacturing_orders SET ${setClause}, updated_at = NOW() WHERE id = $1 RETURNING *`;
  const result = await pool.query(query, [id, ...values]);

  return result.rows[0] || null;
};

export const deleteOrder = async (id: number): Promise<boolean> => {
  const result = await pool.query(
    "DELETE FROM manufacturing_orders WHERE id = $1",
    [id]
  );
  return (result.rowCount ?? 0) > 0;
};
