import pool from "../../../config/db";
import {
  DbCountRow,
  DbPendingUser,
  DbUser,
  DbUserRegistrationResult,
  DbUserSummary,
} from "../types/auth.types";

export const findByEmail = async (email: string): Promise<DbUser | undefined> => {
  const query = `
    SELECT 
      users.id,
      users.name,
      users.email,
      users.password,
      users.status,
      roles.name as role
    FROM users
    JOIN roles ON users.role_id = roles.id
    WHERE users.email = $1
  `;

  const result = await pool.query<DbUser>(query, [email]);

  return result.rows[0];
};

export const findById = async (id: number): Promise<DbUser | undefined> => {
  const query = `
    SELECT 
      users.id,
      users.name,
      users.email,
      users.password,
      users.status,
      users.registration_token,
      users.token_expiry,
      roles.name as role
    FROM users
    JOIN roles ON users.role_id = roles.id
    WHERE users.id = $1
  `;

  const result = await pool.query<DbUser>(query, [id]);

  return result.rows[0];
};

export const findByRegistrationToken = async (
  token: string
): Promise<DbUser | undefined> => {
  const query = `
    SELECT 
      users.id,
      users.name,
      users.email,
      users.password,
      users.status,
      users.registration_token,
      users.token_expiry,
      roles.name as role
    FROM users
    JOIN roles ON users.role_id = roles.id
    WHERE users.registration_token = $1
  `;

  const result = await pool.query<DbUser>(query, [token]);

  return result.rows[0];
};

export const createUser = async (
  name: string,
  email: string,
  password: string,
  roleId: number
): Promise<DbUserSummary> => {
  const query = `
    INSERT INTO users (
      name,
      email,
      password,
      role_id,
      status
    )
    VALUES ($1, $2, $3, $4, 'active')
    RETURNING id, name, email
  `;

  const result = await pool.query<DbUserSummary>(query, [
    name,
    email,
    password,
    roleId,
  ]);

  return result.rows[0];
};

export const createPendingUser = async (
  email: string,
  roleId: number,
  registrationToken: string,
  tokenExpiry: Date
): Promise<DbPendingUser> => {
  const query = `
    INSERT INTO users (
      email,
      role_id,
      status,
      registration_token,
      token_expiry
    )
    VALUES ($1, $2, 'pending', $3, $4)
    RETURNING id, email
  `;

  const result = await pool.query<DbPendingUser>(query, [
    email,
    roleId,
    registrationToken,
    tokenExpiry,
  ]);

  return result.rows[0];
};

export const updateUserRegistration = async (
  userId: number,
  name: string,
  password: string
): Promise<DbUserRegistrationResult> => {
  const query = `
    UPDATE users
    SET 
      name = $1,
      password = $2,
      status = 'active',
      registration_token = NULL,
      token_expiry = NULL
    WHERE id = $3
    RETURNING id, name, email, status
  `;

  const result = await pool.query<DbUserRegistrationResult>(query, [name, password, userId]);

  return result.rows[0];
};

export const checkEmailExists = async (email: string): Promise<boolean> => {
  const query = `
    SELECT COUNT(*) as count FROM users WHERE email = $1
  `;

  const result = await pool.query<DbCountRow>(query, [email]);

  return parseInt(result.rows[0].count) > 0;
};