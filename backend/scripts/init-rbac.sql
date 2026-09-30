-- RBAC schema: roles, permissions, and their associations.
-- Apply this after init-mes-db.sql (which creates the products/orders/events/
-- inventory tables). Safe to re-run (uses IF NOT EXISTS / ON CONFLICT).

-- 1. Roles ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    is_system BOOLEAN DEFAULT false, -- system roles (e.g. admin) cannot be deleted
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Permissions ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS permissions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,        -- e.g. "users:create"
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Role <-> Permission mapping ----------------------------------------
CREATE TABLE IF NOT EXISTS role_permissions (
    role_id INT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_id INT NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

-- 4. Users ---------------------------------------------------------------
-- Replaces the previous implicit users table: adds a unique email,
-- nullable password (for admin-created pending users), and status.
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255),
    role_id INT REFERENCES roles(id) ON DELETE SET NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('active', 'pending', 'inactive')),
    registration_token VARCHAR(255),
    token_expiry TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Indexes -------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role_id ON users(role_id);
CREATE INDEX IF NOT EXISTS idx_role_permissions_role_id ON role_permissions(role_id);
CREATE INDEX IF NOT EXISTS idx_role_permissions_permission_id ON role_permissions(permission_id);

-- 6. Trigger to keep updated_at fresh -----------------------------------
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'set_timestamp_users') THEN
    CREATE TRIGGER set_timestamp_users
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'set_timestamp_roles') THEN
    CREATE TRIGGER set_timestamp_roles
    BEFORE UPDATE ON roles
    FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
  END IF;
END $$;

-- 7. Seed default permissions -------------------------------------------
INSERT INTO permissions (name, description) VALUES
    ('users:read',   'View users'),
    ('users:create', 'Create users'),
    ('users:update', 'Update users and assign roles'),
    ('users:delete', 'Deactivate/delete users'),
    ('roles:read',   'View roles'),
    ('roles:create', 'Create roles'),
    ('roles:update', 'Update roles and their permissions'),
    ('roles:delete', 'Delete roles'),
    ('permissions:read',   'View permissions'),
    ('permissions:create', 'Create permissions'),
    ('products:read',   'View products'),
    ('products:update', 'Update product approval'),
    ('inventory:read',   'View inventory'),
    ('inventory:create', 'Create inventory items'),
    ('inventory:update', 'Update inventory items'),
    ('inventory:delete', 'Delete inventory items'),
    ('manufacturing:read',   'View manufacturing orders'),
    ('events:read',   'View events'),
    ('dashboard:read', 'View dashboard'),
    ('export_plan:read', 'View export planning')
ON CONFLICT (name) DO NOTHING;

-- 8. Seed default roles -------------------------------------------------
INSERT INTO roles (name, description, is_system) VALUES
    ('admin', 'Full access to everything', true),
    ('production_manager', 'Production manager', true),
    ('manager', 'Operational manager', false),
    ('operator', 'Shop-floor operator', false)
ON CONFLICT (name) DO NOTHING;

-- Grant all permissions to admin
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.name = 'admin'
ON CONFLICT DO NOTHING;

-- Grant a sensible subset to manager
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
CROSS JOIN permissions p
WHERE r.name = 'manager'
  AND p.name IN (
    'users:read', 'roles:read', 'permissions:read',
    'products:read', 'products:update',
    'inventory:read', 'inventory:create', 'inventory:update', 'inventory:delete',
    'manufacturing:read', 'events:read', 'dashboard:read', 'export_plan:read'
  )
ON CONFLICT DO NOTHING;

-- Grant the same operational permissions to the production manager role.
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
CROSS JOIN permissions p
WHERE r.name = 'production_manager'
  AND p.name IN (
    'users:read', 'roles:read', 'permissions:read',
    'products:read', 'products:update',
    'inventory:read', 'inventory:create', 'inventory:update', 'inventory:delete',
    'manufacturing:read', 'events:read', 'dashboard:read', 'export_plan:read'
  )
ON CONFLICT DO NOTHING;

-- Grant read-only operational access to operator
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
CROSS JOIN permissions p
WHERE r.name = 'operator'
  AND p.name IN (
    'products:read', 'inventory:read', 'manufacturing:read',
    'events:read', 'dashboard:read'
  )
ON CONFLICT DO NOTHING;
