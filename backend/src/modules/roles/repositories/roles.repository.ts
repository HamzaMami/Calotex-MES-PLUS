import pool from "../../../config/db";
import { Role, Permission } from "../../permissions/interfaces/permissions.interface";

const ALLOWED_ROLE_COLUMNS = new Set(["name", "description"]);

export const findAll = async (): Promise<Role[]> => {
  const query = `
    SELECT
      r.id,
      r.name,
      r.description,
      r.is_system,
      r.created_at,
      r.updated_at,
      COALESCE(
        json_agg(
          json_build_object('id', p.id, 'name', p.name, 'description', p.description)
        ) FILTER (WHERE p.id IS NOT NULL),
        '[]'
      ) AS permissions
    FROM roles r
    LEFT JOIN role_permissions rp ON rp.role_id = r.id
    LEFT JOIN permissions p ON p.id = rp.permission_id
    GROUP BY r.id
    ORDER BY r.id ASC
  `;

  const result = await pool.query(query);
  return result.rows;
};

export const findById = async (id: number): Promise<Role | null> => {
  const query = `
    SELECT
      r.id,
      r.name,
      r.description,
      r.is_system,
      r.created_at,
      r.updated_at,
      COALESCE(
        json_agg(
          json_build_object('id', p.id, 'name', p.name, 'description', p.description)
        ) FILTER (WHERE p.id IS NOT NULL),
        '[]'
      ) AS permissions
    FROM roles r
    LEFT JOIN role_permissions rp ON rp.role_id = r.id
    LEFT JOIN permissions p ON p.id = rp.permission_id
    WHERE r.id = $1
    GROUP BY r.id
  `;

  const result = await pool.query(query, [id]);
  return result.rows[0] || null;
};

export const findByName = async (name: string): Promise<Role | null> => {
  const result = await pool.query("SELECT * FROM roles WHERE name = $1", [name]);
  return result.rows[0] || null;
};

export const create = async (
  name: string,
  description: string | null
): Promise<Role> => {
  const result = await pool.query(
    `INSERT INTO roles (name, description)
     VALUES ($1, $2) RETURNING *`,
    [name, description]
  );
  return { ...result.rows[0], permissions: [] };
};

export const update = async (
  id: number,
  fields: { name?: string; description?: string }
): Promise<Role | null> => {
  const entries = Object.entries(fields).filter(([key]) =>
    ALLOWED_ROLE_COLUMNS.has(key)
  );
  if (entries.length === 0) return null;

  const setClause = entries.map(([k], i) => `"${k}" = $${i + 2}`).join(", ");
  const values = entries.map(([, v]) => v);

  const result = await pool.query(
    `UPDATE roles SET ${setClause}, updated_at = NOW() WHERE id = $1 RETURNING *`,
    [id, ...values]
  );
  if (result.rowCount === 0) return null;
  return findById(id);
};

export const remove = async (id: number): Promise<boolean> => {
  const result = await pool.query("DELETE FROM roles WHERE id = $1 RETURNING id", [id]);
  return (result.rowCount ?? 0) > 0;
};

export const getRolePermissions = async (roleId: number): Promise<Permission[]> => {
  const result = await pool.query(
    `SELECT p.* FROM permissions p
     JOIN role_permissions rp ON rp.permission_id = p.id
     WHERE rp.role_id = $1
     ORDER BY p.name ASC`,
    [roleId]
  );
  return result.rows;
};

export const setRolePermissions = async (
  roleId: number,
  permissionIds: number[]
): Promise<void> => {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    await client.query("DELETE FROM role_permissions WHERE role_id = $1", [roleId]);
    for (const pid of permissionIds) {
      await client.query(
        `INSERT INTO role_permissions (role_id, permission_id)
         VALUES ($1, $2) ON CONFLICT DO NOTHING`,
        [roleId, pid]
      );
    }
    await client.query("COMMIT");
  } catch (err) {
    await client.query("ROLLBACK");
    throw err;
  } finally {
    client.release();
  }
};
