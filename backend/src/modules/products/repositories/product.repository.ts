import pool from "../../../config/db";
import { Product } from "../interfaces/product.interface";

export const findAll = async (): Promise<Product[]> => {
  const result = await pool.query(
    "SELECT * FROM products ORDER BY created_at DESC"
  );
  return result.rows;
};

export const findById = async (id: number): Promise<Product | null> => {
  const result = await pool.query("SELECT * FROM products WHERE id = $1", [id]);
  return result.rows[0] || null;
};

export const create = async (
  productData: Omit<Product, "id" | "created_at" | "updated_at">
): Promise<Product> => {
  const {
    name,
    lead_engineer_id,
    technical_milestone,
    validation_status,
    final_approval,
  } = productData;
  const result = await pool.query(
    `INSERT INTO products (name, lead_engineer_id, technical_milestone, validation_status, final_approval)
     VALUES ($1, $2, $3, $4, $5) RETURNING *`,
    [
      name,
      lead_engineer_id,
      technical_milestone,
      validation_status,
      final_approval || false,
    ]
  );
  return result.rows[0];
};

export const update = async (
  id: number,
  productData: Partial<Product>
): Promise<Product | null> => {
  const keys = Object.keys(productData);
  if (keys.length === 0) return null;

  const setClause = keys
    .map((key, index) => `"${key}" = $${index + 2}`)
    .join(", ");
  const values = keys.map((key) => (productData as any)[key]);

  const query = `UPDATE products SET ${setClause} WHERE id = $1 RETURNING *`;
  const result = await pool.query(query, [id, ...values]);

  return result.rows[0] || null;
};

export const deleteProduct = async (id: number): Promise<boolean> => {
  const result = await pool.query("DELETE FROM products WHERE id = $1", [id]);
  return (result.rowCount ?? 0) > 0;
};
