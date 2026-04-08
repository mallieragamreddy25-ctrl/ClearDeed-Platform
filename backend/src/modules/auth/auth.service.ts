/**
 * Auth Service - Core authentication business logic
 *
 * Handles:
 * - OTP generation and sending
 * - OTP verification and user authentication
 * - JWT token creation and validation
 * - Database-backed user registration and management
 * - Logout functionality
 */

import {
  Injectable,
  InternalServerErrorException,
  UnauthorizedException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { JwtService } from '@nestjs/jwt';
import { Repository } from 'typeorm';
import { OtpService } from './otp.service';
import { SendOtpDto, VerifyOtpDto, AuthResponseDto, UserDataDto } from './auth.dto';
import { OTP_EXPIRY } from './constants';
import { User } from '../../database/entities/user.entity';

@Injectable()
export class AuthService {
  constructor(
    private readonly otpService: OtpService,
    private readonly jwtService: JwtService,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  async sendOtp(sendOtpDto: SendOtpDto): Promise<{ message: string; expiresIn: number }> {
    const normalizedMobile = this.normalizeMobileNumber(sendOtpDto.mobile);

    try {
      this.otpService.rateLimitCheck(normalizedMobile);

      const otp = this.otpService.generateOtp();
      this.otpService.storeOtp(normalizedMobile, otp, OTP_EXPIRY);

      console.log(`[AUTH] OTP sent to ${normalizedMobile}: ${otp}`);

      return {
        message: 'OTP sent successfully',
        expiresIn: OTP_EXPIRY,
      };
    } catch (error) {
      if (error instanceof Error && 'getStatus' in error) {
        throw error;
      }
      throw new InternalServerErrorException('Failed to send OTP');
    }
  }

  async verifyOtp(verifyOtpDto: VerifyOtpDto): Promise<AuthResponseDto> {
    const normalizedMobile = this.normalizeMobileNumber(verifyOtpDto.mobile);

    try {
      this.otpService.verifyOtp(normalizedMobile, verifyOtpDto.otp);

      let user = await this.userRepository.findOne({
        where: { mobile_number: normalizedMobile },
      });

      if (!user) {
        user = this.userRepository.create({
          mobile_number: normalizedMobile,
          is_active: true,
          is_verified: false,
        });
        user = await this.userRepository.save(user);
      }

      const isAdmin = this.isConfiguredAdminMobile(normalizedMobile);
      const payload = {
        sub: user.id,
        mobile: normalizedMobile,
        isAdmin,
      };

      const access_token = this.jwtService.sign(payload);
      user.last_login = new Date();
      user.session_token = access_token;
      user.token_expires_at = new Date(Date.now() + 24 * 60 * 60 * 1000);

      user = await this.userRepository.save(user);

      const userData: UserDataDto = {
        id: user.id,
        mobile: user.mobile_number,
        name: user.full_name,
        isAdmin,
      };

      console.log(`[AUTH] User verified: ${user.id} (${normalizedMobile})`);

      return {
        access_token,
        user: userData,
      };
    } catch (error) {
      if (error instanceof Error && 'getStatus' in error) {
        throw error;
      }
      throw new InternalServerErrorException('Failed to verify OTP');
    }
  }

  async logout(userId: number): Promise<{ message: string }> {
    await this.userRepository.update(
      { id: userId },
      {
        session_token: null as any,
        token_expires_at: null as any,
      },
    );
    console.log(`[AUTH] User logout: ${userId}`);
    return { message: 'Logout successful' };
  }

  validateToken(token: string): any {
    try {
      return this.jwtService.verify(token);
    } catch {
      throw new UnauthorizedException('Invalid token');
    }
  }

  async getUserById(userId: number): Promise<User | null> {
    return this.userRepository.findOne({ where: { id: userId } });
  }

  private normalizeMobileNumber(mobile: string): string {
    let normalized = mobile.replace(/\D/g, '');

    if (normalized.startsWith('91') && normalized.length > 10) {
      normalized = normalized.slice(2);
    }

    if (normalized.startsWith('0')) {
      normalized = normalized.slice(1);
    }

    return normalized.slice(-10);
  }

  private isConfiguredAdminMobile(mobile: string): boolean {
    const configuredMobile = process.env.ADMIN_MOBILE_NUMBER;
    if (!configuredMobile) {
      return false;
    }

    return this.normalizeMobileNumber(configuredMobile) === mobile;
  }
}
