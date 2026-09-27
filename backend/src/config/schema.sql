CREATE TABLE IF NOT EXISTS roles (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  is_system BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS permissions (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS role_permissions (
  role_id INTEGER NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
  permission_id INTEGER NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
  PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  email VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255),
  status VARCHAR(50) DEFAULT 'active',
  role_id INTEGER REFERENCES roles(id),
  registration_token VARCHAR(255),
  token_expiry TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  lead_engineer_id INTEGER,
  technical_milestone TEXT,
  validation_status TEXT,
  final_approval BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS manufacturing_orders (
  id SERIAL PRIMARY KEY,
  product_id INTEGER NOT NULL REFERENCES products(id),
  status VARCHAR(50) DEFAULT 'pending',
  target_quantity INTEGER DEFAULT 0,
  good_quantity INTEGER DEFAULT 0,
  reject_quantity INTEGER DEFAULT 0,
  qa_quantity INTEGER DEFAULT 0,
  start_date TIMESTAMP,
  end_date TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS inventory (
  id SERIAL PRIMARY KEY,
  item_name VARCHAR(255) NOT NULL,
  sku VARCHAR(100),
  quantity INTEGER DEFAULT 0,
  unit VARCHAR(50) DEFAULT 'pcs',
  location VARCHAR(255),
  last_restocked TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS events (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  type VARCHAR(50),
  event_date TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO roles (name, description, is_system) VALUES
  ('admin', 'Administrator', TRUE),
  ('manager', 'Manager', TRUE),
  ('operator', 'Operator', TRUE)
ON CONFLICT (name) DO NOTHING;

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

-- Seed system role permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p WHERE r.name = 'admin'
ON CONFLICT DO NOTHING;

-- Seed products
INSERT INTO products (id, name, lead_engineer_id, technical_milestone, validation_status, final_approval, created_at, updated_at) VALUES
  (101, 'Calotex Panel A1', 12, 'Prototype review', 'In progress', false, NOW(), NOW()),
  (102, 'Calotex Tube Pro', 8, 'Bench testing', 'QA pending', true, NOW(), NOW()),
  (103, 'Calotex Valve X', 15, 'Design freeze', 'Approved', true, NOW(), NOW()),
  (104, 'Calotex Sensor M', 9, 'Calibration', 'In progress', false, NOW(), NOW()),
  (105, 'Calotex Bracket S', 11, 'Tooling ready', 'Pending', false, NOW(), NOW()),
  (106, 'Calotex Gasket R', 14, 'Material certified', 'Approved', true, NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Seed manufacturing orders
INSERT INTO manufacturing_orders (id, product_id, status, target_quantity, good_quantity, reject_quantity, qa_quantity, start_date, end_date, created_at, updated_at) VALUES
  (11004891, 101, 'in_production', 230, 180, 8, 12, NOW() - INTERVAL '7 days', NOW(), NOW(), NOW()),
  (11005007, 102, 'completed', 10, 10, 0, 0, NOW() - INTERVAL '5 days', NOW() - INTERVAL '1 day', NOW(), NOW()),
  (11005113, 103, 'in_production', 11, 7, 2, 2, NOW() - INTERVAL '3 days', NOW() + INTERVAL '2 days', NOW(), NOW()),
  (11005125, 104, 'quality_control', 6, 4, 1, 1, NOW() - INTERVAL '2 days', NOW() + INTERVAL '1 day', NOW(), NOW()),
  (11005176, 105, 'in_production', 12, 8, 2, 2, NOW() - INTERVAL '1 day', NOW() + INTERVAL '3 days', NOW(), NOW()),
  (6412, 106, 'pending', 1, 0, 0, 0, NOW(), NOW() + INTERVAL '7 days', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Seed events
INSERT INTO events (id, title, type, event_date, created_at, updated_at) VALUES
  (1, 'Technical team meeting', 'technical', NOW() - INTERVAL '2 days', NOW(), NOW()),
  (2, 'Quality Control', 'quality', NOW() - INTERVAL '1 day', NOW(), NOW()),
  (3, 'Export', 'export', NOW() + INTERVAL '1 day', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
