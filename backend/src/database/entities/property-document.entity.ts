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
 * PropertyDocument Entity
 * 
 * Stores documents uploaded for property verification
 * Each document type is required for property verification:
 * - title_deed: Proof of ownership/title
 * - survey: Property survey and measurement
 * - tax_proof: Property tax receipts and payment proof
 * - approval_letter: Municipal/government approval
 * 
 * A property can have multiple documents of different types
 * Documents are stored in cloud storage (S3, GCS, etc.) with URL reference
 * 
 * Relationships:
 * - ManyToOne: Multiple documents per property
 * - CASCADE delete: Documents deleted when property deleted
 */
@Entity('property_documents')
@Index('idx_doc_property', ['property_id'])
@Index('idx_doc_type', ['doc_type'])
export class PropertyDocument {
  /**
   * Unique document identifier
   * Auto-generated primary key
   */
  @PrimaryGeneratedColumn()
  id: number;

  /**
   * Property relationship
   * Foreign key to properties table
   * Enforces CASCADE delete - document deleted when property deleted
   */
  @ManyToOne(() => Property, (property) => property.documents, {
    nullable: true,
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'property_id' })
  property: Property;

  /**
   * Property ID (foreign key)
   * References properties.id
   * Cannot be null - every document must belong to a property
   */
  @Column({ nullable: false })
  property_id: number;

  /**
   * Document type/category
   * Enum: title_deed, survey, tax_proof, approval_letter
   * Determines what verification this document satisfies
   */
  @Column({
    type: 'enum',
    enum: ['title_deed', 'survey', 'tax_proof', 'approval_letter'],
  })
  doc_type: 'title_deed' | 'survey' | 'tax_proof' | 'approval_letter';

  /**
   * Document file URL
   * Cloud storage URL (S3, Google Cloud Storage, Azure Blob, etc.)
   * Example: https://s3.amazonaws.com/cleardeed/docs/property-123/title-deed.pdf
   * Should be publicly accessible for admin review
   * Can include authentication tokens for security
   */
  @Column({ type: 'text', nullable: false })
  file_url: string;

  /**
   * Automatic timestamp when document is uploaded
   * Set by database via @CreateDateColumn
   * Enables tracking when documents were added
   */
  @CreateDateColumn()
  created_at: Date;
}
