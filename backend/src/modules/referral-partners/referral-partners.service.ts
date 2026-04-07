import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, FindOptionsWhere, ILike } from 'typeorm';
import { ReferralPartner } from '../../database/entities/referral-partner.entity';
import { CommissionLedger } from '../../database/entities/commission-ledger.entity';
import { User } from '../../database/entities/user.entity';
import { CreateReferralPartnerDto } from './dto/create-referral-partner.dto';
import { UpdateReferralPartnerDto } from './dto/update-referral-partner.dto';
import {
  IReferralPartnerDetail,
  IReferralPartnerListItem,
  IReferralPartnerListResponse,
  ICommissionSummary,
  ICreateReferralPartnerResponse,
  IMobileVerificationResponse,
  IStatusTransitionResponse,
} from './referral-partner.interface';

/**
 * Referral Partners Service
 * 
 * Complete business logic for managing referral partners (agents and verified users)
 * 
 * Responsibilities:
 * - Partner registration and validation
 * - Status management (pending → approved → active)
 * - Commission tracking and calculations
 * - Mobile number verification against User database
 * - Self-service and admin management workflows
 * - Commission history and earnings summary
 * 
 * Integration Points:
 * - ReferralPartner entity: Core partner data
 * - CommissionLedger entity: Commission tracking
 * - User entity: Verification and account linking
 * 
 * Business Rules:
 * 1. Mobile number must be unique
 * 2. Email must be unique
 * 3. Agents must provide license number
 * 4. Partner status: pending → under_review → approved/rejected
 * 5. Commission tracking per deal and partner
 * 6. Earnings calculation: total, pending, paid
 * 7. Self-service updates for own profile
 * 8. Admin override for approvals and suspensions
 */
@Injectable()
export class ReferralPartnersService {
  constructor(
    @InjectRepository(ReferralPartner)
    private partnersRepository: Repository<ReferralPartner>,
    @InjectRepository(CommissionLedger)
    private commissionsRepository: Repository<CommissionLedger>,
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  /**
   * Register new referral partner
   * 
   * Workflow:
   * 1. Validate mobile number uniqueness
   * 2. Validate email uniqueness
   * 3. Verify agent license if partner_type is 'agent'
   * 4. Create partner record with pending status
   * 5. Link to User if found by mobile
   * 
   * @param createDto - Partner registration data
   * @param registeredBy - Admin ID (for audit) or null for self-registration
   * @returns Created partner info with ID
   * @throws BadRequestException if mobile/email already exists
   */
  async registerReferralPartner(
    createDto: CreateReferralPartnerDto,
    registeredBy?: number,
  ): Promise<ICreateReferralPartnerResponse> {
    // Normalize mobile number (remove +91 and 0 prefix)
    const normalizedMobile = this.normalizeMobileNumber(
      createDto.mobile_number,
    );

    // Check mobile uniqueness
    const existingMobile = await this.partnersRepository.findOne({
      where: { mobile_number: normalizedMobile },
    });
    if (existingMobile) {
      throw new BadRequestException(
        `Mobile number ${createDto.mobile_number} is already registered as a referral partner`,
      );
    }

    // Check email uniqueness
    const existingEmail = await this.partnersRepository.findOne({
      where: { email: createDto.email },
    });
    if (existingEmail) {
      throw new BadRequestException(
        `Email ${createDto.email} is already registered as a referral partner`,
      );
    }

    // Validate agent license for agents
    if (createDto.partner_type === 'agent' && !createDto.agent_license_number) {
      throw new BadRequestException(
        'Agents must provide a valid license number',
      );
    }

    // Find associated User by mobile number (if exists)
    const user = await this.usersRepository.findOne({
      where: { mobile_number: normalizedMobile },
    });

    // Create partner record
    const partner = this.partnersRepository.create({
      mobile_number: normalizedMobile,
      partner_type: createDto.partner_type,
      full_name: createDto.full_name,
      email: createDto.email,
      city: createDto.city,
      agent_license_number: createDto.agent_license_number,
      agency_name: createDto.agency_name,
      user_id: user?.id,
      status: 'pending',
      is_active: true,
      commission_enabled: false,
      total_commission_earned: 0,
    });

    const savedPartner = await this.partnersRepository.save(partner);

    return {
      id: savedPartner.id,
      mobile_number: savedPartner.mobile_number,
      partner_type: savedPartner.partner_type,
      status: savedPartner.status,
      message: `Referral partner registered successfully. Status: pending verification`,
    };
  }

  /**
   * Get paginated list of referral partners
   * 
   * Features:
   * - Pagination support
   * - Filtering by status, partner_type, is_active
   * - Search by mobile, name, or email
   * - Sorting by creation date (newest first)
   * 
   * @param page - Page number (1-based)
   * @param limit - Items per page
   * @param status - Filter by status (optional)
   * @param partnerType - Filter by type agent/verified_user (optional)
   * @param search - Search term (mobile, name, or email)
   * @param isActive - Filter by active status (optional)
   * @returns Paginated list with metadata
   */
  async listReferralPartners(
    page: number = 1,
    limit: number = 10,
    status?: string,
    partnerType?: string,
    search?: string,
    isActive?: boolean,
  ): Promise<IReferralPartnerListResponse> {
    const skip = (page - 1) * limit;

    // Build dynamic where clause
    const where: FindOptionsWhere<ReferralPartner> = {};

    if (status) {
      where.status = status as any;
    }

    if (partnerType) {
      where.partner_type = partnerType as any;
    }

    if (isActive !== undefined) {
      where.is_active = isActive;
    }

    // If search provided, handle separately (OR condition)
    let query = this.partnersRepository.createQueryBuilder('partner');

    query = query.where(':searchTerm IS NULL OR partner.mobile_number LIKE :searchTerm OR partner.full_name LIKE :searchTerm OR partner.email LIKE :searchTerm', {
      searchTerm: search ? `%${search}%` : null,
    });

    // Apply filters from where clause
    if (status) {
      query = query.andWhere('partner.status = :status', { status });
    }
    if (partnerType) {
      query = query.andWhere('partner.partner_type = :partnerType', {
        partnerType,
      });
    }
    if (isActive !== undefined) {
      query = query.andWhere('partner.is_active = :isActive', { isActive });
    }

    // Get total count
    const total = await query.getCount();

    // Get paginated data
    const data = await query
      .orderBy('partner.created_at', 'DESC')
      .skip(skip)
      .take(limit)
      .getMany();

    const listItems: IReferralPartnerListItem[] = data.map((partner) => ({
      id: partner.id,
      mobile_number: partner.mobile_number,
      full_name: partner.full_name,
      partner_type: partner.partner_type,
      status: partner.status,
      is_active: partner.is_active,
      total_commission_earned: parseFloat(partner.total_commission_earned.toString()),
      created_at: partner.created_at,
    }));

    return {
      data: listItems,
      total,
      page,
      limit,
      total_pages: Math.ceil(total / limit),
    };
  }

  /**
   * Get referral partner detail
   * 
   * Returns complete partner information including:
   * - Basic profile
   * - Status and verification
   * - Commission earnings
   * - Commission ledger history
   * 
   * @param partnerId - Partner ID
   * @returns Complete partner details with commission history
   * @throws NotFoundException if partner not found
   */
  async getReferralPartnerDetail(
    partnerId: number,
  ): Promise<IReferralPartnerDetail & { commission_ledger?: any[] }> {
    const partner = await this.partnersRepository.findOne({
      where: { id: partnerId },
      relations: ['user'],
    });

    if (!partner) {
      throw new NotFoundException(`Referral partner with ID ${partnerId} not found`);
    }

    const detail: IReferralPartnerDetail & { commission_ledger?: any[] } = {
      id: partner.id,
      user_id: partner.user_id,
      mobile_number: partner.mobile_number,
      partner_type: partner.partner_type,
      full_name: partner.full_name,
      email: partner.email,
      city: partner.city,
      agent_license_number: partner.agent_license_number,
      agency_name: partner.agency_name,
      status: partner.status,
      is_active: partner.is_active,
      commission_enabled: partner.commission_enabled,
      total_commission_earned: parseFloat(partner.total_commission_earned.toString()),
      yearly_maintenance_fee_status: partner.yearly_maintenance_fee_status,
      maintenance_fee_renewal_date: partner.maintenance_fee_renewal_date,
      created_at: partner.created_at,
      updated_at: partner.updated_at,
    };

    // Fetch commission ledger
    const ledger = await this.commissionsRepository.find({
      where: { referral_partner_id: partnerId },
      order: { created_at: 'DESC' },
    });

    detail.commission_ledger = ledger.map((entry) => ({
      id: entry.id,
      deal_id: entry.deal_id,
      amount: parseFloat(entry.amount.toString()),
      commission_type: entry.commission_type,
      percentage_applied: entry.percentage_applied,
      status: entry.status,
      payment_date: entry.payment_date,
      created_at: entry.created_at,
    }));

    return detail;
  }

  /**
   * Update referral partner information
   * 
   * Workflow:
   * 1. Verify partner exists
   * 2. Check email uniqueness (if email updated)
   * 3. Update allowed fields
   * 4. Persist changes
   * 
   * Not updatable:
   * - mobile_number (unique identifier)
   * - partner_type (fixed at registration)
   * - status (changed via approve/reject)
   * - is_active (changed via suspend)
   * 
   * @param partnerId - Partner ID
   * @param updateDto - Fields to update
   * @param isAdmin - Is admin user (allows override)
   * @param requestingPartnerId - Partner making request (for self-service check)
   * @returns Updated partner details
   * @throws NotFoundException if partner not found
   * @throws BadRequestException if email duplicate
   */
  async updateReferralPartner(
    partnerId: number,
    updateDto: UpdateReferralPartnerDto,
    isAdmin: boolean = false,
    requestingPartnerId?: number,
  ): Promise<IReferralPartnerDetail> {
    const partner = await this.partnersRepository.findOne({
      where: { id: partnerId },
    });

    if (!partner) {
      throw new NotFoundException(`Referral partner with ID ${partnerId} not found`);
    }

    // Self-service check: non-admins can only update their own profile
    if (!isAdmin && requestingPartnerId && requestingPartnerId !== partnerId) {
      throw new BadRequestException(
        'You can only update your own profile',
      );
    }

    // Check email uniqueness if email is being updated
    if (updateDto.email && updateDto.email !== partner.email) {
      const existingEmail = await this.partnersRepository.findOne({
        where: { email: updateDto.email },
      });
      if (existingEmail) {
        throw new BadRequestException(
          `Email ${updateDto.email} is already registered`,
        );
      }
    }

    // Update allowed fields
    if (updateDto.full_name) {
      partner.full_name = updateDto.full_name;
    }
    if (updateDto.email) {
      partner.email = updateDto.email;
    }
    if (updateDto.city) {
      partner.city = updateDto.city;
    }
    if (updateDto.agent_license_number) {
      partner.agent_license_number = updateDto.agent_license_number;
    }
    if (updateDto.agency_name) {
      partner.agency_name = updateDto.agency_name;
    }

    const updated = await this.partnersRepository.save(partner);

    return {
      id: updated.id,
      user_id: updated.user_id,
      mobile_number: updated.mobile_number,
      partner_type: updated.partner_type,
      full_name: updated.full_name,
      email: updated.email,
      city: updated.city,
      agent_license_number: updated.agent_license_number,
      agency_name: updated.agency_name,
      status: updated.status,
      is_active: updated.is_active,
      commission_enabled: updated.commission_enabled,
      total_commission_earned: parseFloat(updated.total_commission_earned.toString()),
      yearly_maintenance_fee_status: updated.yearly_maintenance_fee_status,
      maintenance_fee_renewal_date: updated.maintenance_fee_renewal_date,
      created_at: updated.created_at,
      updated_at: updated.updated_at,
    };
  }

  /**
   * Approve referral partner
   * 
   * Admin-only operation to approve a pending or under_review partner
   * 
   * Workflow:
   * 1. Find partner
   * 2. Validate status is pending or under_review
   * 3. Change status to approved
   * 4. Enable commissions
   * 5. Return transition response
   * 
   * @param partnerId - Partner ID to approve
   * @returns Status transition response
   * @throws NotFoundException if partner not found
   * @throws BadRequestException if partner not in approvable status
   */
  async approveReferralPartner(partnerId: number): Promise<IStatusTransitionResponse> {
    const partner = await this.partnersRepository.findOne({
      where: { id: partnerId },
    });

    if (!partner) {
      throw new NotFoundException(`Referral partner with ID ${partnerId} not found`);
    }

    if (!['pending', 'under_review'].includes(partner.status)) {
      throw new BadRequestException(
        `Cannot approve partner with status ${partner.status}. Only pending or under_review partners can be approved.`,
      );
    }

    const previousStatus = partner.status;
    partner.status = 'approved';
    partner.commission_enabled = true;
    partner.is_active = true;

    const updated = await this.partnersRepository.save(partner);

    return {
      id: updated.id,
      mobile_number: updated.mobile_number,
      previous_status: previousStatus,
      new_status: updated.status,
      timestamp: new Date(),
    };
  }

  /**
   * Reject referral partner
   * 
   * Admin-only operation to reject a pending or under_review partner
   * 
   * Workflow:
   * 1. Find partner
   * 2. Validate status is pending or under_review
   * 3. Change status to rejected
   * 4. Disable commissions
   * 5. Deactivate account
   * 6. Return transition response
   * 
   * @param partnerId - Partner ID to reject
   * @param reason - Rejection reason (optional)
   * @returns Status transition response
   * @throws NotFoundException if partner not found
   * @throws BadRequestException if partner not in rejectable status
   */
  async rejectReferralPartner(
    partnerId: number,
    reason?: string,
  ): Promise<IStatusTransitionResponse> {
    const partner = await this.partnersRepository.findOne({
      where: { id: partnerId },
    });

    if (!partner) {
      throw new NotFoundException(`Referral partner with ID ${partnerId} not found`);
    }

    if (!['pending', 'under_review'].includes(partner.status)) {
      throw new BadRequestException(
        `Cannot reject partner with status ${partner.status}. Only pending or under_review partners can be rejected.`,
      );
    }

    const previousStatus = partner.status;
    partner.status = 'rejected';
    partner.commission_enabled = false;
    partner.is_active = false;

    const updated = await this.partnersRepository.save(partner);

    return {
      id: updated.id,
      mobile_number: updated.mobile_number,
      previous_status: previousStatus,
      new_status: updated.status,
      timestamp: new Date(),
    };
  }

  /**
   * Suspend referral partner
   * 
   * Admin-only operation to suspend an approved/active partner
   * Allows reactivation later
   * 
   * Workflow:
   * 1. Find partner
   * 2. Deactivate account (is_active = false)
   * 3. Disable new commissions
   * 4. Return transition response
   * 
   * @param partnerId - Partner ID to suspend
   * @returns Status transition response
   * @throws NotFoundException if partner not found
   */
  async suspendReferralPartner(partnerId: number): Promise<IStatusTransitionResponse> {
    const partner = await this.partnersRepository.findOne({
      where: { id: partnerId },
    });

    if (!partner) {
      throw new NotFoundException(`Referral partner with ID ${partnerId} not found`);
    }

    const previousStatus = partner.is_active ? 'active' : 'suspended';
    partner.is_active = false;
    partner.commission_enabled = false;

    await this.partnersRepository.save(partner);

    return {
      id: partner.id,
      mobile_number: partner.mobile_number,
      previous_status: previousStatus,
      new_status: 'suspended',
      timestamp: new Date(),
    };
  }

  /**
   * Reactivate referral partner
   * 
   * Admin-only operation to reactivate a suspended partner
   * 
   * Workflow:
   * 1. Find partner
   * 2. Reactivate account (is_active = true)
   * 3. Enable commissions (if status is approved)
   * 4. Return transition response
   * 
   * @param partnerId - Partner ID to reactivate
   * @returns Status transition response
   * @throws NotFoundException if partner not found
   */
  async reactivateReferralPartner(partnerId: number): Promise<IStatusTransitionResponse> {
    const partner = await this.partnersRepository.findOne({
      where: { id: partnerId },
    });

    if (!partner) {
      throw new NotFoundException(`Referral partner with ID ${partnerId} not found`);
    }

    const previousStatus = 'suspended';
    partner.is_active = true;
    if (partner.status === 'approved') {
      partner.commission_enabled = true;
    }

    await this.partnersRepository.save(partner);

    return {
      id: partner.id,
      mobile_number: partner.mobile_number,
      previous_status: previousStatus,
      new_status: 'active',
      timestamp: new Date(),
    };
  }

  /**
   * Get commission summary for a partner
   * 
   * Calculates earnings summary:
   * - total_earned: Sum of all commission amounts
   * - pending_amount: Sum of pending commissions
   * - paid_amount: Sum of paid commissions
   * - Includes full commission ledger
   * 
   * @param partnerId - Partner ID
   * @returns Commission summary with ledger
   * @throws NotFoundException if partner not found
   */
  async getCommissionSummary(partnerId: number): Promise<ICommissionSummary> {
    const partner = await this.partnersRepository.findOne({
      where: { id: partnerId },
    });

    if (!partner) {
      throw new NotFoundException(`Referral partner with ID ${partnerId} not found`);
    }

    const ledger = await this.commissionsRepository.find({
      where: { referral_partner_id: partnerId },
      order: { created_at: 'DESC' },
    });

    // Calculate totals
    let totalEarned = 0;
    let pendingAmount = 0;
    let paidAmount = 0;

    ledger.forEach((entry) => {
      const amount = parseFloat(entry.amount.toString());
      totalEarned += amount;

      if (entry.status === 'pending' || entry.status === 'approved') {
        pendingAmount += amount;
      } else if (entry.status === 'paid') {
        paidAmount += amount;
      }
    });

    return {
      partner_id: partnerId,
      total_earned: totalEarned,
      pending_amount: pendingAmount,
      paid_amount: paidAmount,
      commission_ledger: ledger.map((entry) => ({
        id: entry.id,
        deal_id: entry.deal_id,
        amount: parseFloat(entry.amount.toString()),
        commission_type: entry.commission_type,
        percentage_applied: entry.percentage_applied,
        status: entry.status,
        payment_date: entry.payment_date,
        created_at: entry.created_at,
      })),
    };
  }

  /**
   * Verify mobile number against User database
   * 
   * Checks if mobile number exists in users table
   * Returns user details if found
   * 
   * @param mobile - Mobile number to verify
   * @returns Verification result with user details if found
   */
  async verifyMobileNumber(mobile: string): Promise<IMobileVerificationResponse> {
    const normalizedMobile = this.normalizeMobileNumber(mobile);

    const user = await this.usersRepository.findOne({
      where: { mobile_number: normalizedMobile },
    });

    const partner = await this.partnersRepository.findOne({
      where: { mobile_number: normalizedMobile },
    });

    return {
      mobile_number: normalizedMobile,
      is_valid_user: !!user,
      partner_exists: !!partner,
      user_details: user
        ? {
            id: user.id,
            full_name: user.full_name,
            profile_type: user.profile_type,
          }
        : undefined,
    };
  }

  /**
   * Normalize mobile number to 10-digit format
   * 
   * Handles multiple formats:
   * - 10 digit: 9876543210 → 9876543210
   * - With +91: +919876543210 → 9876543210
   * - With 91: 919876543210 → 9876543210
   * - With 0: 09876543210 → 9876543210
   * 
   * @param mobile - Mobile number in various formats
   * @returns Normalized 10-digit mobile number
   */
  private normalizeMobileNumber(mobile: string): string {
    let normalized = mobile.replace(/\D/g, ''); // Remove non-digits

    // Remove country code if present
    if (normalized.startsWith('91') && normalized.length > 10) {
      normalized = normalized.slice(2);
    }

    // Remove leading 0 if present
    if (normalized.startsWith('0')) {
      normalized = normalized.slice(1);
    }

    return normalized.slice(-10); // Take last 10 digits
  }
}
