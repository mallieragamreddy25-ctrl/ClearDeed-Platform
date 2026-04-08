/**
 * Auth Module
 * 
 * Complete OTP-based authentication module with:
 * - 6-digit OTP generation and verification
 * - 10-minute OTP expiry
 * - Rate limiting (5 attempts per 10-minute window)
 * - JWT token generation (HS256, 24-hour validity)
 * - In-memory user storage
 * 
 * Imports: JwtModule, PassportModule
 * Exports: AuthService, JwtAuthGuard
 */

import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { OtpService } from './otp.service';
import { JwtStrategy } from './jwt.strategy';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { User } from '../../database/entities/user.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([User]),
    PassportModule,
    JwtModule.register({
      secret: process.env.JWT_SECRET || 'your-secret-key-change-in-production',
      signOptions: {
        expiresIn: '24h',
        algorithm: 'HS256',
      },
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService, OtpService, JwtStrategy, JwtAuthGuard],
  exports: [AuthService, JwtAuthGuard, OtpService],
})
export class AuthModule {}
