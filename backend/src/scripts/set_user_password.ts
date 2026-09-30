import pool from "../config/db";
import { hashPassword } from "../modules/auth/utils/auth.utils";

async function run() {
  const email = "Ahlem@calotex.com";
  const rawPassword = "Ahlem2026!";
  const hashedPassword = await hashPassword(rawPassword);

  // Check if user exists
  const existing = await pool.query("SELECT id FROM users WHERE email = $1", [email]);
  if (existing.rows.length > 0) {
    await pool.query(
      "UPDATE users SET password = $1, status = 'active', updated_at = NOW() WHERE email = $2",
      [hashedPassword, email]
    );
    console.log(`Password updated successfully for ${email}`);
  } else {
    // Find default role (e.g. QA Technician or Admin)
    const roleRes = await pool.query("SELECT id FROM roles WHERE name = 'QA Technician' OR name = 'Admin' LIMIT 1");
    const roleId = roleRes.rows[0]?.id || 1;

    await pool.query(
      `INSERT INTO users (name, email, password, status, role_id) VALUES ($1, $2, $3, 'active', $4)`,
      ['Ahlem', email, hashedPassword, roleId]
    );
    console.log(`User created and password set successfully for ${email}`);
  }
  process.exit(0);
}

run().catch((err) => {
  console.error("Error setting password:", err);
  process.exit(1);
});
