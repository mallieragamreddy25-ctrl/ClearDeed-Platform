/**
 * Initial Database Migration
 * Creates all core tables for ClearDeed platform
 */

import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateInitialSchema1700000000000 implements MigrationInterface {
  name = 'CreateInitialSchema1700000000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Create ENUM types
    await queryRunner.query(
      `CREATE TYPE "public"."user_role" AS ENUM('buyer', 'seller', 'investor')`,
    );
    await queryRunner.query(
      `CREATE TYPE "public"."property_category" AS ENUM('land', 'individual_house', 'commercial', 'agriculture')`,
    );
    await queryRunner.query(
      `CREATE TYPE "public"."property_status" AS ENUM('submitted', 'under_verification', 'verified', 'live', 'sold', 'rejected')`,
    );
    await queryRunner.query(
      `CREATE TYPE "public"."deal_status" AS ENUM('created', 'pending_verification', 'verified', 'active', 'closed')`,
    );
    await queryRunner.query(
      `CREATE TYPE "public"."referral_partner_type" AS ENUM('agent', 'verified_user')`,
    );
    await queryRunner.query(
      `CREATE TYPE "public"."commission_type" AS ENUM('buyer_fee', 'seller_fee', 'platform_fee', 'referral_fee')`,
    );
    await queryRunner.query(
      `CREATE TYPE "public"."verification_status" AS ENUM('pending', 'under_review', 'approved', 'rejected')`,
    );

    // Create users table
    await queryRunner.query(
      `CREATE TABLE "users" (
        "id" SERIAL PRIMARY KEY,
        "mobile_number" VARCHAR(20) UNIQUE NOT NULL,
        "otp_hash" VARCHAR(255),
        "otp_created_at" TIMESTAMP,
        "otp_attempts" INT DEFAULT 0,
        "otp_locked_until" TIMESTAMP,
        "full_name" VARCHAR(255),
        "email" VARCHAR(255) UNIQUE,
        "city" VARCHAR(100),
        "profile_type" "public"."user_role",
        "budget_range" VARCHAR(50),
        "net_worth_range" VARCHAR(50),
        "referral_mobile_number" VARCHAR(20),
        "referral_validated" BOOLEAN DEFAULT FALSE,
        "referred_by_mobile" VARCHAR(20),
        "is_active" BOOLEAN DEFAULT TRUE,
        "is_verified" BOOLEAN DEFAULT FALSE,
        "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        "last_login" TIMESTAMP,
        "session_token" VARCHAR(255),
        "token_expires_at" TIMESTAMP
      )`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_users_mobile" ON "users"("mobile_number")`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_users_email" ON "users"("email")`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_users_referral_mobile" ON "users"("referral_mobile_number")`,
    );

    // Create referral_partners table
    await queryRunner.query(
      `CREATE TABLE "referral_partners" (
        "id" SERIAL PRIMARY KEY,
        "user_id" INT REFERENCES "users"("id") ON DELETE SET NULL,
        "mobile_number" VARCHAR(20) UNIQUE NOT NULL,
        "partner_type" "public"."referral_partner_type" NOT NULL,
        "full_name" VARCHAR(255),
        "email" VARCHAR(255),
        "city" VARCHAR(100),
        "agent_license_number" VARCHAR(100),
        "agency_name" VARCHAR(255),
        "status" "public"."verification_status" DEFAULT 'pending',
        "is_active" BOOLEAN DEFAULT TRUE,
        "yearly_maintenance_fee_status" VARCHAR(50) DEFAULT 'unpaid',
        "maintenance_fee_renewal_date" DATE,
        "commission_enabled" BOOLEAN DEFAULT FALSE,
        "total_commission_earned" DECIMAL(12, 2) DEFAULT 0,
        "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_referral_partners_mobile" ON "referral_partners"("mobile_number")`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_referral_partners_user_id" ON "referral_partners"("user_id")`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_referral_partners_status" ON "referral_partners"("status")`,
    );

    // Create properties table
    await queryRunner.query(
      `CREATE TABLE "properties" (
        "id" SERIAL PRIMARY KEY,
        "seller_user_id" INT REFERENCES "users"("id") ON DELETE CASCADE,
        "category" "public"."property_category" NOT NULL,
        "title" VARCHAR(255) NOT NULL,
        "description" TEXT,
        "location" VARCHAR(255) NOT NULL,
        "city" VARCHAR(100),
        "pincode" VARCHAR(10),
        "price" DECIMAL(15, 2),
        "area" DECIMAL(10, 2),
        "area_unit" VARCHAR(10) DEFAULT 'sqft',
        "ownership_status" VARCHAR(100),
        "status" "public"."property_status" DEFAULT 'submitted',
        "is_verified" BOOLEAN DEFAULT FALSE,
        "verified_badge" BOOLEAN DEFAULT FALSE,
        "primary_image_url" TEXT,
        "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        "verified_at" TIMESTAMP
      )`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_properties_seller_user_id" ON "properties"("seller_user_id")`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_properties_status" ON "properties"("status")`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_properties_city" ON "properties"("city")`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_properties_category" ON "properties"("category")`,
    );

    // Create property_verifications table
    await queryRunner.query(
      `CREATE TABLE "property_verifications" (
        "id" SERIAL PRIMARY KEY,
        "property_id" INT REFERENCES "properties"("id") ON DELETE CASCADE,
        "verified_by_admin_id" INT REFERENCES "users"("id") ON DELETE SET NULL,
        "verification_status" "public"."verification_status" DEFAULT 'pending',
        "verified_documents" TEXT[],
        "verification_notes" TEXT,
        "rejection_reason" TEXT,
        "verified_at" TIMESTAMP,
        "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_property_verifications_property_id" ON "property_verifications"("property_id")`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_property_verifications_status" ON "property_verifications"("verification_status")`,
    );

    // Create property_documents table
    await queryRunner.query(
      `CREATE TABLE "property_documents" (
        "id" SERIAL PRIMARY KEY,
        "property_id" INT REFERENCES "properties"("id") ON DELETE CASCADE,
        "document_type" VARCHAR(100),
        "document_name" VARCHAR(255),
        "document_url" TEXT,
        "uploaded_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_property_documents_property_id" ON "property_documents"("property_id")`,
    );

    // Create property_gallery table
    await queryRunner.query(
      `CREATE TABLE "property_gallery" (
        "id" SERIAL PRIMARY KEY,
        "property_id" INT REFERENCES "properties"("id") ON DELETE CASCADE,
        "image_url" TEXT NOT NULL,
        "image_title" VARCHAR(255),
        "display_order" INT,
        "uploaded_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_property_gallery_property_id" ON "property_gallery"("property_id")`,
    );

    // Create projects table
    await queryRunner.query(
      `CREATE TABLE "projects" (
        "id" SERIAL PRIMARY KEY,
        "admin_user_id" INT REFERENCES "users"("id") ON DELETE SET NULL,
        "title" VARCHAR(255) NOT NULL,
        "description" TEXT,
        "location" VARCHAR(255),
        "city" VARCHAR(100),
        "capital_required" DECIMAL(15, 2),
        "minimum_investment" DECIMAL(12, 2),
        "roi_estimate" DECIMAL(5, 2),
        "timeline_months" INT,
        "status" "public"."property_status" DEFAULT 'submitted',
        "is_verified" BOOLEAN DEFAULT FALSE,
        "verified_badge" BOOLEAN DEFAULT FALSE,
        "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        "verified_at" TIMESTAMP
      )`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_projects_admin_user_id" ON "projects"("admin_user_id")`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_projects_status" ON "projects"("status")`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_projects_city" ON "projects"("city")`,
    );

    // Create express_interests table
    await queryRunner.query(
      `CREATE TABLE "express_interests" (
        "id" SERIAL PRIMARY KEY,
        "user_id" INT REFERENCES "users"("id") ON DELETE CASCADE,
        "property_id" INT REFERENCES "properties"("id") ON DELETE CASCADE,
        "project_id" INT REFERENCES "projects"("id") ON DELETE CASCADE,
        "user_role" "public"."user_role",
        "interest_date" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        "is_active" BOOLEAN DEFAULT TRUE
      )`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_express_interests_user_id" ON "express_interests"("user_id")`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_express_interests_property_id" ON "express_interests"("property_id")`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_express_interests_project_id" ON "express_interests"("project_id")`,
    );

    // Create deals table
    await queryRunner.query(
      `CREATE TABLE "deals" (
        "id" SERIAL PRIMARY KEY,
        "created_by_admin_id" INT REFERENCES "users"("id") ON DELETE SET NULL,
        "buyer_user_id" INT NOT NULL REFERENCES "users"("id") ON DELETE CASCADE,
        "seller_user_id" INT NOT NULL REFERENCES "users"("id") ON DELETE CASCADE,
        "property_id" INT REFERENCES "properties"("id") ON DELETE SET NULL,
        "project_id" INT REFERENCES "projects"("id") ON DELETE SET NULL,
        "status" "public"."deal_status" DEFAULT 'created',
        "deal_closed_at" TIMESTAMP,
        "transaction_value" DECIMAL(15, 2),
        "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_deals_buyer_user_id" ON "deals"("buyer_user_id")`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_deals_seller_user_id" ON "deals"("seller_user_id")`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_deals_property_id" ON "deals"("property_id")`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_deals_status" ON "deals"("status")`,
    );

    // Create deal_referral_mappings table
    await queryRunner.query(
      `CREATE TABLE "deal_referral_mappings" (
        "id" SERIAL PRIMARY KEY,
        "deal_id" INT REFERENCES "deals"("id") ON DELETE CASCADE,
        "referral_partner_id" INT REFERENCES "referral_partners"("id") ON DELETE CASCADE,
        "side" VARCHAR(10),
        "commission_percentage" DECIMAL(5, 2),
        "commission_locked_at" TIMESTAMP,
        "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_deal_referral_mappings_deal_id" ON "deal_referral_mappings"("deal_id")`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_deal_referral_mappings_referral_partner_id" ON "deal_referral_mappings"("referral_partner_id")`,
    );

    // Create commission_ledgers table
    await queryRunner.query(
      `CREATE TABLE "commission_ledgers" (
        "id" SERIAL PRIMARY KEY,
        "deal_id" INT REFERENCES "deals"("id") ON DELETE CASCADE,
        "referral_partner_id" INT REFERENCES "referral_partners"("id") ON DELETE SET NULL,
        "commission_type" "public"."commission_type" NOT NULL,
        "amount" DECIMAL(12, 2),
        "percentage_applied" DECIMAL(5, 2),
        "status" VARCHAR(50) DEFAULT 'pending',
        "payment_date" TIMESTAMP,
        "payment_reference" VARCHAR(255),
        "notes" TEXT,
        "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_commission_ledgers_deal_id" ON "commission_ledgers"("deal_id")`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_commission_ledgers_referral_partner_id" ON "commission_ledgers"("referral_partner_id")`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_commission_ledgers_status" ON "commission_ledgers"("status")`,
    );

    // Create agent_maintenance table
    await queryRunner.query(
      `CREATE TABLE "agent_maintenance" (
        "id" SERIAL PRIMARY KEY,
        "referral_partner_id" INT REFERENCES "referral_partners"("id") ON DELETE CASCADE,
        "fee_amount" DECIMAL(10, 2) DEFAULT 999,
        "payment_date" TIMESTAMP,
        "payment_reference" VARCHAR(255),
        "fee_expiry_date" DATE,
        "is_active" BOOLEAN DEFAULT FALSE,
        "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_agent_maintenance_referral_partner_id" ON "agent_maintenance"("referral_partner_id")`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_agent_maintenance_is_active" ON "agent_maintenance"("is_active")`,
    );

    // Create notifications table
    await queryRunner.query(
      `CREATE TABLE "notifications" (
        "id" SERIAL PRIMARY KEY,
        "user_id" INT REFERENCES "users"("id") ON DELETE CASCADE,
        "notification_type" VARCHAR(100),
        "title" VARCHAR(255),
        "body" TEXT,
        "channel" VARCHAR(50) DEFAULT 'sms',
        "recipient_mobile" VARCHAR(20),
        "recipient_email" VARCHAR(255),
        "sent_at" TIMESTAMP,
        "delivery_status" VARCHAR(50) DEFAULT 'pending',
        "delivery_attempts" INT DEFAULT 0,
        "last_attempt_at" TIMESTAMP,
        "related_deal_id" INT REFERENCES "deals"("id") ON DELETE SET NULL,
        "related_property_id" INT REFERENCES "properties"("id") ON DELETE SET NULL,
        "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_notifications_user_id" ON "notifications"("user_id")`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_notifications_delivery_status" ON "notifications"("delivery_status")`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_notifications_created_at" ON "notifications"("created_at")`,
    );

    // Create admin_activity_logs table
    await queryRunner.query(
      `CREATE TABLE "admin_activity_logs" (
        "id" SERIAL PRIMARY KEY,
        "admin_user_id" INT REFERENCES "users"("id") ON DELETE SET NULL,
        "action_type" VARCHAR(100),
        "related_entity_type" VARCHAR(100),
        "related_entity_id" INT,
        "action_details" JSONB,
        "ip_address" VARCHAR(45),
        "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_admin_activity_logs_admin_user_id" ON "admin_activity_logs"("admin_user_id")`,
    );
    await queryRunner.query(
      `CREATE INDEX "idx_admin_activity_logs_created_at" ON "admin_activity_logs"("created_at")`,
    );

    // Create update_timestamp trigger function
    await queryRunner.query(`
      CREATE OR REPLACE FUNCTION update_timestamp()
      RETURNS TRIGGER AS $$
      BEGIN
        NEW.updated_at = CURRENT_TIMESTAMP;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    `);

    // Apply triggers
    await queryRunner.query(
      `CREATE TRIGGER trigger_users_updated_at BEFORE UPDATE ON "users" FOR EACH ROW EXECUTE FUNCTION update_timestamp()`,
    );
    await queryRunner.query(
      `CREATE TRIGGER trigger_referral_partners_updated_at BEFORE UPDATE ON "referral_partners" FOR EACH ROW EXECUTE FUNCTION update_timestamp()`,
    );
    await queryRunner.query(
      `CREATE TRIGGER trigger_properties_updated_at BEFORE UPDATE ON "properties" FOR EACH ROW EXECUTE FUNCTION update_timestamp()`,
    );
    await queryRunner.query(
      `CREATE TRIGGER trigger_deals_updated_at BEFORE UPDATE ON "deals" FOR EACH ROW EXECUTE FUNCTION update_timestamp()`,
    );
    await queryRunner.query(
      `CREATE TRIGGER trigger_commission_ledgers_updated_at BEFORE UPDATE ON "commission_ledgers" FOR EACH ROW EXECUTE FUNCTION update_timestamp()`,
    );
    await queryRunner.query(
      `CREATE TRIGGER trigger_agent_maintenance_updated_at BEFORE UPDATE ON "agent_maintenance" FOR EACH ROW EXECUTE FUNCTION update_timestamp()`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Drop triggers
    await queryRunner.query(`DROP TRIGGER IF EXISTS trigger_agent_maintenance_updated_at ON "agent_maintenance"`);
    await queryRunner.query(`DROP TRIGGER IF EXISTS trigger_commission_ledgers_updated_at ON "commission_ledgers"`);
    await queryRunner.query(`DROP TRIGGER IF EXISTS trigger_deals_updated_at ON "deals"`);
    await queryRunner.query(`DROP TRIGGER IF EXISTS trigger_properties_updated_at ON "properties"`);
    await queryRunner.query(`DROP TRIGGER IF EXISTS trigger_referral_partners_updated_at ON "referral_partners"`);
    await queryRunner.query(`DROP TRIGGER IF EXISTS trigger_users_updated_at ON "users"`);

    // Drop function
    await queryRunner.query(`DROP FUNCTION IF EXISTS update_timestamp()`);

    // Drop tables (in reverse order of creation)
    await queryRunner.query(`DROP TABLE IF EXISTS "admin_activity_logs"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "notifications"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "agent_maintenance"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "commission_ledgers"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "deal_referral_mappings"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "deals"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "express_interests"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "projects"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "property_gallery"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "property_documents"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "property_verifications"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "properties"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "referral_partners"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "users"`);

    // Drop ENUM types
    await queryRunner.query(`DROP TYPE IF EXISTS "public"."verification_status"`);
    await queryRunner.query(`DROP TYPE IF EXISTS "public"."commission_type"`);
    await queryRunner.query(`DROP TYPE IF EXISTS "public"."referral_partner_type"`);
    await queryRunner.query(`DROP TYPE IF EXISTS "public"."deal_status"`);
    await queryRunner.query(`DROP TYPE IF EXISTS "public"."property_status"`);
    await queryRunner.query(`DROP TYPE IF EXISTS "public"."property_category"`);
    await queryRunner.query(`DROP TYPE IF EXISTS "public"."user_role"`);
  }
}
