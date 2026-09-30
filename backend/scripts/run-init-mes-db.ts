import { Pool } from "pg";
import * as dotenv from "dotenv";
import * as path from "path";
import * as fs from "fs";

dotenv.config({ path: path.join(__dirname, "../.env") });

const pool = new Pool({
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT || "5432"),
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

async function initMesDb() {
  const client = await pool.connect();
  try {
    console.log(`🔌 Connected to database: ${process.env.DB_NAME}`);

    const mesSqlPath = path.join(__dirname, "init-mes-db.sql");
    const mesScript = fs.readFileSync(mesSqlPath, "utf8");
    console.log("📜 Executing init-mes-db.sql...");
    await client.query(mesScript);
    console.log("✅ MES tables initialized successfully.");

    const rbacSqlPath = path.join(__dirname, "init-rbac.sql");
    if (fs.existsSync(rbacSqlPath)) {
      const rbacScript = fs.readFileSync(rbacSqlPath, "utf8");
      console.log("📜 Executing init-rbac.sql...");
      await client.query(rbacScript);
      console.log("✅ Roles / permissions initialized successfully.");
    } else {
      console.warn("⚠️  init-rbac.sql not found; skipping RBAC setup.");
    }
  } catch (error) {
    console.error("❌ Error initializing database:", error);
  } finally {
    client.release();
    await pool.end();
  }
}

initMesDb();
