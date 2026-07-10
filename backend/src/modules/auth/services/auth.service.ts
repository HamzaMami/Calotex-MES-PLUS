import * as authRepository from "../repositories/auth.repositories";
import * as authUtils from "../utils/auth.utils";
import * as tokenUtils from "../utils/token.utils";
import {
  DbUser,
  DbUserRegistrationResult,
  DbUserSummary,
} from "../types/auth.types";
import { sendEmail, generateRegistrationEmail } from "../../../shared/services/email.service";

type AuthUserWithoutPassword = Omit<DbUser, "password">;

export const login = async (
  email: string,
  password: string
): Promise<{
  token: string;
  user: AuthUserWithoutPassword;
}> => {
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

  // Generate token
  const token = authUtils.generateToken({
    id: user.id,
    email: user.email,
    role: user.role,
  });

  // Return user without password
  const { password: _, ...userWithoutPassword } = user;

  return {
    token,
    user: userWithoutPassword,
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