import { DataSource, DataSourceOptions } from 'typeorm';
import * as dotenv from 'dotenv';
import { User } from './entities/user.entity';
import { ReferralPartner } from './entities/referral-partner.entity';
import { Property } from './entities/property.entity';
import { PropertyVerification } from './entities/property-verification.entity';
import { PropertyDocument } from './entities/property-document.entity';
import { PropertyGallery } from './entities/property-gallery.entity';
import { Project } from './entities/project.entity';
import { ExpressInterest } from './entities/express-interest.entity';
import { Deal } from './entities/deal.entity';
import { DealReferralMapping } from './entities/deal-referral-mapping.entity';
import { CommissionLedger } from './entities/commission-ledger.entity';
import { AgentMaintenance } from './entities/agent-maintenance.entity';
import { Notification } from './entities/notification.entity';
import { AdminActivityLog } from './entities/admin-activity-log.entity';
import { AdminUser } from './entities/admin-user.entity';

dotenv.config({
  path: `.env.${process.env.NODE_ENV || 'development'}`,
});
dotenv.config();

/**
 * TypeORM Data Source Configuration for PostgreSQL
 * 
 * Environment variables required:
 * - DB_HOST: Database host (default: localhost)
 * - DB_PORT: Database port (default: 5432)
 * - DB_USERNAME: Database username
 * - DB_PASSWORD: Database password
 * - DB_NAME: Database name
 * - NODE_ENV: Environment (development/production)
 */
const config: DataSourceOptions = {
  type: 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  username: process.env.DB_USERNAME || 'cleardeed',
  password: process.env.DB_PASSWORD || 'cleardeed123',
  database: process.env.DB_NAME || 'cleardeed_db',
  entities: [
    User,
    ReferralPartner,
    Property,
    PropertyVerification,
    PropertyDocument,
    PropertyGallery,
    Project,
    ExpressInterest,
    Deal,
    DealReferralMapping,
    CommissionLedger,
    AgentMaintenance,
    Notification,
    AdminActivityLog,
    AdminUser,
  ],
  migrations: ['src/database/migrations/*.ts'],
  migrationsTableName: 'typeorm_migrations',
  synchronize: process.env.NODE_ENV !== 'production', // Sync in dev, migrations in prod
  logging: process.env.NODE_ENV !== 'production',
  maxQueryExecutionTime: 1000, // Log slow queries
};

export const DataSourceInstance = new DataSource(config);
