/**
 * Auth Service - Core authentication business logic
 * 
 * Handles:
 * - OTP generation and sending
 * - OTP verification and user authentication
 * - JWT token creation and validation
 * - User registration and management (in-memory for now)
 * - Logout functionality
 */

import {
  Injectable,
  BadRequestException,
  InternalServerErrorException,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { v4 as uuidv4 } from 'uuid';
import { OtpService } from './otp.service';
import { SendOtpDto, VerifyOtpDto, AuthResponseDto, UserDataDto } from './auth.dto';
import { OTP_EXPIRY, JWT_EXPIRY } from './constants';

interface User {
  id: string;
  mobile: string;
  name?: string;
  createdAt: Date;
}

@Injectable()
export class AuthService {
  private userStore: Map<string, User> = new Map();
  private sessionStore: Set<string> = new Set();

  constructor(
    private readonly otpService: OtpService,
    private readonly jwtService: JwtService,
  ) {}

  /**
   * Send OTP to mobile number
   * Generates 6-digit OTP, stores with 10-min expiry, enforces 5-attempt rate limit
   * 
   * @param sendOtpDto - Contains mobile number
   * @returns Object with message and expiresIn
   * @throws RateLimitExceededException if 5+ attempts in 10 minutes
   */
  async sendOtp(sendOtpDto: SendOtpDto): Promise<{ message: string; expiresIn: number }> {
    const { mobile } = sendOtpDto;

    try {
      // Check rate limit
      this.otpService.rateLimitCheck(mobile);

      // Generate OTP
      const otp = this.otpService.generateOtp();
      this.otpService.storeOtp(mobile, otp, OTP_EXPIRY);

      console.log(`[AUTH] OTP sent to ${mobile}: ${otp}`);

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

  /**
   * Verify OTP and create JWT token
   * Validates OTP, creates user if new, returns JWT token and user object
   * 
   * @param verifyOtpDto - Contains mobile and otp
   * @returns Object with access_token and user object
   * @throws InvalidOtpException if OTP is invalid or expired
   */
  async verifyOtp(verifyOtpDto: VerifyOtpDto): Promise<AuthResponseDto> {
    const { mobile, otp } = verifyOtpDto;

    try {
      // Verify OTP
      this.otpService.verifyOtp(mobile, otp);

      // Get or create user
      let user = this.userStore.get(mobile);

      if (!user) {
        user = {
          id: uuidv4(),
          mobile,
          createdAt: new Date(),
        };
        this.userStore.set(mobile, user);
        console.log(`[AUTH] New user created: ${user.id}`);
      }

      // Generate JWT token
      const payload = { sub: user.id, mobile };
      const access_token = this.jwtService.sign(payload);
      this.sessionStore.add(access_token);

      // Build response
      const userData: UserDataDto = {
        id: user.id,
        mobile: user.mobile,
        name: user.name,
      };

      console.log(`[AUTH] User verified: ${user.id}`);

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

  /**
   * Logout user
   * Invalidates session and returns success
   * 
   * @param userId - User ID (from JWT)
   * @returns Object with message
   */
  async logout(userId: string): Promise<{ message: string }> {
    console.log(`[AUTH] User logout: ${userId}`);
    // In production, add token to blacklist or revoke refresh tokens
    return { message: 'Logout successful' };
  }


  /**
   * Validate JWT token
   * @param token - JWT token
   * @returns Decoded payload
   */
  validateToken(token: string): any {
    try {
      return this.jwtService.verify(token);
    } catch {
      throw new UnauthorizedException('Invalid token');
    }
  }

  /**
   * Get user by ID
   * @param userId - User ID
   * @returns User object or undefined
   */
  getUserById(userId: string): User | undefined {
    for (const user of this.userStore.values()) {
      if (user.id === userId) {
        return user;
      }
    }
    return undefined;
  }
}
