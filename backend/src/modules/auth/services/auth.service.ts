import * as authRepository from "../repositories/auth.repositories";
import * as authUtils from "../utils/auth.utils";
import * as tokenUtils from "../utils/token.utils";
import {
  DbUser,
  DbUserRegistrationResult,
  DbUserSummary,
} from "../types/auth.types";
import { IAuthTokens } from "../interfaces/auth.interface";
import { env } from "../../../config/env";
import { sendEmail, generateRegistrationEmail } from "../../../shared/services/email.service";

type AuthUserWithoutPassword = Omit<DbUser, "password">;

const buildTokens = (user: {
  id: number;
  email: string;
  role: string;
}): { accessToken: string; refreshToken: string; expiresIn: number } => {
  const payload = { id: user.id, email: user.email, role: user.role };
  return {
    accessToken: authUtils.generateAccessToken(payload),
    refreshToken: authUtils.generateRefreshToken(payload),
    expiresIn: env.jwt.accessExpiresInSeconds,
  };
};

export const login = async (
  email: string,
  password: string
): Promise<IAuthTokens> => {
  // Find user by email
  const user = await authRepository.findByEmail(email);

  if (!user) {
    throw new Error("Invalid credentials");
  }

  if (user.status !== "active") {
    throw new Error("User account is not active. Please complete registration.");
  }

  if (!user.password) {
    throw new Error("Invalid credentials");
  }

  // Compare passwords
  const isPasswordValid = await authUtils.comparePasswords(
    password,
    user.password
  );

  if (!isPasswordValid) {
    throw new Error("Invalid credentials");
  }

  // Generate access + refresh tokens
  const tokens = buildTokens({
    id: user.id,
    email: user.email,
    role: user.role,
  });

  // Return user without password
  const { password: _, ...userWithoutPassword } = user;

  return {
    ...tokens,
    user: userWithoutPassword,
  };
};

/**
 * Exchange a valid refresh token for a fresh access/refresh token pair
 * (refresh token rotation).
 */
export const refreshTokens = async (
  refreshToken: string
): Promise<IAuthTokens> => {
  const payload = authUtils.verifyRefreshToken(refreshToken);

  if (!payload) {
    throw new Error("Invalid or expired refresh token");
  }

  // Re-load the user to ensure the account still exists and is active,
  // and to pick up any role changes since the refresh token was issued.
  const user = await authRepository.findById(payload.id);

  if (!user || user.status !== "active") {
    throw new Error("Invalid or expired refresh token");
  }

  const tokens = buildTokens({
    id: user.id,
    email: user.email,
    role: user.role,
  });

  const { password: _, ...userWithoutPassword } = user;

  return {
    ...tokens,
    user: userWithoutPassword as AuthUserWithoutPassword,
  };
};

export const register = async (
  name: string,
  email: string,
  password: string,
  roleId: number
): Promise<DbUserSummary> => {
  // Check if user already exists
  const existingUser = await authRepository.findByEmail(email);

  if (existingUser) {
    throw new Error("Email already in use");
  }

  // Hash password
  const hashedPassword = await authUtils.hashPassword(password);

  // Create user
  const newUser = await authRepository.createUser(
    name,
    email,
    hashedPassword,
    roleId
  );

  return newUser;
};

export const createUserByAdmin = async (
  email: string,
  roleId: number,
  baseUrl: string
): Promise<{
  id: number;
  email: string;
  status: string;
}> => {
  // Check if email already exists
  const emailExists = await authRepository.checkEmailExists(email);

  if (emailExists) {
    throw new Error("Email already in use");
  }

  // Generate registration token
  const { token, expiresAt } = tokenUtils.generateRegistrationToken();

  // Create pending user
  const newUser = await authRepository.createPendingUser(
    email,
    roleId,
    token,
    expiresAt
  );

  // Generate registration link
  const registrationLink = `${baseUrl}/complete-registration/${token}`;

  // Send registration email
  const emailHtml = generateRegistrationEmail("New User", registrationLink);

  await sendEmail({
    to: email,
    subject: "Complete Your Registration - Calotex MES",
    html: emailHtml,
  });

  return {
    id: newUser.id,
    email: newUser.email,
    status: "pending",
  };
};

export const completeRegistration = async (
  token: string,
  fullName: string,
  password: string,
  passwordConfirm: string
): Promise<DbUserRegistrationResult> => {
  // Validate passwords match
  if (password !== passwordConfirm) {
    throw new Error("Passwords do not match");
  }

  // Validate password strength (optional but recommended)
  if (password.length < 8) {
    throw new Error("Password must be at least 8 characters");
  }

  // Find user by token
  const user = await authRepository.findByRegistrationToken(token);

  if (!user) {
    throw new Error("Invalid registration token");
  }

  // Check if token is expired
  if (!user.token_expiry || tokenUtils.isTokenExpired(new Date(user.token_expiry))) {
    throw new Error("Registration link has expired");
  }

  // Check if user status is pending
  if (user.status !== "pending") {
    throw new Error("User registration is no longer pending");
  }

  // Hash password
  const hashedPassword = await authUtils.hashPassword(password);

  // Update user with registration data
  const updatedUser = await authRepository.updateUserRegistration(
    user.id,
    fullName,
    hashedPassword
  );

  return updatedUser;
};