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

async function seedDashboard() {
  const client = await pool.connect();
  try {
    console.log(`🔌 Connected to database: ${process.env.DB_NAME}`);
    
    // Clear existing data
    await client.query("TRUNCATE events, manufacturing_orders, products RESTART IDENTITY CASCADE");

    console.log("🌱 Seeding Products...");
    const productsRes = await client.query(`
      INSERT INTO products (name, lead_engineer_id, technical_milestone, validation_status, final_approval)
      VALUES 
        ('Aixtron-UK-V1', 1, 'Defining Heating Element', 'Waiting for Mr. AZ', false),
        ('Project Omega', null, 'Process list', 'Approved by Ms. Sana', true),
        ('Aixtron-DE-Ecrou', 1, 'Isolation method', 'Internal Review', false)
      RETURNING id;
    `);

    console.log("🌱 Seeding Manufacturing Orders...");
    await client.query(`
      INSERT INTO manufacturing_orders (product_id, status, target_quantity, good_quantity, reject_quantity, qa_quantity)
      VALUES 
        ($1, 'in_production', 200, 150, 5, 20),
        ($2, 'pending', 50, 0, 0, 0),
        ($3, 'quality_control', 100, 90, 2, 8)
    `, [productsRes.rows[0].id, productsRes.rows[1].id, productsRes.rows[2].id]);

    console.log("🌱 Seeding Events...");
    // Create some upcoming events relative to today
    const today = new Date();
    const event1 = new Date(today); event1.setDate(today.getDate() + 1);
    const event2 = new Date(today); event2.setDate(today.getDate() + 3);
    const event3 = new Date(today); event3.setDate(today.getDate() + 5);

    await client.query(`
      INSERT INTO events (title, type, event_date)
      VALUES 
        ('Technical team meeting', 'technical', $1),
        ('Quality check phase 1', 'quality', $2),
        ('Shipment batch A', 'export', $3)
    `, [event1, event2, event3]);

    console.log("✅ Dashboard seeded successfully.");
  } catch (error) {
    console.error("❌ Error seeding dashboard:", error);
  } finally {
    client.release();
    await pool.end();
  }
}

seedDashboard();
