import crypto from "crypto";

export const generateRegistrationToken = (): {
  token: string;
  expiresAt: Date;
} => {
  const token = crypto.randomBytes(32).toString("hex");
  const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours

  return { token, expiresAt };
};

export const generateResetToken = (): {
  token: string;
  expiresAt: Date;
} => {
  const token = crypto.randomBytes(32).toString("hex");
  const expiresAt = new Date(Date.now() + 60 * 60 * 1000); // 1 hour

  return { token, expiresAt };
};

export const isTokenExpired = (expiresAt: Date): boolean => {
  return new Date() > expiresAt;
};
