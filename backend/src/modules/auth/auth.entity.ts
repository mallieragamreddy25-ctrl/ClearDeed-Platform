import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';

/**
 * User Entity - Authentication & User Data
 * 
 * Stores:
 * - Basic user information (email, phone)
 * - Authentication credentials (hashed password)
 * - Account status and verification status
 * - Timestamps for tracking
 */
@Entity('users')
@Index('idx_email', ['email'], { unique: true })
@Index('idx_phone', ['phone'], { unique: true })
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 255 })
  firstName: string;

  @Column({ length: 255 })
  lastName: string;

  @Column({ length: 255, unique: true })
  email: string;

  @Column({ length: 20, unique: true })
  phone: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  password: string;

  @Column({ default: false })
  isEmailVerified: boolean;

  @Column({ default: false })
  isPhoneVerified: boolean;

  @Column({ default: true })
  isActive: boolean;

  @Column({ length: 50, default: 'buyer' })
  userType: string; // 'buyer', 'seller', 'investor', 'agent'

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Column({ nullable: true })
  lastLoginAt: Date;
}

/**
 * OTP Entity - OTP Storage & Verification
 * 
 * Stores OTP records with:
 * - Expiry timestamps
 * - Attempt counting for rate limiting
 * - Verification status
 */
@Entity('otps')
@Index('idx_otp_phone_used', ['phone', 'isUsed'])
export class Otp {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 20 })
  phone: string;

  @Column({ length: 10 })
  code: string;

  @Column({ default: 0 })
  attempts: number;

  @Column({ default: false })
  isUsed: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @Column()
  expiresAt: Date;
}
