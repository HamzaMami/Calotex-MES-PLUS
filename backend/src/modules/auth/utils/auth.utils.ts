import jwt from "jsonwebtoken";
import bcrypt from "bcrypt";
import { IJwtPayload } from "../interfaces/auth.interface";

const JWT_SECRET = process.env.JWT_SECRET || "SUPER_SECRET";
const SALT_ROUNDS = 10;

export const hashPassword = async (password: string): Promise<string> => {
  return bcrypt.hash(password, SALT_ROUNDS);
};

export const comparePasswords = async (
  password: string,
  hashedPassword: string
): Promise<boolean> => {
  return bcrypt.compare(password, hashedPassword);
};

export const generateToken = (payload: IJwtPayload): string => {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: "24h" });
};

export const verifyToken = (token: string): IJwtPayload | null => {
  try {
    const decoded = jwt.verify(token, JWT_SECRET) as IJwtPayload;
    return decoded;
  } catch (error) {
    return null;
  }
};
