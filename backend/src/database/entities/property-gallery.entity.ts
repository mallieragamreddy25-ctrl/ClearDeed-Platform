import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Property } from './property.entity';

/**
 * PropertyGallery Entity
 * 
 * Stores gallery images for properties
 * Supports multiple images per property with display ordering
 * Helps showcase property features through photos
 * 
 * Features:
 * - Multiple images per property
 * - Display ordering for gallery sequence
 * - Image URLs from cloud storage (S3, GCS, etc.)
 * - Automatic timestamp tracking
 * 
 * Relationships:
 * - ManyToOne: Multiple images per property
 * - CASCADE delete: Images deleted when property deleted
 * 
 * Ordering:
 * - display_order determines sequence in gallery (1, 2, 3, ...)
 * - Lower numbers appear first
 * - Seller can update order for better presentation
 */
@Entity('property_gallery')
@Index(['property_id'], { name: 'idx_gallery_property' })
@Index(['display_order'], { name: 'idx_gallery_order' })
export class PropertyGallery {
  /**
   * Unique gallery image identifier
   * Auto-generated primary key
   */
  @PrimaryGeneratedColumn()
  id: number;

  /**
   * Property relationship
   * Foreign key to properties table
   * Enforces CASCADE delete - image deleted when property deleted
   */
  @ManyToOne(() => Property, (property) => property.gallery, {
    nullable: true,
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'property_id' })
  property: Property;

  /**
   * Property ID (foreign key)
   * References properties.id
   * Cannot be null - every image must belong to a property
   */
  @Column({ nullable: false })
  property_id: number;

  /**
   * Image URL
   * Cloud storage URL (S3, Google Cloud Storage, Azure Blob, etc.)
   * Example: https://s3.amazonaws.com/cleardeed/gallery/property-123/photo-1.jpg
   * Should be optimized for web (compressed, multiple sizes for responsive design)
   * Recommended: Use CDN for fast delivery
   */
  @Column({ type: 'text', nullable: false })
  image_url: string;

  /**
   * Display order in gallery
   * Integer value determining sequence (1 = first, 2 = second, etc.)
   * Lower numbers display first in buyer views
   * Can be updated by seller to reorder gallery
   * Typically range 1-50 images per property
   */
  @Column({ type: 'int', nullable: false, default: 1 })
  display_order: number;

  /**
   * Automatic timestamp when image is uploaded
   * Set by database via @CreateDateColumn
   * Enables tracking when images were added to listing
   */
  @CreateDateColumn()
  created_at: Date;
}
