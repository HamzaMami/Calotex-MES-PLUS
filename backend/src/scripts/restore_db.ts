import fs from "fs";
import path from "path";
import pool from "../config/db";

async function restoreDatabase() {
  const backupDir = path.join(process.cwd(), "..", "backups");
  if (!fs.existsSync(backupDir)) {
    // eslint-disable-next-line no-console
    console.error("[restore] No backups directory found.");
    process.exit(1);
  }

  const files = fs.readdirSync(backupDir).filter((f) => f.endsWith(".json"));
  if (files.length === 0) {
    // eslint-disable-next-line no-console
    console.error("[restore] No JSON backup files found in backups/ directory.");
    process.exit(1);
  }

  // Pick the latest backup file
  files.sort().reverse();
  const latestFile = path.join(backupDir, files[0]);
  // eslint-disable-next-line no-console
  console.log(`[restore] Loading backup from: ${latestFile}`);

  const backupData = JSON.parse(fs.readFileSync(latestFile, "utf8"));
  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    for (const [tableName, rows] of Object.entries(backupData)) {
      if (!Array.isArray(rows) || rows.length === 0) continue;

      // eslint-disable-next-line no-console
      console.log(`[restore] Restoring ${rows.length} rows into '${tableName}'...`);

      for (const row of rows) {
        const keys = Object.keys(row);
        const values = Object.values(row);

        const columnsStr = keys.map((k) => `"${k}"`).join(", ");
        const placeholdersStr = keys.map((_, i) => `$${i + 1}`).join(", ");

        const query = `
          INSERT INTO "${tableName}" (${columnsStr})
          VALUES (${placeholdersStr})
          ON CONFLICT DO NOTHING
        `;

        await client.query(query, values);
      }
    }

    await client.query("COMMIT");
    // eslint-disable-next-line no-console
    console.log("[restore] Database restore completed successfully!");
  } catch (err) {
    await client.query("ROLLBACK");
    // eslint-disable-next-line no-console
    console.error("[restore] Database restore failed:", err);
  } finally {
    client.release();
    await pool.end();
  }
}

restoreDatabase();
