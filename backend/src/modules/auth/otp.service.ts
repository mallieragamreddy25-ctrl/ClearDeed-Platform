/**
 * OTP Service - Handles OTP generation, storage, and verification
 * Features:
 * - 6-digit OTP generation
 * - OTP storage with expiration
 * - Rate limiting (5 attempts in 10 minutes)
 * - OTP verification
 */

import { Injectable } from '@nestjs/common';
import { InvalidOtpException, RateLimitExceededException } from './auth.exceptions';
import { OTP_EXPIRY, MAX_OTP_ATTEMPTS, RATE_LIMIT_WINDOW, OTP_LENGTH } from './constants';

interface OtpRecord {
  otp: string;
  expiresAt: number;
  attempts: number;
  createdAt: number;
}

@Injectable()
export class OtpService {
  private otpStore: Map<string, OtpRecord> = new Map();
  private attemptTracker: Map<string, number[]> = new Map(); // Track timestamps of attempts

  /**
   * Generate a 6-digit random OTP
   * @returns 6-digit OTP string
   */
  generateOtp(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  /**
   * Store OTP with expiration for a mobile number
   * @param mobile - Mobile number
   * @param otp - OTP code
   * @param expiresIn - Expiration time in seconds (default: 600s = 10 minutes)
   */
  storeOtp(mobile: string, otp: string, expiresIn: number = OTP_EXPIRY): void {
    const now = Date.now();
    const expiresAt = now + expiresIn * 1000;

    this.otpStore.set(mobile, {
      otp,
      expiresAt,
      attempts: 0,
      createdAt: now,
    });

    console.log(`[OTP] Generated for ${mobile}: ${otp} (Expires in ${expiresIn}s)`);
  }

  /**
   * Verify OTP for a mobile number
   * @param mobile - Mobile number
   * @param otp - OTP to verify
   * @returns true if OTP is valid, false otherwise
   * @throws InvalidOtpException if OTP is invalid or expired
   */
  verifyOtp(mobile: string, otp: string): boolean {
    const record = this.otpStore.get(mobile);

    if (!record) {
      throw new InvalidOtpException('OTP not found or expired');
    }

    const now = Date.now();

    // Check if OTP has expired
    if (now > record.expiresAt) {
      this.otpStore.delete(mobile);
      throw new InvalidOtpException('OTP has expired');
    }

    // Check attempt limit
    if (record.attempts >= MAX_OTP_ATTEMPTS) {
      this.otpStore.delete(mobile);
      throw new InvalidOtpException(`Maximum OTP verification attempts (${MAX_OTP_ATTEMPTS}) exceeded`);
    }

    // Increment attempts
    record.attempts++;

    // Verify OTP
    if (record.otp !== otp) {
      throw new InvalidOtpException('Invalid OTP');
    }

    // OTP is valid, remove from store
    this.otpStore.delete(mobile);
    return true;
  }

  /**
   * Check rate limit for OTP requests
   * Throws exception if 5+ attempts in 10-minute window
   * @param mobile - Mobile number
   * @throws RateLimitExceededException if limit exceeded
   */
  rateLimitCheck(mobile: string): void {
    const now = Date.now();
    const windowStart = now - RATE_LIMIT_WINDOW * 1000;

    // Get or initialize attempt timestamps for this mobile
    if (!this.attemptTracker.has(mobile)) {
      this.attemptTracker.set(mobile, []);
    }

    const attempts = this.attemptTracker.get(mobile)!;

    // Remove old attempts outside the window
    const recentAttempts = attempts.filter((timestamp) => timestamp > windowStart);

    // Check if limit exceeded
    if (recentAttempts.length >= MAX_OTP_ATTEMPTS) {
      console.log(`[RATE_LIMIT] ${mobile} exceeded ${MAX_OTP_ATTEMPTS} attempts in ${RATE_LIMIT_WINDOW}s`);
      throw new RateLimitExceededException(
        `Too many OTP requests. Maximum ${MAX_OTP_ATTEMPTS} attempts allowed in ${RATE_LIMIT_WINDOW} seconds. Please try again later.`,
      );
    }

    // Add current attempt
    recentAttempts.push(now);
    this.attemptTracker.set(mobile, recentAttempts);
  }

  /**
   * Cleanup expired OTPs periodically
   * Called automatically every 5 minutes
   */
  private cleanupExpiredOtps(): void {
    const now = Date.now();
    let cleaned = 0;

    for (const [mobile, record] of this.otpStore.entries()) {
      if (now > record.expiresAt) {
        this.otpStore.delete(mobile);
        cleaned++;
      }
    }

    if (cleaned > 0) {
      console.log(`[OTP] Cleaned up ${cleaned} expired OTPs`);
    }
  }

  /**
   * Initialize periodic cleanup (call in module initialization)
   */
  initCleanup(): void {
    setInterval(() => this.cleanupExpiredOtps(), 5 * 60 * 1000); // Every 5 minutes
  }

  /**
   * Normalize phone number to E.164 format
   */
  private normalizePhoneNumber(phone: string): string {
    let normalized = phone.replace(/\D/g, '');
    
    if (normalized.length === 10) {
      normalized = '91' + normalized;
    } else if (normalized.length === 12 && !normalized.startsWith('91')) {
      if (!normalized.startsWith('91')) {
        normalized = '91' + normalized;
      }
      normalized = '+' + normalized;
    }

    return normalized;
  }
}
