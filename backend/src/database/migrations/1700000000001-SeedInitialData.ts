/**
 * Seed Data Migration
 * Adds sample data for testing and development
 */

import { MigrationInterface, QueryRunner } from 'typeorm';

export class SeedInitialData1700000000001 implements MigrationInterface {
  name = 'SeedInitialData1700000000001';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Add admin user
    await queryRunner.query(`
      INSERT INTO "users" (
        mobile_number, full_name, email, city, profile_type, 
        is_active, is_verified, created_at, updated_at
      ) VALUES (
        '+919999999999', 'Admin User', 'admin@cleardeed.com', 'Mumbai', 'buyer',
        true, true, NOW(), NOW()
      )
      ON CONFLICT (mobile_number) DO NOTHING
    `);

    // Add sample buyers
    await queryRunner.query(`
      INSERT INTO "users" (
        mobile_number, full_name, email, city, profile_type,
        budget_range, is_active, is_verified, created_at, updated_at
      ) VALUES 
        ('+91', 'Buyer One', 'buyer1@example.com', 'Mumbai', 'buyer', '50L-1Cr', true, true, NOW(), NOW()),
        ('+912', 'Buyer Two', 'buyer2@example.com', 'Bangalore', 'buyer', '1Cr-2Cr', true, false, NOW(), NOW())
      ON CONFLICT (mobile_number) DO NOTHING
    `);

    // Add sample sellers
    await queryRunner.query(`
      INSERT INTO "users" (
        mobile_number, full_name, email, city, profile_type,
        is_active, is_verified, created_at, updated_at
      ) VALUES 
        ('+913', 'Seller One', 'seller1@example.com', 'Mumbai', 'seller', true, true, NOW(), NOW()),
        ('+914', 'Seller Two', 'seller2@example.com', 'Bangalore', 'seller', true, false, NOW(), NOW())
      ON CONFLICT (mobile_number) DO NOTHING
    `);

    // Add sample properties
    await queryRunner.query(`
      INSERT INTO "properties" (
        seller_user_id, category, title, description, location, city,
        pincode, price, area, area_unit, ownership_status, status,
        is_verified, verified_badge, created_at, updated_at
      ) VALUES 
        (
          (SELECT id FROM "users" WHERE mobile_number = '+913' LIMIT 1),
          'land', 
          'Premium Land in Bandra', 
          'Beautiful 5000 sqft land plot',
          'Bandra, Mumbai', 'Mumbai', '400050',
          50000000, 5000, 'sqft', 'owned',
          'submitted', false, false, NOW(), NOW()
        ),
        (
          (SELECT id FROM "users" WHERE mobile_number = '+914' LIMIT 1),
          'individual_house',
          '3 BHK House in BTM Layout',
          'Spacious 3 bedroom house with garden',
          'BTM Layout, Bangalore', 'Bangalore', '560068',
          10000000, 2500, 'sqft', 'owned',
          'submitted', false, false, NOW(), NOW()
        )
      ON CONFLICT DO NOTHING
    `);

    // Add sample referral partners
    await queryRunner.query(`
      INSERT INTO "referral_partners" (
        mobile_number, partner_type, full_name, email, city,
        agent_license_number, agency_name, status, is_active,
        commission_enabled, created_at, updated_at
      ) VALUES 
        (
          '+919000000001', 'agent', 'John Agent', 'john@agents.com',
          'Mumbai', 'AGENT001', 'Premier Agents', 'pending', true,
          false, NOW(), NOW()
        ),
        (
          '+919000000002', 'agent', 'Sarah Agent', 'sarah@agents.com',
          'Bangalore', 'AGENT002', 'Elite Realty', 'approved', true,
          true, NOW(), NOW()
        )
      ON CONFLICT (mobile_number) DO NOTHING
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Delete seed data in reverse order of creation
    await queryRunner.query(`DELETE FROM "referral_partners" WHERE mobile_number LIKE '+919%'`);
    await queryRunner.query(`DELETE FROM "properties" WHERE created_at IS NOT NULL AND created_at > NOW() - INTERVAL '1 day'`);
    await queryRunner.query(`DELETE FROM "users" WHERE mobile_number IN ('+91', '+912', '+913', '+914', '+919999999999')`);
  }
}
