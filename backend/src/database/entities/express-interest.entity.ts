import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index,
  ManyToOne,
  JoinColumn,
  Unique,
} from 'typeorm';
import { User } from './user.entity';
import { Property } from './property.entity';
import { Project } from './project.entity';

/**
 * ExpressInterest Entity
 * 
 * Tracks buyer/investor interest in properties and projects
 * Enables lead generation and customer engagement
 * 
 * Features:
 * - Buyer expresses interest in property (POST /properties/:id/express-interest)
 * - One user cannot express interest twice in same property (unique constraint)
 * - Tracks timestamp of interest for follow-up
 * - Helps sellers/agents identify qualified leads
 * 
 * Workflow:
 * 1. Buyer views live property
 * 2. Clicks "Express Interest" button
 * 3. ExpressInterest record created (if not already exists)
 * 4. Seller/agent notified of new lead
 * 5. Used for analytics and CRM
 * 
 * Note: Can express interest in either property OR project, not both required
 */
@Entity('express_interests')
@Index(['user_id'], { name: 'idx_interest_user' })
@Index(['property_id'], { name: 'idx_interest_property' })
@Index(['project_id'], { name: 'idx_interest_project' })
@Index(['interested_at'], { name: 'idx_interest_date' })
@Unique('uk_user_property_interest', ['user_id', 'property_id'])
@Unique('uk_user_project_interest', ['user_id', 'project_id'])
export class ExpressInterest {
  /**
   * Unique interest record identifier
   * Auto-generated primary key
   */
  @PrimaryGeneratedColumn()
  id: number;

  /**
   * Interested user (buyer/investor)
   * Foreign key to users table
   * CASCADE delete: Interest deleted when user deleted
   */
  @ManyToOne(() => User, { nullable: true, onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;

  /**
   * User ID (foreign key)
   * References users.id
   * Cannot be null - interest must belong to a user
   */
  @Column({ nullable: false })
  user_id: number;

  /**
   * Property being interested in (optional)
   * Foreign key to properties table
   * CASCADE delete: Interest deleted when property deleted
   * Either property_id or project_id must be set, not both null
   */
  @ManyToOne(() => Property, (property) => property.expressInterests, {
    nullable: true,
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'property_id' })
  property: Property;

  /**
   * Property ID (foreign key)
   * References properties.id
   * Null if interest is in a project instead
   * Unique with user_id: one interest per user-property combo
   */
  @Column({ nullable: true })
  property_id: number;

  /**
   * Project being interested in (optional)
   * Foreign key to projects table
   * CASCADE delete: Interest deleted when project deleted
   * Either property_id or project_id must be set, not both null
   */
  @ManyToOne(() => Project, { nullable: true, onDelete: 'CASCADE' })
  @JoinColumn({ name: 'project_id' })
  project: Project;

  /**
   * Project ID (foreign key)
   * References projects.id
   * Null if interest is in a property instead
   * Unique with user_id: one interest per user-project combo
   */
  @Column({ nullable: true })
  project_id: number;

  /**
   * User role when expressing interest
   * Stored for analytics (which role types are interested)
   * Enum: buyer, seller, investor
   */
  @Column({
    type: 'enum',
    enum: ['buyer', 'seller', 'investor'],
  })
  user_role: 'buyer' | 'seller' | 'investor';

  /**
   * Is interest still active
   * Boolean flag for soft delete / deactivation
   * False if user withdrew interest
   * Default: true (first interest is always active)
   */
  @Column({ type: 'boolean', default: true })
  is_active: boolean;

  /**
   * Automatic timestamp when interest is expressed
   * Set by database via @CreateDateColumn
   * Used for tracking and lead prioritization
   * Newer interests might be higher priority
   */
  @CreateDateColumn()
  interested_at: Date;
}
