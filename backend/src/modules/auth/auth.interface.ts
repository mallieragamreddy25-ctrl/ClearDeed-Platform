/**
 * Auth Module - TypeScript Interfaces
 * 
 * Defines types for OTP, JWT tokens, user data, and auth responses
 */

export interface IOtpStore {
  otp: string;
  createdAt: number;
  attempts: number;
  lastAttemptAt: number;
  lastSentAt: number;
}

export interface IOtpCache {
  [key: string]: IOtpStore;
}

export interface IUserPayload {
  mobile_number: string;
  id?: string;
  iat?: number;
  exp?: number;
}

export interface IAuthUser {
  id: string;
  mobile_number: string;
  created_at: string;
}

export interface ISendOtpResponse {
  success: boolean;
  message: string;
}

export interface IVerifyOtpResponse {
  token: string;
  user: IAuthUser;
}

export interface ILogoutResponse {
  success: boolean;
}

export interface IJwtPayload {
  sub: string;
  mobile_number: string;
  iat: number;
  exp: number;
}
