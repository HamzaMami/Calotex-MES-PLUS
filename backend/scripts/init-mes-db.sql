-- Initialize MES core tables

-- 1. Products (Product Maturity)
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    lead_engineer_id INT REFERENCES users(id) ON DELETE SET NULL,
    technical_milestone VARCHAR(255),
    validation_status VARCHAR(255),
    final_approval BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Manufacturing Orders (Active Orders)
CREATE TABLE IF NOT EXISTS manufacturing_orders (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(id) ON DELETE CASCADE,
    status VARCHAR(50) NOT NULL CHECK (status IN ('in_production', 'pending', 'quality_control', 'completed')),
    target_quantity INT NOT NULL,
    good_quantity INT DEFAULT 0,
    reject_quantity INT DEFAULT 0,
    qa_quantity INT DEFAULT 0,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Events (Schedule Calendar)
CREATE TABLE IF NOT EXISTS events (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL CHECK (type IN ('technical', 'quality', 'export')),
    event_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Inventory
CREATE TABLE IF NOT EXISTS inventory (
    id SERIAL PRIMARY KEY,
    item_name VARCHAR(255) NOT NULL,
    sku VARCHAR(100) UNIQUE,
    quantity INT DEFAULT 0,
    unit VARCHAR(50) DEFAULT 'pcs',
    location VARCHAR(255),
    last_restocked TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create updated_at trigger function if it doesn't exist
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'set_timestamp_products') THEN
    CREATE TRIGGER set_timestamp_products
    BEFORE UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp();
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'set_timestamp_manufacturing_orders') THEN
    CREATE TRIGGER set_timestamp_manufacturing_orders
    BEFORE UPDATE ON manufacturing_orders
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp();
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'set_timestamp_events') THEN
    CREATE TRIGGER set_timestamp_events
    BEFORE UPDATE ON events
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp();
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'set_timestamp_inventory') THEN
    CREATE TRIGGER set_timestamp_inventory
    BEFORE UPDATE ON inventory
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp();
  END IF;
END $$;
