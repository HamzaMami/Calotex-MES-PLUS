import jwt from "jsonwebtoken";
import bcrypt from "bcrypt";
import { IJwtPayload } from "../interfaces/auth.interface";
import { env } from "../../../config/env";

const SALT_ROUNDS = 10;

type ExpiresIn = jwt.SignOptions["expiresIn"];

export const hashPassword = async (password: string): Promise<string> => {
  return bcrypt.hash(password, SALT_ROUNDS);
};

export const comparePasswords = async (
  password: string,
  hashedPassword: string
): Promise<boolean> => {
  return bcrypt.compare(password, hashedPassword);
};

/** Short-lived access token used for authenticating API requests. */
export const generateAccessToken = (payload: IJwtPayload): string => {
  return jwt.sign(payload, env.jwt.accessSecret, {
    expiresIn: env.jwt.accessExpiresIn as ExpiresIn,
  });
};

/** Long-lived refresh token used to obtain new access tokens. */
export const generateRefreshToken = (payload: IJwtPayload): string => {
  return jwt.sign(payload, env.jwt.refreshSecret, {
    expiresIn: env.jwt.refreshExpiresIn as ExpiresIn,
  });
};

export const verifyAccessToken = (token: string): IJwtPayload | null => {
  try {
    return jwt.verify(token, env.jwt.accessSecret) as IJwtPayload;
  } catch {
    return null;
  }
};

export const verifyRefreshToken = (token: string): IJwtPayload | null => {
  try {
    return jwt.verify(token, env.jwt.refreshSecret) as IJwtPayload;
  } catch {
    return null;
  }
};

/**
 * @deprecated Use {@link generateAccessToken}. Kept for backward compatibility.
 */
export const generateToken = generateAccessToken;

/**
 * @deprecated Use {@link verifyAccessToken}. Kept for backward compatibility.
 */
export const verifyToken = verifyAccessToken;
