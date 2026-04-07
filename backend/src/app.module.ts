import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { DataSourceInstance } from './database/data-source';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { PropertiesModule } from './modules/properties/properties.module';
import { CommissionsModule } from './modules/commissions/commissions.module';
import { ReferralPartnersModule } from './modules/referral-partners/referral-partners.module';
import { AdminModule } from './modules/admin/admin.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import { APP_FILTER } from '@nestjs/core';

/**
 * App Module - Root Module
 * 
 * Imports:
 * - ConfigModule: Environment variables
 * - TypeOrmModule: Database connection
 * - AuthModule: OTP authentication
 * - UsersModule: User management
 * - PropertiesModule: Property management
 * - CommissionsModule: Commission tracking and reporting
 * - AdminModule: Admin user management and activity logging
 * 
 * Global configurations:
 * - HTTP Exception Filter: Unified error handling
 * - API prefix: /v1
 * 
 * Ready for Phase 1 + Admin & Commissions Modules production
 */
@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT || '5432', 10),
      username: process.env.DB_USERNAME || 'cleardeed',
      password: process.env.DB_PASSWORD || 'cleardeed123',
      database: process.env.DB_NAME || 'cleardeed_db',
      entities: [__dirname + '/database/entities/*.entity{.ts,.js}'],
      migrations: [__dirname + '/database/migrations/*{.ts,.js}'],
      migrationsTableName: 'typeorm_migrations',
      synchronize: process.env.NODE_ENV !== 'production',
      logging: process.env.NODE_ENV !== 'production',
      maxQueryExecutionTime: 1000,
    }),
    AuthModule,
    UsersModule,
    PropertiesModule,
    ReferralPartnersModule,
    CommissionsModule,
    AdminModule,
    NotificationsModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    {
      provide: APP_FILTER,
      useClass: HttpExceptionFilter,
    },
  ],
})
export class AppModule {}
