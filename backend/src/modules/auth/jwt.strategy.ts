/**
 * JWT Passport Strategy
 * 
 * Validates JWT tokens from Authorization header (Bearer token)
 * Uses HS256 algorithm with secret from environment
 * Automatically called by Passport when JwtAuthGuard is used
 */

import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';

interface JwtPayload {
  sub: string; // user ID
  mobile: string;
  iat: number;
  exp: number;
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor() {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET || 'your-secret-key-change-in-production',
    });
  }

  /**
   * Validate JWT payload after signature verification
   * This method is called automatically by Passport
   * The validated result is attached to request.user
   */
  validate(payload: JwtPayload): JwtPayload {
    if (!payload.sub || !payload.mobile) {
      throw new UnauthorizedException('Invalid token payload');
    }

    return payload;
  }
}

