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
    // 0. Ensure qa_controls table exists so constraint drops don't fail on fresh databases
    await client.query(`
      CREATE TABLE IF NOT EXISTS qa_controls (
        id SERIAL PRIMARY KEY,
        product_code VARCHAR(100) NOT NULL,
        year INTEGER NOT NULL,
        calendar_week_kw INTEGER NOT NULL,
        first_control_id VARCHAR(50) NOT NULL,
        last_control_id VARCHAR(50) NOT NULL,
        first_serial_number VARCHAR(50) NOT NULL,
        last_serial_number VARCHAR(50) NOT NULL,
        created_by INTEGER,
        created_at TIMESTAMP DEFAULT NOW()
      );
    `);

    // Drop restrictive old SN check constraints on qa_controls if any exist
    await client.query(`
      ALTER TABLE qa_controls DROP CONSTRAINT IF EXISTS qa_controls_first_serial_number_check;
      ALTER TABLE qa_controls DROP CONSTRAINT IF EXISTS qa_controls_last_serial_number_check;
    `);

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

    // 2. Ensure system and custom roles exist
    await client.query(`
      INSERT INTO roles (name, description, is_system) VALUES
        ('Admin', 'Administrator', TRUE),
        ('Calotex Project owner', 'Calotex Project Owner', TRUE),
        ('Calotex Technical Diractor', 'Calotex Technical Director', TRUE),
        ('CTX-1 production manager', 'CTX-1 Production Manager', FALSE),
        ('CTX-1 technical team manager', 'CTX-1 Technical Team Manager', FALSE),
        ('Engineer', 'Engineer', FALSE),
        ('Line manager', 'Line Manager', FALSE),
        ('QA Technician', 'QA Technician', FALSE),
        ('Winkler Client', 'Winkler Client', FALSE),
        ('Direct Client', 'Direct Client', FALSE),
        ('Sales manager', 'Sales Manager', FALSE),
        ('Inventory manager', 'Inventory Manager', FALSE)
      ON CONFLICT (name) DO NOTHING;
    `);

    // 3. Grant ALL permissions to system roles ('Admin', 'Calotex Project owner', 'Calotex Technical Diractor')
    await client.query(`
      INSERT INTO role_permissions (role_id, permission_id)
      SELECT r.id, p.id
      FROM roles r, permissions p
      WHERE r.name IN ('Admin', 'Calotex Project owner', 'Calotex Technical Diractor')
      ON CONFLICT DO NOTHING;
    `);

    // 4. Grant QA Technician permissions (dashboard, products, manufacturing, inventory, events read/create/update)
    await client.query(`
      INSERT INTO role_permissions (role_id, permission_id)
      SELECT r.id, p.id
      FROM roles r, permissions p
      WHERE r.name = 'QA Technician'
        AND p.name IN (
          'dashboard:read',
          'products:read', 'products:update',
          'manufacturing:read', 'manufacturing:update',
          'inventory:read',
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
