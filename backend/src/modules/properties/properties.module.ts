import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PropertiesService } from './properties.service';
import { PropertiesController } from './properties.controller';
import { Property } from '../../database/entities/property.entity';
import { PropertyVerification } from '../../database/entities/property-verification.entity';
import { PropertyDocument } from '../../database/entities/property-document.entity';
import { PropertyGallery } from '../../database/entities/property-gallery.entity';
import { ExpressInterest } from '../../database/entities/express-interest.entity';
import { User } from '../../database/entities/user.entity';

/**
 * Properties Module
 * 
 * Complete property management module with:
 * - Property CRUD operations (sellers)
 * - Verification workflow (admins)
 * - Document and gallery management
 * - Buyer discovery and filtering
 * - Express interest tracking
 * 
 * Features:
 * - Full text search with filters
 * - Pagination support
 * - File upload handling (documents, gallery)
 * - Verification status tracking
 * - Transaction support for multi-table operations
 * 
 * Related Entities:
 * - Property: Main property listings
 * - PropertyVerification: Verification workflow tracking
 * - PropertyDocument: Title deeds, surveys, tax proofs
 * - PropertyGallery: Property images with ordering
 * - ExpressInterest: Buyer interest tracking
 * - User: Property sellers/buyers
 */
@Module({
  imports: [
    TypeOrmModule.forFeature([
      Property,
      PropertyVerification,
      PropertyDocument,
      PropertyGallery,
      ExpressInterest,
      User,
    ]),
  ],
  controllers: [PropertiesController],
  providers: [PropertiesService],
  exports: [PropertiesService],
})
export class PropertiesModule {}
