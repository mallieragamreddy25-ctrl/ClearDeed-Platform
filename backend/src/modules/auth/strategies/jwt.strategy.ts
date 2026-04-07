import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { AuthService } from '../auth.service';

/**
 * JWT Strategy for Passport
 * 
 * Validates JWT tokens and extracts user information
 * Used by JwtAuthGuard to protect routes
 * 
 * Token format: Authorization: Bearer <token>
 */
@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private readonly authService: AuthService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET || 'your_jwt_secret_key_change_in_production',
    });
  }

  /**
   * Validates JWT token payload
   * Called automatically by Passport during authentication
   */
  async validate(payload: any) {
    return {
      userId: payload.sub,
      mobile_number: payload.mobile_number,
      is_verified: payload.is_verified,
    };
  }
}
