import { SetMetadata } from '@nestjs/common';

/**
 * Decorator to mark routes that require admin role
 * Used in conjunction with AdminGuard for authorization
 * 
 * @example
 * @Post('/verify-property')
 * @IsAdmin()
 * async verifyProperty(...)
 */
export const IsAdmin = () => SetMetadata('is_admin', true);
