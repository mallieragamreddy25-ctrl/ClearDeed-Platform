/**
 * Add payment and audit fields migration
 * Adds payment tracking and audit trail fields
 */

import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddPaymentAndAudit1700000000003 implements MigrationInterface {
  name = 'AddPaymentAndAudit1700000000003';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Add columns for payment tracking
    await queryRunner.query(`
      ALTER TABLE "commission_ledgers"
      ADD COLUMN IF NOT EXISTS "payment_gateway" VARCHAR(100),
      ADD COLUMN IF NOT EXISTS "transaction_id" VARCHAR(255),
      ADD COLUMN IF NOT EXISTS "approved_by_admin_id" INT REFERENCES "users"("id") ON DELETE SET NULL,
      ADD COLUMN IF NOT EXISTS "approved_at" TIMESTAMP
    `);

    // Add audit columns
    await queryRunner.query(`
      ALTER TABLE "admin_activity_logs"
      ADD COLUMN IF NOT EXISTS "changes" JSONB,
      ADD COLUMN IF NOT EXISTS "status" VARCHAR(50) DEFAULT 'completed'
    `);

    // Create indexes
    await queryRunner.query(`
      CREATE INDEX IF NOT EXISTS "idx_commission_ledgers_transaction"
      ON "commission_ledgers"("transaction_id")
    `);

    await queryRunner.query(`
      CREATE INDEX IF NOT EXISTS "idx_commission_ledgers_approved"
      ON "commission_ledgers"("approved_by_admin_id", "approved_at")
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DROP INDEX IF EXISTS "idx_commission_ledgers_approved"`
    );
    await queryRunner.query(
      `DROP INDEX IF EXISTS "idx_commission_ledgers_transaction"`
    );

    await queryRunner.query(`
      ALTER TABLE "admin_activity_logs"
      DROP COLUMN IF EXISTS "status",
      DROP COLUMN IF EXISTS "changes"
    `);

    await queryRunner.query(`
      ALTER TABLE "commission_ledgers"
      DROP COLUMN IF EXISTS "approved_at",
      DROP COLUMN IF EXISTS "approved_by_admin_id",
      DROP COLUMN IF EXISTS "transaction_id",
      DROP COLUMN IF EXISTS "payment_gateway"
    `);
  }
}
