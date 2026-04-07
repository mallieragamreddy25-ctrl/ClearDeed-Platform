# NestJS Backend - Template Migrations

This directory contains database migrations.

Migrations are TypeORM migrations that manage schema changes over time.

## Creating a Migration

```bash
npm run typeorm migration:create src/database/migrations/InitialSchema
```

## Running Migrations

```bash
npm run migrate
```

## Reverting Migrations

```bash
npm run typeorm migration:revert -d src/database/data-source.ts
```

## Template Structure

Each migration file should follow this pattern:

```typescript
import { MigrationInterface, QueryRunner } from 'typeorm';

export class InitialSchema1234567890 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    // Forward migration
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Rollback migration
  }
}
```

## Current Schema Version

Phase 1: Foundation & Core APIs - All 18 core tables schema initialized with `synchronize: true` in development.

**Note**: Production deployments should use migrations instead of synchronize.
