import fs from "fs";
import path from "path";
import pool from "../config/db";

async function backupDatabase() {
  const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
  const backupDir = path.join(process.cwd(), "..", "backups");
  if (!fs.existsSync(backupDir)) {
    fs.mkdirSync(backupDir, { recursive: true });
  }

  const backupFile = path.join(backupDir, `mes_db_backup_${timestamp}.json`);
  const tables = [
    "roles",
    "permissions",
    "role_permissions",
    "users",
    "products",
    "manufacturing_orders",
    "inventory",
    "events",
    "qa_controls",
    "export_plans",
    "productivity_records",
    "uploaded_files",
  ];

  const backupData: Record<string, any[]> = {};

  const client = await pool.connect();
  try {
    // eslint-disable-next-line no-console
    console.log("[backup] Starting database backup...");
    for (const table of tables) {
      try {
        const res = await client.query(`SELECT * FROM ${table}`);
        backupData[table] = res.rows;
        // eslint-disable-next-line no-console
        console.log(`[backup] Exported table '${table}' (${res.rows.length} rows)`);
      } catch (err: any) {
        // eslint-disable-next-line no-console
        console.warn(`[backup] Table '${table}' could not be exported (might not exist yet):`, err.message);
        backupData[table] = [];
      }
    }

    fs.writeFileSync(backupFile, JSON.stringify(backupData, null, 2), "utf8");
    // eslint-disable-next-line no-console
    console.log(`[backup] Database backup successfully created at: ${backupFile}`);
  } catch (err) {
    // eslint-disable-next-line no-console
    console.error("[backup] Database backup failed:", err);
  } finally {
    client.release();
    await pool.end();
  }
}

backupDatabase();
