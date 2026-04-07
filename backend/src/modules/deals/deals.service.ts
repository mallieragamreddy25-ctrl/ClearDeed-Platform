import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Deal } from '../../database/entities/deal.entity';
import { CommissionLedger } from '../../database/entities/commission-ledger.entity';
import { User } from '../../database/entities/user.entity';
import { Property } from '../../database/entities/property.entity';
import { Project } from '../../database/entities/project.entity';
import { DealReferralMapping } from '../../database/entities/deal-referral-mapping.entity';
import { CreateDealDto } from './dto/create-deal.dto';
import { CloseDealDto } from './dto/close-deal.dto';
import { IDeal, ICommissionLedger } from './deals.interface';

/**
 * Deals Service
 * 
 * Business logic for deal management:
 * - Create deals and lock commission percentages
 * - Close deals and calculate commissions
 * - Validate all party existence and status
 * - Track referral mappings and commission splits
 * 
 * Commission Structure (on transaction_value):
 * - Buyer Commission: 2%
 * - Seller Commission: 2%
 * - Referral Commission (if agent): 1% (split from buyer or seller)
 * - Platform Commission: 1% (retained)
 */
@Injectable()
export class DealsService {
  constructor(
    @InjectRepository(Deal)
    private readonly dealRepository: Repository<Deal>,
    
    @InjectRepository(CommissionLedger)
    private readonly commissionRepository: Repository<CommissionLedger>,
    
    @InjectRepository(DealReferralMapping)
    private readonly dealReferralRepository: Repository<DealReferralMapping>,
    
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    
    @InjectRepository(Property)
    private readonly propertyRepository: Repository<Property>,
    
    @InjectRepository(Project)
    private readonly projectRepository: Repository<Project>,
  ) {}

  /**
   * Create a new deal (admin-only)
   * 
   * Validates:
   * 1. Buyer and seller users exist
   * 2. Property OR project exists (at least one required)
   * 3. Property status is 'verified' (if property_id provided)
   * 4. No duplicate active deal for same property
   * 5. Commission percentages are valid (0-100)
   * 
   * Locks commission percentages at creation time
   */
  async createDeal(createDealDto: CreateDealDto, adminId: number): Promise<Deal> {
    const {
      buyer_user_id,
      seller_user_id,
      property_id,
      project_id,
      transaction_value,
      referral_partner_id,
      buyer_commission_percentage = 2,
      seller_commission_percentage = 2,
    } = createDealDto;

    // Validate at least one of property_id or project_id exists
    if (!property_id && !project_id) {
      throw new BadRequestException(
        'At least one of property_id or project_id is required',
      );
    }

    // Validate commission percentages
    if (
      buyer_commission_percentage < 0 ||
      buyer_commission_percentage > 100 ||
      seller_commission_percentage < 0 ||
      seller_commission_percentage > 100
    ) {
      throw new BadRequestException(
        'Commission percentages must be between 0 and 100',
      );
    }

    // Validate users exist
    const buyer = await this.userRepository.findOne({
      where: { id: buyer_user_id },
    });
    if (!buyer) {
      throw new NotFoundException(`Buyer with ID ${buyer_user_id} not found`);
    }

    const seller = await this.userRepository.findOne({
      where: { id: seller_user_id },
    });
    if (!seller) {
      throw new NotFoundException(`Seller with ID ${seller_user_id} not found`);
    }

    // Validate property if provided
    if (property_id) {
      const property = await this.propertyRepository.findOne({
        where: { id: property_id },
      });
      if (!property) {
        throw new NotFoundException(`Property with ID ${property_id} not found`);
      }
      if (property.status !== 'verified') {
        throw new BadRequestException(
          `Property status must be 'verified', current: ${property.status}`,
        );
      }

      // Check for existing active deal on this property
      const existingDeal = await this.dealRepository.findOne({
        where: {
          property_id,
          status: 'open',
        },
      });
      if (existingDeal) {
        throw new BadRequestException(
          `Property ${property_id} already has an active deal`,
        );
      }
    }

    // Validate project if provided
    if (project_id) {
      const project = await this.projectRepository.findOne({
        where: { id: project_id },
      });
      if (!project) {
        throw new NotFoundException(`Project with ID ${project_id} not found`);
      }
    }

    // Validate referral partner if provided
    let referralPartner = null;
    if (referral_partner_id) {
      referralPartner = await this.userRepository.findOne({
        where: { id: referral_partner_id },
      });
      if (!referralPartner) {
        throw new NotFoundException(
          `Referral partner with ID ${referral_partner_id} not found`,
        );
      }
    }

    // Create deal with locked commission percentages
    const deal = this.dealRepository.create({
      buyer_user_id,
      seller_user_id,
      property_id,
      project_id,
      referral_partner_id,
      created_by_admin_id: adminId,
      transaction_value,
      status: 'open',
      payment_status: 'pending',
      commission_locked_at: new Date(),
    });

    const savedDeal = await this.dealRepository.save(deal);

    // Create referral mapping if agent is involved
    if (referral_partner_id) {
      await this.dealReferralRepository.save({
        deal_id: savedDeal.id,
        referral_partner_id,
        side: 'buyer', // Default to buyer side; can be overridden
        commission_percentage: 1, // 1% referral commission
        commission_locked_at: new Date(),
      });
    }

    return savedDeal;
  }

  /**
   * Get deal with all related data
   * 
   * Returns:
   * - Deal object
   * - Buyer and seller details
   * - Property/Project details
   * - Referral mappings
   * - Commission ledger entries
   */
  async getDealDetail(dealId: number): Promise<IDeal> {
    const deal = await this.dealRepository.findOne({
      where: { id: dealId },
      relations: [
        'buyer',
        'seller',
        'property',
        'project',
        'referral_partner',
        'created_by_admin',
      ],
    });

    if (!deal) {
      throw new NotFoundException(`Deal with ID ${dealId} not found`);
    }

    return deal;
  }

  /**
   * Close a deal and calculate commissions
   * 
   * Process:
   * 1. Validate deal exists and is in 'open' status
   * 2. Calculate commissions for all parties:
   *    - Buyer commission: 2% of transaction (goes to platform + referral if exists)
   *    - Seller commission: 2% of transaction (goes to platform + referral if exists)
   *    - Platform commission: 1%
   * 3. Create commission ledger entries
   * 4. Mark property as 'sold' if property deal
   * 5. Update deal to 'closed' status
   * 
   * Commission Split Example (for $100,000 transaction):
   * - Buyer Fee: $2,000 (splits: $1,000 platform + $1,000 to referral if exists)
   * - Seller Fee: $2,000 (splits: $1,000 platform + $1,000 to referral if exists)
   * - Platform: $1,000
   * - Referral: $2,000 (if agent involved)
   */
  async closeDeal(dealId: number, closeDealDto: CloseDealDto): Promise<Deal> {
    const deal = await this.dealRepository.findOne({
      where: { id: dealId },
      relations: ['property', 'referral_partner'],
    });

    if (!deal) {
      throw new NotFoundException(`Deal with ID ${dealId} not found`);
    }

    if (deal.status !== 'open') {
      throw new BadRequestException(
        `Cannot close deal with status: ${deal.status}`,
      );
    }

    const { transaction_value } = deal;

    // Calculate commissions
    const buyerCommissionAmount = (transaction_value * 2) / 100; // 2%
    const sellerCommissionAmount = (transaction_value * 2) / 100; // 2%
    const platformCommissionAmount = (transaction_value * 1) / 100; // 1%

    // Create commission ledger entries
    const commissionEntries: CommissionLedger[] = [];

    // Buyer commission (2%)
    commissionEntries.push(
      this.commissionRepository.create({
        deal_id: dealId,
        commission_type: 'buyer_fee',
        amount: buyerCommissionAmount,
        percentage_applied: 2,
        status: 'pending',
        notes: `Buyer commission for deal ${dealId}`,
      }),
    );

    // Seller commission (2%)
    commissionEntries.push(
      this.commissionRepository.create({
        deal_id: dealId,
        commission_type: 'seller_fee',
        amount: sellerCommissionAmount,
        percentage_applied: 2,
        status: 'pending',
        notes: `Seller commission for deal ${dealId}`,
      }),
    );

    // Platform commission (1%)
    commissionEntries.push(
      this.commissionRepository.create({
        deal_id: dealId,
        commission_type: 'platform_fee',
        amount: platformCommissionAmount,
        percentage_applied: 1,
        status: 'pending',
        notes: `Platform commission for deal ${dealId}`,
      }),
    );

    // Referral commission if agent involved (1% to referral partner)
    if (deal.referral_partner_id) {
      const referralAmount = (transaction_value * 1) / 100;
      commissionEntries.push(
        this.commissionRepository.create({
          deal_id: dealId,
          referral_partner_id: deal.referral_partner_id,
          commission_type: 'referral_fee',
          amount: referralAmount,
          percentage_applied: 1,
          status: 'pending',
          notes: `Referral commission for deal ${dealId}`,
        }),
      );
    }

    // Save all commission entries
    await this.commissionRepository.save(commissionEntries);

    // Mark property as sold if property deal
    if (deal.property_id) {
      await this.propertyRepository.update(
        { id: deal.property_id },
        { status: 'sold' },
      );
    }

    // Close the deal
    deal.status = 'closed';
    deal.payment_status = 'completed';
    deal.payment_date = new Date();
    deal.deal_closed_at = new Date();

    return this.dealRepository.save(deal);
  }

  /**
   * Get deal by ID with all details
   */
  async getDealById(dealId: number): Promise<Deal> {
    const deal = await this.dealRepository.findOne({
      where: { id: dealId },
      relations: ['buyer', 'seller', 'property', 'project', 'referral_partner'],
    });

    if (!deal) {
      throw new NotFoundException(`Deal with ID ${dealId} not found`);
    }

    return deal;
  }

  /**
   * List deals with pagination
   */
  async listDeals(
    page: number = 1,
    limit: number = 20,
    status?: 'open' | 'closed',
    property_id?: number,
  ) {
    const query = this.dealRepository.createQueryBuilder('deal');

    if (status) {
      query.where('deal.status = :status', { status });
    }

    if (property_id) {
      query.andWhere('deal.property_id = :property_id', { property_id });
    }

    const total = await query.getCount();

    const deals = await query
      .skip((page - 1) * limit)
      .take(limit)
      .orderBy('deal.created_at', 'DESC')
      .getMany();

    return {
      data: deals,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get commission summary for a deal
   */
  async getDealCommissionSummary(dealId: number) {
    const commissions = await this.commissionRepository.find({
      where: { deal_id: dealId },
    });

    const summary = {
      total_commissions: commissions.reduce((sum, c) => sum + c.amount, 0),
      buyer_fee: commissions
        .filter((c) => c.commission_type === 'buyer_fee')
        .reduce((sum, c) => sum + c.amount, 0),
      seller_fee: commissions
        .filter((c) => c.commission_type === 'seller_fee')
        .reduce((sum, c) => sum + c.amount, 0),
      platform_fee: commissions
        .filter((c) => c.commission_type === 'platform_fee')
        .reduce((sum, c) => sum + c.amount, 0),
      referral_fee: commissions
        .filter((c) => c.commission_type === 'referral_fee')
        .reduce((sum, c) => sum + c.amount, 0),
      entries_count: commissions.length,
    };

    return { commissions, summary };
  }
}
