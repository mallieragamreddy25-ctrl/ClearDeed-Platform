/**
 * Auth Controller
 * 
 * Endpoints:
 * - POST /auth/send-otp - Request body: { mobile: string } → Response: { message: string, expiresIn: number }
 * - POST /auth/verify-otp - Request body: { mobile: string, otp: string } → Response: { access_token: string, user: { id, mobile, name } }
 * - POST /auth/logout - Response: { message: string }
 */

import {
  Controller,
  Post,
  Body,
  UseGuards,
  Request,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { SendOtpDto, VerifyOtpDto, AuthResponseDto } from './auth.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';

@ApiTags('Authentication')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  /**
   * Send OTP to mobile number
   * Generates 6-digit OTP, stores with 10-min expiry, enforces 5-attempt rate limit
   */
  @Post('send-otp')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Send OTP',
    description: 'Sends 6-digit OTP to mobile number. Valid for 10 minutes. Max 5 requests per 10-minute window.',
  })
  @ApiResponse({
    status: 200,
    description: 'OTP sent successfully',
    schema: {
      properties: {
        message: { type: 'string', example: 'OTP sent successfully' },
        expiresIn: { type: 'number', example: 600 },
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Invalid mobile number' })
  @ApiResponse({ status: 429, description: 'Rate limit exceeded' })
  async sendOtp(@Body() sendOtpDto: SendOtpDto): Promise<{ message: string; expiresIn: number }> {
    return this.authService.sendOtp(sendOtpDto);
  }

  /**
   * Verify OTP and get JWT token
   * Validates OTP, creates user if new, returns JWT token and user object
   */
  @Post('verify-otp')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Verify OTP',
    description: 'Verifies OTP and returns JWT token. Max 5 verification attempts.',
  })
  @ApiResponse({
    status: 200,
    description: 'OTP verified successfully',
    type: AuthResponseDto,
  })
  @ApiResponse({ status: 400, description: 'OTP not found or expired' })
  @ApiResponse({ status: 401, description: 'Invalid OTP' })
  @ApiResponse({ status: 429, description: 'Too many attempts' })
  async verifyOtp(@Body() verifyOtpDto: VerifyOtpDto): Promise<AuthResponseDto> {
    return this.authService.verifyOtp(verifyOtpDto);
  }

  /**
   * Logout user
   * Invalidates session
   */
  @Post('logout')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Logout',
    description: 'Logs out the user by invalidating the session.',
  })
  @ApiResponse({
    status: 200,
    description: 'Logged out successfully',
    schema: {
      properties: {
        message: { type: 'string', example: 'Logout successful' },
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Missing or invalid JWT token' })
  async logout(@Request() req: any): Promise<{ message: string }> {
    const userId = req.user.sub;
    return this.authService.logout(userId);
  }
}

