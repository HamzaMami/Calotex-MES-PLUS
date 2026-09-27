import { Pool } from "pg";
import { env } from "./env";

const pool = new Pool({
  host: env.db.host,
  port: env.db.port,
  user: env.db.user,
  password: env.db.password,
  database: env.db.name,
  ssl: env.db.ssl ? { rejectUnauthorized: false } : undefined,
  max: 10,
  idleTimeoutMillis: 30_000,
  connectionTimeoutMillis: 10_000,
});

// Surface pool-level errors (e.g. a backend dropping an idle client) instead of
// letting them crash the process silently.
pool.on("error", (err) => {
  // eslint-disable-next-line no-console
  console.error("[db] Unexpected error on idle PostgreSQL client:", err);
});

/** Automatically seed permissions and assign full permissions to system roles if missing. */
const ensureSystemPermissionsSeeded = async (client: any): Promise<void> => {
  try {
    // 1. Ensure permissions table has all required permissions
    await client.query(`
      INSERT INTO permissions (name, description) VALUES
        ('dashboard:read', 'Read dashboard'),
        ('users:create', 'Create users'),
        ('users:read', 'Read users'),
        ('users:update', 'Update users'),
        ('users:delete', 'Delete users'),
        ('roles:create', 'Create roles'),
        ('roles:read', 'Read roles'),
        ('roles:update', 'Update roles'),
        ('roles:delete', 'Delete roles'),
        ('permissions:create', 'Create permissions'),
        ('permissions:read', 'Read permissions'),
        ('permissions:update', 'Update permissions'),
        ('permissions:delete', 'Delete permissions'),
        ('products:create', 'Create products'),
        ('products:read', 'Read products'),
        ('products:update', 'Update products'),
        ('products:delete', 'Delete products'),
        ('manufacturing:create', 'Create manufacturing orders'),
        ('manufacturing:read', 'Read manufacturing orders'),
        ('manufacturing:update', 'Update manufacturing orders'),
        ('manufacturing:delete', 'Delete manufacturing orders'),
        ('inventory:create', 'Create inventory items'),
        ('inventory:read', 'Read inventory items'),
        ('inventory:update', 'Update inventory items'),
        ('inventory:delete', 'Delete inventory items'),
        ('events:create', 'Create events'),
        ('events:read', 'Read events'),
        ('events:update', 'Update events'),
        ('events:delete', 'Delete events')
      ON CONFLICT (name) DO NOTHING;
    `);

    // 2. Ensure system roles exist
    await client.query(`
      INSERT INTO roles (name, description, is_system) VALUES
        ('admin', 'Administrator', TRUE),
        ('manager', 'Manager', TRUE),
        ('operator', 'Operator', TRUE)
      ON CONFLICT (name) DO NOTHING;
    `);

    // 3. Grant ALL permissions to the 'admin' system role
    await client.query(`
      INSERT INTO role_permissions (role_id, permission_id)
      SELECT r.id, p.id
      FROM roles r, permissions p
      WHERE r.name = 'admin'
      ON CONFLICT DO NOTHING;
    `);

    // 4. Grant Manager permissions
    await client.query(`
      INSERT INTO role_permissions (role_id, permission_id)
      SELECT r.id, p.id
      FROM roles r, permissions p
      WHERE r.name = 'manager'
        AND p.name IN (
          'dashboard:read',
          'users:read', 'users:create', 'users:update',
          'roles:read',
          'permissions:read',
          'products:read', 'products:create', 'products:update',
          'manufacturing:read', 'manufacturing:create', 'manufacturing:update',
          'inventory:read', 'inventory:create', 'inventory:update',
          'events:read', 'events:create', 'events:update'
        )
      ON CONFLICT DO NOTHING;
    `);

    // 5. Grant Operator permissions
    await client.query(`
      INSERT INTO role_permissions (role_id, permission_id)
      SELECT r.id, p.id
      FROM roles r, permissions p
      WHERE r.name = 'operator'
        AND p.name IN (
          'dashboard:read',
          'products:read',
          'manufacturing:read', 'manufacturing:update',
          'inventory:read', 'inventory:update',
          'events:read'
        )
      ON CONFLICT DO NOTHING;
    `);
  } catch (err) {
    // eslint-disable-next-line no-console
    console.error("[db] Error seeding system permissions:", err);
  }
};

/** Verify the database is reachable and seed system permissions if needed. Call once during startup. */
export const verifyDatabaseConnection = async (): Promise<void> => {
  const client = await pool.connect();
  try {
    await client.query("SELECT 1");
    await ensureSystemPermissionsSeeded(client);
  } finally {
    client.release();
  }
};

/** Gracefully close the pool during shutdown. */
export const closePool = async (): Promise<void> => {
  await pool.end();
};

export default pool;
