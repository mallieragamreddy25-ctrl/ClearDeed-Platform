import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

/**
 * JWT Authentication Guard
 * 
 * Used to protect endpoints that require authentication
 * Validates JWT token from Authorization header
 * 
 * Usage:
 * @UseGuards(JwtAuthGuard)
 * @ApiBearerAuth()
 */
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {}
