import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { randomUUID } from 'node:crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { DeepPartial, Repository } from 'typeorm';
import { Deal } from '../../database/entities/deal.entity';
import { CommissionLedger } from '../../database/entities/commission-ledger.entity';
import { User } from '../../database/entities/user.entity';
import { Property } from '../../database/entities/property.entity';
import { Project } from '../../database/entities/project.entity';
import { DealReferralMapping } from '../../database/entities/deal-referral-mapping.entity';
import { ReferralPartner } from '../../database/entities/referral-partner.entity';
import { CreateDealDto } from './dto/create-deal.dto';
import { CloseDealDto } from './dto/close-deal.dto';
import { IDeal } from './deals.interface';

type ReferralSide = 'buyer' | 'seller';

/**
 * Deals Service
 *
 * Business logic for deal management:
 * - Create deals and lock commission percentages
 * - Close deals and calculate commissions
 * - Validate all party existence and status
 * - Track buyer-side and seller-side referral mappings independently
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

    @InjectRepository(ReferralPartner)
    private readonly referralPartnerRepository: Repository<ReferralPartner>,
  ) {}

  async createDeal(createDealDto: CreateDealDto, adminId: number): Promise<Deal> {
    const {
      buyer_user_id,
      seller_user_id,
      property_id,
      project_id,
      transaction_value,
      referral_partner_id,
      buyer_referral_partner_id,
      seller_referral_partner_id,
      buyer_commission_percentage = 2,
      seller_commission_percentage = 2,
      platform_commission_percentage,
      referral_commission_percentage,
    } = createDealDto;

    const isProjectDeal = !!project_id;
    const resolvedBuyerReferralPartnerId =
      buyer_referral_partner_id ?? referral_partner_id;
    const resolvedSellerReferralPartnerId = seller_referral_partner_id;
    const resolvedReferralPartnerIds = [
      resolvedBuyerReferralPartnerId,
      resolvedSellerReferralPartnerId,
    ].filter((value): value is number => typeof value === 'number');

    if (!property_id && !project_id) {
      throw new BadRequestException(
        'At least one of property_id or project_id is required',
      );
    }

    if (buyer_user_id === seller_user_id) {
      throw new BadRequestException('Buyer and seller must be different users');
    }

    if (!isProjectDeal) {
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
    } else {
      const resolvedPlatformCommission = platform_commission_percentage ?? 2;
      const resolvedReferralCommission =
        resolvedReferralPartnerIds.length > 0
          ? referral_commission_percentage ?? 1
          : 0;

      if (resolvedPlatformCommission < 2 || resolvedPlatformCommission > 10) {
        throw new BadRequestException(
          'Project deals require platform commission percentage between 2 and 10',
        );
      }

      if (resolvedReferralPartnerIds.length > 0) {
        if (resolvedReferralCommission < 1 || resolvedReferralCommission > 2) {
          throw new BadRequestException(
            'Project deals require referral commission percentage between 1 and 2 when a referral partner is assigned',
          );
        }
      } else if (
        referral_commission_percentage !== undefined &&
        referral_commission_percentage !== null
      ) {
        throw new BadRequestException(
          'Referral commission percentage can only be provided when a referral partner is assigned',
        );
      }
    }

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

    if (project_id) {
      const project = await this.projectRepository.findOne({
        where: { id: project_id },
      });
      if (!project) {
        throw new NotFoundException(`Project with ID ${project_id} not found`);
      }
    }

    const referralPartnersById = new Map<number, ReferralPartner>();
    for (const partnerId of resolvedReferralPartnerIds) {
      if (referralPartnersById.has(partnerId)) {
        continue;
      }

      const partner = await this.referralPartnerRepository.findOne({
        where: { id: partnerId },
      });

      if (!partner) {
        throw new NotFoundException(
          `Referral partner with ID ${partnerId} not found`,
        );
      }

      if (
        partner.status !== 'approved' ||
        !partner.is_active ||
        !partner.commission_enabled
      ) {
        throw new BadRequestException(
          `Referral partner ${partnerId} must be approved, active, and commission-enabled`,
        );
      }

      referralPartnersById.set(partnerId, partner);
    }

    const dealPayload: DeepPartial<Deal> = {
      buyer_user_id,
      seller_user_id,
      property_id,
      project_id,
      created_by_admin_id: adminId,
      transaction_value,
      buyer_commission_percentage,
      seller_commission_percentage,
      platform_commission_percentage: isProjectDeal
        ? platform_commission_percentage ?? 2
        : undefined,
      referral_commission_percentage: isProjectDeal
        ? resolvedReferralPartnerIds.length > 0
          ? referral_commission_percentage ?? 1
          : 0
        : undefined,
      status: 'open',
      payment_status: 'pending',
      commission_locked_at: new Date(),
    };

    const savedDeal = await this.dealRepository.save(
      this.dealRepository.create(dealPayload),
    );

    const referralMappings: Array<DeepPartial<DealReferralMapping>> = [];
    const propertyReferralPercentage = 1;
    const projectReferralPercentage = savedDeal.referral_commission_percentage ?? 1;

    if (resolvedBuyerReferralPartnerId) {
      referralMappings.push(
        this.buildReferralMapping(
          savedDeal.id,
          resolvedBuyerReferralPartnerId,
          'buyer',
          isProjectDeal ? projectReferralPercentage : propertyReferralPercentage,
        ),
      );
    }

    if (resolvedSellerReferralPartnerId) {
      referralMappings.push(
        this.buildReferralMapping(
          savedDeal.id,
          resolvedSellerReferralPartnerId,
          'seller',
          isProjectDeal ? projectReferralPercentage : propertyReferralPercentage,
        ),
      );
    }

    if (referralMappings.length > 0) {
      await this.dealReferralRepository.save(
        referralMappings.map((mapping) => this.dealReferralRepository.create(mapping)),
      );
    }

    return await this.getDealById(savedDeal.id);
  }

  async getDealDetail(dealId: number): Promise<IDeal> {
    const deal = await this.getDealById(dealId);
    return deal as unknown as IDeal;
  }

  async closeDeal(dealId: number, closeDealDto: CloseDealDto): Promise<Deal> {
    void closeDealDto;

    const deal = await this.dealRepository.findOne({
      where: { id: dealId },
      relations: [
        'property',
        'referral_mappings',
        'referral_mappings.referral_partner',
      ],
    });

    if (!deal) {
      throw new NotFoundException(`Deal with ID ${dealId} not found`);
    }

    if (deal.status !== 'open') {
      throw new BadRequestException(
        `Cannot close deal with status: ${deal.status}`,
      );
    }

    const transactionValue = Number(deal.transaction_value ?? 0);
    const commissionEntries: CommissionLedger[] = [];
    const isProjectDeal = !!deal.project_id;

    if (isProjectDeal) {
      const platformPercentage = Number(deal.platform_commission_percentage ?? 2);
      const platformCommissionAmount = (transactionValue * platformPercentage) / 100;
      commissionEntries.push(
        this.commissionRepository.create({
          deal_id: dealId,
          commission_type: 'platform_fee',
          amount: platformCommissionAmount,
          percentage_applied: platformPercentage,
          status: 'pending',
          notes: `Platform commission for project deal ${dealId}`,
        }),
      );

      for (const mapping of deal.referral_mappings ?? []) {
        const referralPercentage = Number(
          mapping.commission_percentage ??
            deal.referral_commission_percentage ??
            1,
        );

        if (referralPercentage <= 0) {
          continue;
        }

        commissionEntries.push(
          this.commissionRepository.create({
            deal_id: dealId,
            referral_partner_id: mapping.referral_partner_id,
            commission_type: 'referral_fee',
            amount: (transactionValue * referralPercentage) / 100,
            percentage_applied: referralPercentage,
            status: 'pending',
            notes: `${this.sideLabel(mapping.side)} referral commission for project deal ${dealId}`,
          }),
        );
      }
    } else {
      const buyerPercentage = Number(deal.buyer_commission_percentage ?? 2);
      const sellerPercentage = Number(deal.seller_commission_percentage ?? 2);

      commissionEntries.push(
        this.commissionRepository.create({
          deal_id: dealId,
          commission_type: 'buyer_fee',
          amount: (transactionValue * buyerPercentage) / 100,
          percentage_applied: buyerPercentage,
          status: 'pending',
          notes: `Buyer commission for deal ${dealId}`,
        }),
      );

      commissionEntries.push(
        this.commissionRepository.create({
          deal_id: dealId,
          commission_type: 'seller_fee',
          amount: (transactionValue * sellerPercentage) / 100,
          percentage_applied: sellerPercentage,
          status: 'pending',
          notes: `Seller commission for deal ${dealId}`,
        }),
      );

      commissionEntries.push(
        this.commissionRepository.create({
          deal_id: dealId,
          commission_type: 'platform_fee',
          amount: (transactionValue * 1) / 100,
          percentage_applied: 1,
          status: 'pending',
          notes: `Platform commission for deal ${dealId}`,
        }),
      );

      for (const mapping of deal.referral_mappings ?? []) {
        const referralPercentage = Number(mapping.commission_percentage ?? 1);
        commissionEntries.push(
          this.commissionRepository.create({
            deal_id: dealId,
            referral_partner_id: mapping.referral_partner_id,
            commission_type: 'referral_fee',
            amount: (transactionValue * referralPercentage) / 100,
            percentage_applied: referralPercentage,
            status: 'pending',
            notes: `${this.sideLabel(mapping.side)} referral commission for deal ${dealId}`,
          }),
        );
      }
    }

    await this.commissionRepository.save(commissionEntries);

    if (deal.property_id) {
      await this.propertyRepository.update(
        { id: deal.property_id },
        { status: 'sold' },
      );
    }

    deal.status = 'closed';
    deal.payment_status = 'completed';
    deal.payment_date = new Date();
    deal.deal_closed_at = new Date();

    return this.dealRepository.save(deal);
  }

  async getDealById(dealId: number): Promise<Deal> {
    const deal = await this.dealRepository.findOne({
      where: { id: dealId },
      relations: [
        'buyer_user',
        'seller_user',
        'property',
        'project',
        'referral_mappings',
        'referral_mappings.referral_partner',
      ],
    });

    if (!deal) {
      throw new NotFoundException(`Deal with ID ${dealId} not found`);
    }

    return deal;
  }

  async listDeals(
    page: number = 1,
    limit: number = 20,
    status?: 'open' | 'closed',
    property_id?: number,
  ) {
    const query = this.dealRepository
      .createQueryBuilder('deal')
      .leftJoinAndSelect('deal.buyer_user', 'buyer_user')
      .leftJoinAndSelect('deal.seller_user', 'seller_user')
      .leftJoinAndSelect('deal.property', 'property')
      .leftJoinAndSelect('deal.project', 'project')
      .leftJoinAndSelect('deal.referral_mappings', 'referral_mappings')
      .leftJoinAndSelect('referral_mappings.referral_partner', 'referral_partner');

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

  async getDealCommissionSummary(dealId: number) {
    const commissions = await this.commissionRepository.find({
      where: { deal_id: dealId },
      relations: ['referral_partner'],
    });

    const summary = {
      total_commissions: commissions.reduce(
        (sum, commission) => sum + Number(commission.amount),
        0,
      ),
      buyer_fee: commissions
        .filter((commission) => commission.commission_type === 'buyer_fee')
        .reduce((sum, commission) => sum + Number(commission.amount), 0),
      seller_fee: commissions
        .filter((commission) => commission.commission_type === 'seller_fee')
        .reduce((sum, commission) => sum + Number(commission.amount), 0),
      platform_fee: commissions
        .filter((commission) => commission.commission_type === 'platform_fee')
        .reduce((sum, commission) => sum + Number(commission.amount), 0),
      referral_fee: commissions
        .filter((commission) => commission.commission_type === 'referral_fee')
        .reduce((sum, commission) => sum + Number(commission.amount), 0),
      entries_count: commissions.length,
    };

    return { commissions, summary };
  }

  private buildReferralMapping(
    dealId: number,
    referralPartnerId: number,
    side: ReferralSide,
    commissionPercentage: number,
  ): DeepPartial<DealReferralMapping> {
    return {
      deal_id: dealId,
      referral_partner_id: referralPartnerId,
      side,
      commission_percentage: commissionPercentage,
      tracking_token: randomUUID(),
      commission_locked_at: new Date(),
    };
  }

  private sideLabel(side: ReferralSide): string {
    return side === 'buyer' ? 'Buyer-side' : 'Seller-side';
  }
}
