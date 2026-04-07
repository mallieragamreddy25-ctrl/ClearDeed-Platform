import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Property } from './property.entity';
import { User } from './user.entity';

/**
 * PropertyVerification Entity
 * 
 * Tracks the verification process for properties
 * Links to admin user who performed verification
 * Stores verification documents and notes
 */
@Entity('property_verifications')
@Index(['property_id'])
@Index(['verification_status'])
export class PropertyVerification {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => Property, { nullable: true, onDelete: 'CASCADE' })
  @JoinColumn({ name: 'property_id' })
  property: Property;

  @Column({ nullable: true })
  property_id: number;

  @ManyToOne(() => User, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'verified_by_admin_id' })
  verified_by_admin: User;

  @Column({ nullable: true })
  verified_by_admin_id: number;

  @Column({
    type: 'enum',
    enum: ['pending', 'under_review', 'approved', 'rejected'],
    default: 'pending',
  })
  verification_status: 'pending' | 'under_review' | 'approved' | 'rejected';

  @Column({ type: 'text', array: true, nullable: true })
  verified_documents: string[];

  @Column({ type: 'text', nullable: true })
  verification_notes: string;

  @Column({ type: 'text', nullable: true })
  rejection_reason: string;

  @Column({ type: 'timestamp', nullable: true })
  verified_at: Date;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}
