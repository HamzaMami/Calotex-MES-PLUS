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
