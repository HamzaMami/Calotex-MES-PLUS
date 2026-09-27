import pool from "../../../config/db";
import { InventoryItem } from "../interfaces/inventory.interface";

const ALLOWED_INVENTORY_COLUMNS = new Set([
  "item_name",
  "sku",
  "quantity",
  "unit",
  "location",
  "last_restocked",
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
): Promise<InventoryItem[] | PaginatedResult<InventoryItem>> => {
  if (page && limit) {
    const offset = (page - 1) * limit;
    const countResult = await pool.query("SELECT COUNT(*) FROM inventory");
    const total = parseInt(countResult.rows[0].count, 10);

    const dataResult = await pool.query(
      "SELECT * FROM inventory ORDER BY created_at DESC LIMIT $1 OFFSET $2",
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
    "SELECT * FROM inventory ORDER BY created_at DESC"
  );
  return result.rows;
};

export const findById = async (id: number): Promise<InventoryItem | null> => {
  const result = await pool.query("SELECT * FROM inventory WHERE id = $1", [id]);
  return result.rows[0] || null;
};

export const create = async (
  itemData: Omit<InventoryItem, "id" | "created_at" | "updated_at">
): Promise<InventoryItem> => {
  const { item_name, sku, quantity, unit, location, last_restocked } = itemData;
  const result = await pool.query(
    `INSERT INTO inventory (item_name, sku, quantity, unit, location, last_restocked)
     VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
    [item_name, sku, quantity || 0, unit || "pcs", location, last_restocked]
  );
  return result.rows[0];
};

export const update = async (
  id: number,
  itemData: Partial<InventoryItem>
): Promise<InventoryItem | null> => {
  const entries = Object.entries(itemData).filter(([key]) =>
    ALLOWED_INVENTORY_COLUMNS.has(key)
  );
  if (entries.length === 0) return null;

  const setClause = entries
    .map(([key], index) => `"${key}" = $${index + 2}`)
    .join(", ");
  const values = entries.map(([, value]) => value);

  const query = `UPDATE inventory SET ${setClause}, updated_at = NOW() WHERE id = $1 RETURNING *`;
  const result = await pool.query(query, [id, ...values]);

  return result.rows[0] || null;
};

export const deleteItem = async (id: number): Promise<boolean> => {
  const result = await pool.query("DELETE FROM inventory WHERE id = $1", [id]);
  return (result.rowCount ?? 0) > 0;
};
