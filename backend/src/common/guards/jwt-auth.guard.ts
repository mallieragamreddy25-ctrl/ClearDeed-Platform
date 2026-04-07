import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

/**
 * JWT Authentication Guard
 * Validates JWT tokens from Authorization header
 * Extracts user information from token payload
 * 
 * Applied globally or per-route to protect endpoints
 * Inherited from @nestjs/passport JWT strategy
 */
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {}
