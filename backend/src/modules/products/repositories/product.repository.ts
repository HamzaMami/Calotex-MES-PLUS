import pool from "../../../config/db";
import { Product } from "../interfaces/product.interface";

const ALLOWED_PRODUCT_COLUMNS = new Set([
  "name",
  "product_code",
  "assembly_pdf",
  "product_photo",
  "client_name",
  "category",
  "lead_engineer_id",
  "technical_milestone",
  "validation_status",
  "final_approval",
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
): Promise<Product[] | PaginatedResult<Product>> => {
  if (page && limit) {
    const offset = (page - 1) * limit;
    const countResult = await pool.query("SELECT COUNT(*) FROM products");
    const total = parseInt(countResult.rows[0].count, 10);

    const dataResult = await pool.query(
      "SELECT * FROM products ORDER BY created_at DESC LIMIT $1 OFFSET $2",
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
    product_code,
    name,
    assembly_pdf,
    product_photo,
    client_name,
    category,
    lead_engineer_id,
    technical_milestone,
    validation_status,
    final_approval,
  } = productData;
  const result = await pool.query(
    `INSERT INTO products (product_code, name, assembly_pdf, product_photo, client_name, category, lead_engineer_id, technical_milestone, validation_status, final_approval)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING *`,
    [
      product_code,
      name,
      assembly_pdf,
      product_photo,
      client_name,
      category,
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
  const entries = Object.entries(productData).filter(([key]) =>
    ALLOWED_PRODUCT_COLUMNS.has(key)
  );
  if (entries.length === 0) return null;

  const setClause = entries
    .map(([key], index) => `"${key}" = $${index + 2}`)
    .join(", ");
  const values = entries.map(([, value]) => value);

  const query = `UPDATE products SET ${setClause}, updated_at = NOW() WHERE id = $1 RETURNING *`;
  const result = await pool.query(query, [id, ...values]);

  return result.rows[0] || null;
};

export const deleteProduct = async (id: number): Promise<boolean> => {
  const result = await pool.query("DELETE FROM products WHERE id = $1", [id]);
  return (result.rowCount ?? 0) > 0;
};
