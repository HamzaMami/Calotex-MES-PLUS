/**
 * Reset Admin Script
 * Usage: npx ts-node scripts/reset-admin.ts
 *
 * This script creates or resets the admin account with:
 *   Email:    admin@calotex.com
 *   Password: Admin@1234
 */

import * as bcrypt from "bcrypt";
import { Pool } from "pg";
import * as dotenv from "dotenv";
import * as path from "path";

dotenv.config({ path: path.join(__dirname, "../.env") });

const pool = new Pool({
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT || "5432"),
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

const ADMIN_EMAIL = "admin@calotex.com";
const ADMIN_NAME = "Admin";
const ADMIN_PASSWORD = "Admin@1234";

async function resetAdmin() {
  const client = await pool.connect();
  try {
    console.log("🔌 Connected to database:", process.env.DB_NAME);

    // Get the admin role id
    const roleResult = await client.query(
      `SELECT id FROM roles WHERE name ILIKE 'admin' LIMIT 1`
    );

    if (roleResult.rows.length === 0) {
      // List all available roles
      const allRoles = await client.query(`SELECT id, name FROM roles`);
      console.log("⚠️  No 'admin' role found. Available roles:");
      allRoles.rows.forEach((r) => console.log(`   - id=${r.id}  name=${r.name}`));
      console.log("\nUsing role id=1 as fallback...");
    }

    const roleId = roleResult.rows[0]?.id ?? 1;
    console.log(`✅ Using role id=${roleId}`);

    // Hash the password
    const hashedPassword = await bcrypt.hash(ADMIN_PASSWORD, 10);

    // Upsert the admin user
    const upsertQuery = `
      INSERT INTO users (name, email, password, role_id, status)
      VALUES ($1, $2, $3, $4, 'active')
      ON CONFLICT (email)
      DO UPDATE SET
        name     = EXCLUDED.name,
        password = EXCLUDED.password,
        role_id  = EXCLUDED.role_id,
        status   = 'active',
        registration_token = NULL,
        token_expiry       = NULL
      RETURNING id, name, email, status
    `;

    const result = await client.query(upsertQuery, [
      ADMIN_NAME,
      ADMIN_EMAIL,
      hashedPassword,
      roleId,
    ]);

    const user = result.rows[0];
    console.log("\n✅ Admin account ready:");
    console.log(`   ID:       ${user.id}`);
    console.log(`   Name:     ${user.name}`);
    console.log(`   Email:    ${user.email}`);
    console.log(`   Status:   ${user.status}`);
    console.log(`   Password: ${ADMIN_PASSWORD}`);
    console.log("\n🎉 You can now log in with the credentials above.");
  } catch (err) {
    console.error("❌ Error:", err);
    process.exit(1);
  } finally {
    client.release();
    await pool.end();
  }
}

resetAdmin();
