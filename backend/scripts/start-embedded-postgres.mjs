import path from 'node:path';
import { fileURLToPath } from 'node:url';
import fs from 'node:fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function main() {
  const { default: EmbeddedPostgres } = await import('embedded-postgres');

  const port = parseInt(process.env.DB_PORT || '5432', 10);
  const user = process.env.DB_USERNAME || 'cleardeed';
  const password = process.env.DB_PASSWORD || 'cleardeed123';
  const database = process.env.DB_NAME || 'cleardeed_db';
  const databaseDir = path.resolve(__dirname, '..', '.local', 'postgres-data');
  const pgVersionPath = path.join(databaseDir, 'PG_VERSION');

  const postgres = new EmbeddedPostgres({
    databaseDir,
    port,
    user,
    password,
    persistent: true,
    onLog: (message) => {
      console.log(`[embedded-postgres] ${String(message)}`);
    },
    onError: (messageOrError) => {
      console.error('[embedded-postgres:error]', messageOrError);
    },
  });

  if (!fs.existsSync(pgVersionPath)) {
    await postgres.initialise();
  } else {
    console.log('[embedded-postgres] existing data directory detected, skipping initdb');
  }
  await postgres.start();

  try {
    await postgres.createDatabase(database);
    console.log(`[embedded-postgres] created database "${database}"`);
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    if (!message.toLowerCase().includes('already exists')) {
      throw error;
    }
    console.log(`[embedded-postgres] database "${database}" already exists`);
  }

  console.log(
    `[embedded-postgres] ready on postgres://${user}:***@localhost:${port}/${database}`,
  );

  const shutdown = async (signal) => {
    console.log(`[embedded-postgres] received ${signal}, shutting down`);
    await postgres.stop();
    process.exit(0);
  };

  process.on('SIGINT', () => {
    void shutdown('SIGINT');
  });
  process.on('SIGTERM', () => {
    void shutdown('SIGTERM');
  });

  await new Promise(() => {
    // Keep the process alive until it is terminated.
  });
}

main().catch((error) => {
  console.error('[embedded-postgres] failed to start', error);
  process.exit(1);
});
