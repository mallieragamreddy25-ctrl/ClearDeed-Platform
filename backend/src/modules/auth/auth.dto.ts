/**
 * Authentication DTOs (Data Transfer Objects)
 */

import { IsString, IsPhoneNumber } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

/**
 * DTO for sending OTP request
 */
export class SendOtpDto {
  @ApiProperty({
    description: 'Mobile number in E.164 format (e.g., +919876543210)',
    example: '+919876543210',
  })
  @IsString({ message: 'Mobile must be a string' })
  @IsPhoneNumber('IN', { message: 'Mobile must be a valid phone number' })
  mobile: string;
}

/**
 * DTO for verifying OTP request
 */
export class VerifyOtpDto {
  @ApiProperty({
    description: 'Mobile number in E.164 format',
    example: '+919876543210',
  })
  @IsString({ message: 'Mobile must be a string' })
  @IsPhoneNumber('IN', { message: 'Mobile must be a valid phone number' })
  mobile: string;

  @ApiProperty({
    description: '6-digit OTP code',
    example: '123456',
  })
  @IsString({ message: 'OTP must be a string' })
  otp: string;
}

/**
 * User data returned in auth response
 */
export class UserDataDto {
  @ApiProperty({ example: 'user-123' })
  id: string;

  @ApiProperty({ example: '+919876543210' })
  mobile: string;

  @ApiProperty({ example: 'John Doe' })
  name?: string;
}

/**
 * DTO for successful OTP send response
 */
export class AuthResponseDto {
  @ApiProperty({ example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' })
  access_token: string;

  @ApiProperty()
  user: UserDataDto;
}

/**
 * Send OTP Response DTO
 * 
 * Success response when OTP is sent
 */
export class SendOtpResponseDto {
  @ApiProperty({
    description: 'Success message',
    example: 'OTP sent successfully',
  })
  message: string;

  @ApiProperty({
    description: 'Phone number where OTP was sent',
    example: '+919876543210',
  })
  phone: string;

  @ApiProperty({
    description: 'OTP expiry time in seconds',
    example: 600,
  })
  expiresIn: number;
}

/**
 * Error Response DTO
 * 
 * Used for error responses with appropriate status codes
 */
export class ErrorResponseDto {
  @ApiProperty({
    description: 'HTTP status code',
    example: 401,
  })
  statusCode: number;

  @ApiProperty({
    description: 'Error message',
    example: 'Invalid OTP',
  })
  message: string;

  @ApiProperty({
    description: 'Error code for client-side handling',
    example: 'INVALID_OTP',
  })
  code: string;

  @ApiPropertyOptional({
    description: 'Additional error details',
    example: { retries: 3 },
  })
  details?: Record<string, any>;
}

/**
 * JWT Payload DTO
 * 
 * Used internally for JWT token creation
 */
export class JwtPayloadDto {
  sub: string; // User ID
  email: string;
  phone: string;
  iat?: number;
  exp?: number;
}
