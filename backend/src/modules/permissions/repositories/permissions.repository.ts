import pool from "../../../config/db";
import { Permission } from "../interfaces/permissions.interface";

export const findAll = async (): Promise<Permission[]> => {
  const result = await pool.query(
    "SELECT * FROM permissions ORDER BY name ASC"
  );
  return result.rows;
};

export const findByName = async (name: string): Promise<Permission | null> => {
  const result = await pool.query("SELECT * FROM permissions WHERE name = $1", [name]);
  return result.rows[0] || null;
};

export const create = async (
  name: string,
  description: string | null
): Promise<Permission> => {
  const result = await pool.query(
    `INSERT INTO permissions (name, description)
     VALUES ($1, $2) RETURNING *`,
    [name, description]
  );
  return result.rows[0];
};
