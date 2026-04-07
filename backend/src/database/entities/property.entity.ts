import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
  ManyToOne,
  JoinColumn,
  OneToMany,
} from 'typeorm';
import { User } from './user.entity';
import { PropertyDocument } from './property-document.entity';
import { PropertyGallery } from './property-gallery.entity';
import { ExpressInterest } from './express-interest.entity';

/**
 * Property Entity
 * 
 * Represents real estate properties being bought/sold through ClearDeed platform
 * Supports multiple categories: land, individual_house, commercial, agriculture
 * Tracks verification status and enforces business rules for property lifecycle
 * 
 * Status Lifecycle:
 * - submitted: Seller uploads property, awaiting admin review
 * - under_verification: Admin review in progress
 * - verified: Passed verification by admin, approved for listing
 * - live: Property is live and discoverable by buyers
 * - sold: Transaction completed
 * - rejected: Failed verification by admin
 * 
 * Business Rules:
 * - Only sellers (users with profile_type='seller') can create properties
 * - Properties start in 'submitted' status
 * - Only admins can transition to 'verified' status
 * - Cannot edit once status is not 'submitted' or 'under_verification'
 * - Once 'live', buyer can express interest
 */
@Entity('properties')
@Index(['seller_user_id'], { name: 'idx_property_seller' })
@Index(['status'], { name: 'idx_property_status' })
@Index(['city'], { name: 'idx_property_city' })
@Index(['category'], { name: 'idx_property_category' })
@Index(['is_verified'], { name: 'idx_property_verified' })
@Index(['created_at'], { name: 'idx_property_created' })
export class Property {
  /**
   * Unique property identifier
   * Auto-generated primary key
   */
  @PrimaryGeneratedColumn()
  id: number;

  /**
   * Seller (User) relationship
   * Foreign key to users table
   * Enforces CASCADE delete - property deleted when seller deleted
   */
  @ManyToOne(() => User, { nullable: true, onDelete: 'CASCADE' })
  @JoinColumn({ name: 'seller_user_id' })
  seller_user: User;

  /**
   * Seller user ID
   * References users.id where profile_type='seller'
   */
  @Column({ nullable: true })
  seller_user_id: number;

  /**
   * Property category
   * Enum: land, individual_house, commercial, agriculture
   * Used for buyer filtering and discovery
   */
  @Column({
    type: 'enum',
    enum: ['land', 'individual_house', 'commercial', 'agriculture'],
  })
  category: 'land' | 'individual_house' | 'commercial' | 'agriculture';

  /**
   * Property title/headline
   * Max 255 characters
   * Example: "Beautiful 2BHK House in Bangalore"
   */
  @Column({ type: 'varchar', length: 255 })
  title: string;

  /**
   * Detailed property description
   * Text field for full description
   * Optional, can be added/updated by seller
   */
  @Column({ type: 'text', nullable: true })
  description: string;

  /**
   * Exact property location/address
   * Example: "123 Main Street, Koramangala"
   */
  @Column({ type: 'varchar', length: 255 })
  location: string;

  /**
   * City where property is located
   * Used for filtering in buyer discovery
   * Indexed for performance
   */
  @Column({ type: 'varchar', length: 100, nullable: true })
  city: string;

  /**
   * Postal code
   * Maximum 10 characters (international compatibility)
   */
  @Column({ type: 'varchar', length: 10, nullable: true })
  pincode: string;

  /**
   * Property price in INR
   * Decimal precision: 15 digits, 2 decimal places
   * Supports prices up to 9,999,999,999.99
   */
  @Column({ type: 'decimal', precision: 15, scale: 2, nullable: true })
  price: number;

  /**
   * Property area/size
   * Decimal precision: 10 digits, 2 decimal places
   * Value depends on area_unit (sqft or sqm)
   */
  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  area: number;

  /**
   * Unit of area measurement
   * Enum: sqft (Square Feet), sqm (Square Meters)
   * Default: sqft
   */
  @Column({ type: 'varchar', length: 10, default: 'sqft' })
  area_unit: string;

  /**
   * Ownership type
   * Enum: freehold, leasehold
   * Freehold: Seller owns the land permanently
   * Leasehold: Seller has right to use for limited period
   */
  @Column({ type: 'varchar', length: 100, nullable: true })
  ownership_status: string;

  /**
   * Property status in verification workflow
   * Enum: submitted, under_verification, verified, live, sold, rejected
   * Default: submitted
   * 
   * State Transitions:
   * submitted → under_verification (admin initiates)
   * under_verification → verified (admin approves) OR rejected (admin rejects)
   * verified → live (system publishes)
   * live → sold (after deal completion)
   */
  @Column({
    type: 'enum',
    enum: ['submitted', 'under_verification', 'verified', 'live', 'sold', 'rejected'],
    default: 'submitted',
  })
  status: 'submitted' | 'under_verification' | 'verified' | 'live' | 'sold' | 'rejected';

  /**
   * Is property verified flag
   * Boolean version of verification status
   * True if status is 'verified' or 'live'
   * Used for quick queries and business logic
   */
  @Column({ type: 'boolean', default: false })
  is_verified: boolean;

  /**
   * Display verified badge to buyers
   * Shown in property listings and detail view
   * Indicates property passed verification and is trustworthy
   */
  @Column({ type: 'boolean', default: false })
  verified_badge: boolean;

  /**
   * Primary/main image URL
   * Used in property listings and thumbnails
   * Should be optimized for web display
   * Can be S3, Google Cloud Storage, or CDN URL
   */
  @Column({ type: 'text', nullable: true })
  primary_image_url: string;

  /**
   * One-to-many relationship with PropertyDocument
   * Stores verification documents: title_deed, survey, tax_proof, approval_letter
   * Automatically deleted when property is deleted
   */
  @OneToMany(() => PropertyDocument, (doc) => doc.property, { cascade: true })
  documents: PropertyDocument[];

  /**
   * One-to-many relationship with PropertyGallery
   * Stores property images with display order
   * Automatically deleted when property is deleted
   */
  @OneToMany(() => PropertyGallery, (gallery) => gallery.property, { cascade: true })
  gallery: PropertyGallery[];

  /**
   * One-to-many relationship with ExpressInterest
   * Tracks buyer interests in this property
   * Used for lead generation and analytics
   */
  @OneToMany(() => ExpressInterest, (interest) => interest.property, { cascade: true })
  expressInterests: ExpressInterest[];

  /**
   * Automatic timestamp when property record is created
   * Set by database via @CreateDateColumn
   */
  @CreateDateColumn()
  created_at: Date;

  /**
   * Automatic timestamp when property record is last updated
   * Updated every time property details change
   * Set by database via @UpdateDateColumn
   */
  @UpdateDateColumn()
  updated_at: Date;

  /**
   * Timestamp when property was verified by admin
   * Null until admin verifies the property
   * Set when status transitions to 'verified'
   */
  @Column({ type: 'timestamp', nullable: true })
  verified_at: Date;
}
