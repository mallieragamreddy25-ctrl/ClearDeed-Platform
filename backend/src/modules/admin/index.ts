/**
 * Admin Module Exports
 * 
 * Central export point for admin module types, interfaces, DTOs, and services.
 * Use this file for importing admin module functionality in other modules.
 *
 * Example usage:
 * ```typescript
 * import { AdminService, IAdminUser, CreateAdminDto } from './modules/admin';
 * ```
 */

// Interfaces
export * from './admin.interface';

// Service
export * from './admin.service';

// Controller
export * from './admin.controller';

// Module
export * from './admin.module';

// DTOs
export * from './dto/create-admin.dto';
export * from './dto/update-admin.dto';
export * from './dto/activity-log-filter.dto';
