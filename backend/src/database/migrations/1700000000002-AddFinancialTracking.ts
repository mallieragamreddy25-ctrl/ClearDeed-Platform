/**
 * Add agent maintenance and commission fields migration
 * Adds financial tracking fields
 */

import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddFinancialTracking1700000000002 implements MigrationInterface {
  name = 'AddFinancialTracking1700000000002';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Add columns for commission tracking
    await queryRunner.query(`
      ALTER TABLE "referral_partners"
      ADD COLUMN IF NOT EXISTS "total_commissions_pending" DECIMAL(12, 2) DEFAULT 0,
      ADD COLUMN IF NOT EXISTS "total_commissions_earned" DECIMAL(12, 2) DEFAULT 0,
      ADD COLUMN IF NOT EXISTS "last_commission_date" TIMESTAMP
    `);

    // Add columns for deal tracking
    await queryRunner.query(`
      ALTER TABLE "deals"
      ADD COLUMN IF NOT EXISTS "buyer_reference_code" VARCHAR(50),
      ADD COLUMN IF NOT EXISTS "seller_reference_code" VARCHAR(50),
      ADD COLUMN IF NOT EXISTS "verified_at" TIMESTAMP,
      ADD COLUMN IF NOT EXISTS "notes" TEXT
    `);

    // Create index for tracking
    await queryRunner.query(`
      CREATE INDEX IF NOT EXISTS "idx_referral_partners_total_earned" 
      ON "referral_partners"("total_commission_earned")
    `);

    await queryRunner.query(`
      CREATE INDEX IF NOT EXISTS "idx_deals_reference_codes"
      ON "deals"("buyer_reference_code", "seller_reference_code")
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DROP INDEX IF EXISTS "idx_deals_reference_codes"`
    );
    await queryRunner.query(
      `DROP INDEX IF EXISTS "idx_referral_partners_total_earned"`
    );

    await queryRunner.query(`
      ALTER TABLE "deals"
      DROP COLUMN IF EXISTS "notes",
      DROP COLUMN IF EXISTS "verified_at",
      DROP COLUMN IF EXISTS "seller_reference_code",
      DROP COLUMN IF EXISTS "buyer_reference_code"
    `);

    await queryRunner.query(`
      ALTER TABLE "referral_partners"
      DROP COLUMN IF EXISTS "last_commission_date",
      DROP COLUMN IF EXISTS "total_commissions_earned",
      DROP COLUMN IF EXISTS "total_commissions_pending"
    `);
  }
}
