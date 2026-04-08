import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../../database/entities/user.entity';

/**
 * Admin Guard
 * 
 * Validates that the authenticated user is an admin
 * Currently checks hardcoded admin user IDs
 * Can be extended to use a role-based system
 * 
 * Used with @UseGuards(AdminGuard) on routes requiring admin access
 */
@Injectable()
export class AdminGuard implements CanActivate {
  // Hardcoded admin user IDs for now
  private readonly ADMIN_IDS = new Set([1]); // User ID 1 is admin

  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user || !user.userId) {
      throw new ForbiddenException('No authenticated user found');
    }

    if (user.isAdmin) {
      return true;
    }

    if (this.ADMIN_IDS.has(user.userId)) {
      return true;
    }

    const dbUser = await this.usersRepository.findOne({
      where: { id: user.userId },
    });

    if (dbUser?.mobile_number) {
      const configuredMobile = process.env.ADMIN_MOBILE_NUMBER;
      if (
        configuredMobile &&
        this.normalizeMobileNumber(configuredMobile) ===
          this.normalizeMobileNumber(dbUser.mobile_number)
      ) {
        return true;
      }
    }

    throw new ForbiddenException('Only administrators can access this endpoint');
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
}
