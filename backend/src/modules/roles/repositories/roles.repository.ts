import pool from "../../../config/db";
import { Role, Permission } from "../../permissions/interfaces/permissions.interface";

export const findAll = async (): Promise<Role[]> => {
  const result = await pool.query("SELECT * FROM roles ORDER BY id ASC");
  return result.rows;
};

export const findById = async (id: number): Promise<Role | null> => {
  const result = await pool.query("SELECT * FROM roles WHERE id = $1", [id]);
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
  return result.rows[0];
};

export const update = async (
  id: number,
  fields: { name?: string; description?: string }
): Promise<Role | null> => {
  const keys = Object.keys(fields);
  if (keys.length === 0) return null;

  const setClause = keys.map((k, i) => `"${k}" = $${i + 2}`).join(", ");
  const values = keys.map((k) => (fields as any)[k]);

  const result = await pool.query(
    `UPDATE roles SET ${setClause} WHERE id = $1 RETURNING *`,
    [id, ...values]
  );
  return result.rows[0] || null;
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
