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

    // Check if user is admin
    if (this.ADMIN_IDS.has(user.userId)) {
      return true;
    }

    // Could extend with database query:
    // const dbUser = await this.usersRepository.findOne({
    //   where: { id: user.userId },
    // });
    // if (dbUser?.is_admin) {
    //   return true;
    // }

    throw new ForbiddenException('Only administrators can access this endpoint');
  }
}
