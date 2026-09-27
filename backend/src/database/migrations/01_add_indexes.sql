-- Migration: 01_add_indexes.sql
-- Description: Creates indexes for performance optimization on frequent lookups, joins, and sort columns.

-- Users table indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role_id ON users(role_id);
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);

-- Events table index
CREATE INDEX IF NOT EXISTS idx_events_event_date ON events(event_date);

-- Manufacturing orders table index
CREATE INDEX IF NOT EXISTS idx_mfg_orders_product_id ON manufacturing_orders(product_id);
CREATE INDEX IF NOT EXISTS idx_mfg_orders_status ON manufacturing_orders(status);

-- Inventory table index
CREATE INDEX IF NOT EXISTS idx_inventory_sku ON inventory(sku);
