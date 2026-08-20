export interface Permission {
  id: number;
  name: string;        // e.g. "users:create"
  description: string | null;
  created_at: Date;
}

export interface Role {
  id: number;
  name: string;
  description: string | null;
  is_system: boolean;
  created_at: Date;
  updated_at: Date;
  permissions?: Permission[];
}

export interface UserWithRole {
  id: number;
  name: string | null;
  email: string;
  status: "active" | "pending" | "inactive";
  role_id: number | null;
  role_name: string | null;
  created_at: Date;
  updated_at: Date;
}
