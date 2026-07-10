export type JwtSecret = string;

export type AuthRequest = {
  id: number;
  email: string;
  role: string;
};

export interface DbUser {
  id: number;
  name: string | null;
  email: string;
  password?: string | null;
  status: "active" | "pending";
  role: string;
  registration_token?: string | null;
  token_expiry?: Date | string | null;
}

export interface DbUserSummary {
  id: number;
  name: string | null;
  email: string;
}

export interface DbPendingUser {
  id: number;
  email: string;
}

export interface DbUserRegistrationResult {
  id: number;
  name: string | null;
  email: string;
  status: "active";
}

export interface DbCountRow {
  count: string;
}
