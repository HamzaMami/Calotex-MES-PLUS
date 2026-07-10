import { env } from "./config/env";
import app from "./app";
import { verifyDatabaseConnection, closePool } from "./config/db";

async function bootstrap() {
  // Fail fast if the database is unreachable at startup.
  try {
    await verifyDatabaseConnection();
    console.log("[db] Database connection verified");
  } catch (error) {
    console.error("[db] Failed to connect to the database:", error);
    process.exit(1);
  }

  const server = app.listen(env.port, () => {
    console.log(`Server is running on port ${env.port} (${env.nodeEnv})`);
  });

  // Graceful shutdown: stop accepting connections, then close the DB pool.
  const shutdown = async (signal: string) => {
    console.log(`\n[server] ${signal} received, shutting down gracefully...`);
    server.close(async () => {
      await closePool();
      console.log("[server] Shutdown complete");
      process.exit(0);
    });

    // Force-exit if graceful shutdown hangs.
    setTimeout(() => {
      console.error("[server] Forced shutdown after timeout");
      process.exit(1);
    }, 10_000).unref();
  };

  process.on("SIGINT", () => shutdown("SIGINT"));
  process.on("SIGTERM", () => shutdown("SIGTERM"));
}

bootstrap();
