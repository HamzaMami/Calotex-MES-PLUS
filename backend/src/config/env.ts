import dotenv from "dotenv";

dotenv.config();

/**
 * Centralized, validated environment configuration.
 *
 * Required variables are checked at startup so the process fails fast with a
 * clear message instead of crashing later with confusing runtime errors.
 */

function required(name: string): string {
  const value = process.env[name];
  if (value === undefined || value === "") {
    throw new Error(
      `Missing required environment variable: ${name}. ` +
        `Check your .env file (see .env.example).`
    );
  }
  return value;
}

function optional(name: string, fallback: string): string {
  const value = process.env[name];
  return value === undefined || value === "" ? fallback : value;
}

const nodeEnv = optional("NODE_ENV", "development");
const isProduction = nodeEnv === "production";

const accessSecret = required("JWT_SECRET");
// Fall back to a derived refresh secret in non-production only, so existing
// setups keep working; production must configure a dedicated secret.
const refreshSecret = isProduction
  ? required("JWT_REFRESH_SECRET")
  : optional("JWT_REFRESH_SECRET", `${accessSecret}_refresh`);

// Guard against shipping the well-known placeholder secret to production.
if (isProduction && (accessSecret === "SUPER_SECRET" || accessSecret.length < 16)) {
  throw new Error(
    "JWT_SECRET is weak or using the default placeholder. " +
      "Set a strong, unique JWT_SECRET (>= 16 chars) in production."
  );
}

if (!isProduction && accessSecret === "SUPER_SECRET") {
  // eslint-disable-next-line no-console
  console.warn(
    "[env] WARNING: JWT_SECRET is using the insecure default 'SUPER_SECRET'. " +
      "Replace it before deploying."
  );
}

export const env = {
  nodeEnv,
  isProduction,
  port: Number(optional("PORT", "5000")),

  db: {
    host: required("DB_HOST"),
    port: Number(optional("DB_PORT", "5432")),
    user: required("DB_USER"),
    password: required("DB_PASSWORD"),
    name: required("DB_NAME"),
    ssl: optional("DB_SSL", "false") === "true",
  },

  jwt: {
    accessSecret,
    refreshSecret,
    accessExpiresIn: optional("JWT_ACCESS_EXPIRES_IN", "15m"),
    refreshExpiresIn: optional("JWT_REFRESH_EXPIRES_IN", "7d"),
    /** Access token lifetime in seconds, surfaced to clients as `expires_in`. */
    accessExpiresInSeconds: Number(optional("JWT_ACCESS_EXPIRES_IN_SECONDS", "900")),
  },

  cors: {
    // Comma-separated allowlist, e.g. "http://localhost:3000,https://app.calotex.com".
    // Empty means "allow all" (development convenience only).
    origins: optional("CORS_ORIGINS", "")
      .split(",")
      .map((origin) => origin.trim())
      .filter(Boolean),
  },
} as const;

export type Env = typeof env;
