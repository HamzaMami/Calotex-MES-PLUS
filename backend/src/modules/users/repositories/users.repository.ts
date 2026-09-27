import pool from "../../../config/db";
import { UserWithRole } from "../interfaces/users.interface";

const ALLOWED_USER_COLUMNS = new Set(["name", "role_id", "status"]);

export interface PaginatedResult<T> {
  items: T[];
  total: number;
  page: number;
  limit: number;
}

export const findAll = async (
  page?: number,
  limit?: number
): Promise<UserWithRole[] | PaginatedResult<UserWithRole>> => {
  if (page && limit) {
    const offset = (page - 1) * limit;
    const countResult = await pool.query("SELECT COUNT(*) FROM users");
    const total = parseInt(countResult.rows[0].count, 10);

    const dataResult = await pool.query(
      `SELECT u.id, u.name, u.email, u.status, u.role_id, u.created_at, u.updated_at,
              r.name AS role_name
       FROM users u
       LEFT JOIN roles r ON r.id = u.role_id
       ORDER BY u.created_at DESC
       LIMIT $1 OFFSET $2`,
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
    `SELECT u.id, u.name, u.email, u.status, u.role_id, u.created_at, u.updated_at,
            r.name AS role_name
     FROM users u
     LEFT JOIN roles r ON r.id = u.role_id
     ORDER BY u.created_at DESC`
  );
  return result.rows;
};

export const findById = async (id: number): Promise<UserWithRole | null> => {
  const result = await pool.query(
    `SELECT u.id, u.name, u.email, u.status, u.role_id, u.created_at, u.updated_at,
            r.name AS role_name
     FROM users u
     LEFT JOIN roles r ON r.id = u.role_id
     WHERE u.id = $1`,
    [id]
  );
  return result.rows[0] || null;
};

export const findByEmail = async (email: string): Promise<UserWithRole | null> => {
  const result = await pool.query(
    `SELECT u.id, u.name, u.email, u.status, u.role_id, u.created_at, u.updated_at,
            r.name AS role_name
     FROM users u
     LEFT JOIN roles r ON r.id = u.role_id
     WHERE u.email = $1`,
    [email]
  );
  return result.rows[0] || null;
};

export const updateUser = async (
  id: number,
  fields: { name?: string; role_id?: number | null; status?: string }
): Promise<UserWithRole | null> => {
  const entries = Object.entries(fields).filter(([key]) =>
    ALLOWED_USER_COLUMNS.has(key)
  );
  if (entries.length === 0) return null;

  const setClause = entries.map(([k], i) => `"${k}" = $${i + 2}`).join(", ");
  const values = entries.map(([, v]) => v);

  const result = await pool.query(
    `UPDATE users SET ${setClause}, updated_at = NOW() WHERE id = $1 RETURNING id`,
    [id, ...values]
  );
  if (result.rowCount === 0) return null;
  return findById(id);
};

export const setStatus = async (id: number, status: string): Promise<boolean> => {
  const result = await pool.query(
    "UPDATE users SET status = $2, updated_at = NOW() WHERE id = $1 RETURNING id",
    [id, status]
  );
  return (result.rowCount ?? 0) > 0;
};

export const remove = async (id: number): Promise<boolean> => {
  const result = await pool.query(
    "DELETE FROM users WHERE id = $1 RETURNING id",
    [id]
  );
  return (result.rowCount ?? 0) > 0;
};
