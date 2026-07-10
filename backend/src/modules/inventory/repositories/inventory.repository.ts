import pool from "../../../config/db";
import { InventoryItem } from "../interfaces/inventory.interface";

export const findAll = async (): Promise<InventoryItem[]> => {
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
  const keys = Object.keys(itemData);
  if (keys.length === 0) return null;

  const setClause = keys
    .map((key, index) => `"${key}" = $${index + 2}`)
    .join(", ");
  const values = keys.map((key) => (itemData as any)[key]);

  const query = `UPDATE inventory SET ${setClause} WHERE id = $1 RETURNING *`;
  const result = await pool.query(query, [id, ...values]);

  return result.rows[0] || null;
};

export const deleteItem = async (id: number): Promise<boolean> => {
  const result = await pool.query("DELETE FROM inventory WHERE id = $1", [id]);
  return (result.rowCount ?? 0) > 0;
};
