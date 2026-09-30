import { Pool } from "pg";
import { env } from "./env";
import { schemaSql } from "./schema";

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

/** Automatically initialize database schema and apply migration patches on startup. */
const ensureDatabaseInitialized = async (client: any): Promise<void> => {
  try {
    await client.query(schemaSql);

    // Migration patches for existing tables created prior to schema updates
    await client.query(`
      ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar VARCHAR(255);
      ALTER TABLE users ADD COLUMN IF NOT EXISTS registration_token VARCHAR(255);
      ALTER TABLE users ADD COLUMN IF NOT EXISTS token_expiry TIMESTAMP;
    `);

    // eslint-disable-next-line no-console
    console.log("[db] Database schema and migration patches applied successfully");
  } catch (err) {
    // eslint-disable-next-line no-console
    console.error("[db] Error initializing database schema:", err);
  }
};

/** Verify the database is reachable and initialize schema. Call once during startup. */
export const verifyDatabaseConnection = async (): Promise<void> => {
  const client = await pool.connect();
  try {
    await client.query("SELECT 1");
    await ensureDatabaseInitialized(client);
  } finally {
    client.release();
  }
};

/** Gracefully close the pool during shutdown. */
export const closePool = async (): Promise<void> => {
  await pool.end();
};

export default pool;
