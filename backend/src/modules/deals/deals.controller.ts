import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
  HttpCode,
  HttpStatus,
  BadRequestException,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiParam,
  ApiQuery,
} from '@nestjs/swagger';
import { DealsService } from './deals.service';
import { CreateDealDto } from './dto/create-deal.dto';
import { CloseDealDto } from './dto/close-deal.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { AdminGuard } from '../../common/guards/admin.guard';

/**
 * Deals Controller
 * 
 * Manages deal lifecycle:
 * - Create new deals (admin-only)
 * - Close deals and trigger commissions (admin-only)
 * - Get deal details with breakdowns
 * - List deals with filtering and pagination
 * 
 * All endpoints require JWT authentication
 * Create and close endpoints additionally require admin role
 * 
 * Endpoints:
 * - POST /deals → Create deal
 * - GET /deals/:id → Get deal detail with referral mappings and commissions
 * - POST /deals/:id/close → Close deal and trigger commission calculations
 * - GET /deals → List deals with filters
 */
@ApiTags('Deals')
@Controller('deals')
@ApiBearerAuth('JWT')
@UseGuards(JwtAuthGuard)
export class DealsController {
  constructor(private readonly dealsService: DealsService) {}

  /**
   * Create a new deal
   * 
   * Admin-only endpoint that creates a new deal transaction
   * between a buyer and seller for a property/project.
   * 
   * Business Rules:
   * - Both buyer and seller must exist
   * - Buyer and seller must be different users
   * - Property must be verified (if property_id provided)
   * - Property cannot already be sold
   * - Commission percentages are locked at creation
   * - DealReferralMapping created only if referral_partner_id provided
   * 
   * Commission Calculation:
   * - Buyer Fee: 2% of transaction_value
   * - Seller Fee: 2% of transaction_value
   * - Referral Split: 50% to referral partner, 50% to platform (if referral exists)
   * 
   * @param req Express request with authenticated user (admin)
   * @param createDealDto Deal creation details
   * @returns Created deal with referral mappings (status: open)
   */
  @Post()
  @UseGuards(AdminGuard)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create a new deal',
    description: 'Admin-only: Create a new deal transaction with buyer, seller, and optional referral partner',
  })
  @ApiResponse({
    status: 201,
    description: 'Deal created successfully',
    schema: {
      example: {
        id: 1,
        buyer_user_id: 10,
        seller_user_id: 20,
        property_id: 5,
        transaction_value: '1000000.00',
        status: 'open',
        referral_partner_id: null,
        commission_locked_at: null,
        payment_status: 'pending',
        created_at: '2026-03-31T10:00:00Z',
        buyer_commission_percentage: 2,
        seller_commission_percentage: 2,
      },
    },
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid request - buyer/seller not found, property not verified, or same buyer/seller',
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - JWT token missing or invalid',
  })
  @ApiResponse({
    status: 403,
    description: 'Forbidden - User is not an admin',
  })
  async createDeal(
    @Request() req: any,
    @Body() createDealDto: CreateDealDto,
  ) {
    // Validate XOR: either property_id or project_id, not both, not neither
    const hasPropertyId = createDealDto.property_id !== undefined && createDealDto.property_id !== null;
    const hasProjectId = createDealDto.project_id !== undefined && createDealDto.project_id !== null;

    if (!hasPropertyId && !hasProjectId) {
      throw new BadRequestException('Either property_id or project_id must be provided');
    }

    if (hasPropertyId && hasProjectId) {
      throw new BadRequestException('Cannot provide both property_id and project_id - choose one');
    }

    const adminId = req.user.userId;
    return await this.dealsService.createDeal(createDealDto, adminId);
  }

  /**
   * Get deal details
   * 
   * Retrieves complete deal information including:
   * - Buyer and seller details
   * - Property/Project information
   * - Referral mappings (if any)
   * - Commission ledger entries
   * 
   * @param id Deal ID
   * @returns Deal with all related data
   */
  @Get(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get deal details',
    description: 'Retrieve complete deal information with all related data (referrals, commissions, etc.)',
  })
  @ApiParam({
    name: 'id',
    description: 'Deal ID',
    example: 1,
  })
  @ApiResponse({
    status: 200,
    description: 'Deal details retrieved successfully',
    schema: {
      example: {
        deal: {
          id: 1,
          buyer_user_id: 10,
          seller_user_id: 20,
          property_id: 5,
          transaction_value: '1000000.00',
          status: 'open',
          payment_status: 'pending',
        },
        referral_mappings: [],
        commission_ledgers: [],
      },
    },
  })
  @ApiResponse({
    status: 404,
    description: 'Deal not found',
  })
  async getDealById(@Param('id') id: string) {
    return await this.dealsService.getDealById(parseInt(id, 10));
  }

  /**
   * Close a deal
   * 
   * Admin-only endpoint that finalizes a deal:
   * 1. Updates deal status to 'closed'
   * 2. Locks property as 'sold'
   * 3. Creates commission ledger entries
   * 4. Locks commission percentages
   * 
   * Commission Ledger Creation:
   * - Buyer fee ledger (2% of transaction)
   * - Seller fee ledger (2% of transaction)
   * - Referral fee ledger (if referral exists)
   * - Platform fee ledger (remainder)
   * 
   * @param id Deal ID to close
   * @param closeDealDto Closure details (optional notes, date, proof)
   * @returns Closed deal with commission ledgers created
   */
  @Post(':id/close')
  @UseGuards(AdminGuard)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Close a deal',
    description: 'Admin-only: Finalize deal closure and trigger commission calculations',
  })
  @ApiParam({
    name: 'id',
    description: 'Deal ID to close',
    example: 1,
  })
  @ApiResponse({
    status: 200,
    description: 'Deal closed successfully with commission ledgers created',
    schema: {
      example: {
        deal: {
          id: 1,
          status: 'closed',
          deal_closed_at: '2026-03-31T10:00:00Z',
        },
        commission_ledgers: [
          {
            id: 1,
            deal_id: 1,
            commission_type: 'buyer_fee',
            amount: '20000.00',
            status: 'pending',
          },
        ],
      },
    },
  })
  @ApiResponse({
    status: 404,
    description: 'Deal not found',
  })
  @ApiResponse({
    status: 409,
    description: 'Deal is already closed',
  })
  async closeDeal(
    @Param('id') id: string,
    @Body() closeDealDto: CloseDealDto,
  ) {
    return await this.dealsService.closeDeal(parseInt(id, 10), closeDealDto);
  }

  /**
   * List all deals
   * 
   * Retrieves paginated list of deals with optional filtering by status.
   * 
   * Query Parameters:
   * - status: Filter by deal status (open, closed)
   * - page: Page number (1-indexed, default: 1)
   * - limit: Items per page (default: 20, max: 100)
   * 
   * @param status Optional status filter
   * @param page Page number (1-indexed)
   * @param limit Items per page
   * @returns Paginated list of deals with pagination metadata
   */
  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'List all deals',
    description: 'Get paginated list of deals with optional status filtering',
  })
  @ApiQuery({
    name: 'status',
    description: 'Filter by deal status (open, closed)',
    required: false,
    example: 'open',
  })
  @ApiQuery({
    name: 'page',
    description: 'Page number (1-indexed)',
    required: false,
    example: 1,
  })
  @ApiQuery({
    name: 'limit',
    description: 'Items per page (default: 20)',
    required: false,
    example: 20,
  })
  @ApiResponse({
    status: 200,
    description: 'Deals list retrieved successfully',
    schema: {
      example: {
        data: [
          {
            id: 1,
            buyer_user_id: 10,
            seller_user_id: 20,
            property_id: 5,
            transaction_value: '1000000.00',
            status: 'open',
          },
        ],
        pagination: {
          total: 100,
          page: 1,
          limit: 20,
          pages: 5,
        },
      },
    },
  })
  async listDeals(
    @Query('status') status?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return await this.dealsService.listDeals(
      page ? parseInt(page, 10) : 1,
      limit ? parseInt(limit, 10) : 20,
      status as 'open' | 'closed' | undefined,
    );
  }
}

