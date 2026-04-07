import {
  Controller,
  Get,
  Post,
  Put,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
  HttpCode,
  HttpStatus,
  ParseIntPipe,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiBody,
  ApiOkResponse,
  ApiCreatedResponse,
  ApiBadRequestResponse,
  ApiUnauthorizedResponse,
  ApiNotFoundResponse,
  ApiParam,
  ApiQuery,
} from '@nestjs/swagger';
import { ReferralPartnersService } from './referral-partners.service';
import { CreateReferralPartnerDto } from './dto/create-referral-partner.dto';
import { UpdateReferralPartnerDto } from './dto/update-referral-partner.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { IsAdmin } from '../../common/decorators/is-admin.decorator';
import {
  IReferralPartnerDetail,
  ICreateReferralPartnerResponse,
  IStatusTransitionResponse,
  ICommissionSummary,
  IMobileVerificationResponse,
} from './referral-partner.interface';

/**
 * Referral Partners Controller
 * 
 * REST API endpoints for managing referral partners (agents and verified users)
 * 
 * Features:
 * - Self-service registration
 * - Admin approval workflow
 * - Commission tracking
 * - Status management (approve, suspend, reactivate)
 * - Commission summary and earnings history
 * 
 * Authentication:
 * - Public: POST /register (new registration)
 * - Public: POST /verify-mobile (mobile verification)
 * - Protected: All other endpoints require JWT Bearer token
 * - Admin-only: Approve, suspend, reactivate endpoints
 * 
 * Base Path: /v1/referral-partners
 */
@ApiTags('Referral Partners')
@Controller('referral-partners')
export class ReferralPartnersController {
  constructor(private readonly referralPartnersService: ReferralPartnersService) {}

  /**
   * Register new referral partner
   * 
   * Public endpoint for self-registration of agents or verified users
   * 
   * Workflow:
   * 1. Validate input data
   * 2. Check mobile/email uniqueness
   * 3. Create partner record (status: pending)
   * 4. Link to User if found
   * 
   * Response Status:
   * - 201: Partner registered successfully
   * - 400: Validation error or duplicate mobile/email
   * 
   * @param createDto - Partner registration data
   * @returns Created partner info with ID and status
   * 
   * @example
   * POST /v1/referral-partners
   * {
   *   "mobile_number": "9876543210",
   *   "full_name": "Rajesh Kumar",
   *   "email": "rajesh@example.com",
   *   "city": "Mumbai",
   *   "partner_type": "agent",
   *   "agent_license_number": "MH2024-ABC12345",
   *   "agency_name": "Premium Real Estate"
   * }
   */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Register new referral partner',
    description:
      'Self-registration endpoint for agents and verified users to become referral partners',
  })
  @ApiBody({ type: CreateReferralPartnerDto })
  @ApiCreatedResponse({
    description: 'Partner registered successfully',
    schema: {
      example: {
        id: 1,
        mobile_number: '9876543210',
        partner_type: 'agent',
        status: 'pending',
        message: 'Referral partner registered successfully. Status: pending verification',
      },
    },
  })
  @ApiBadRequestResponse({
    description: 'Validation error or duplicate mobile/email',
    schema: {
      example: {
        statusCode: 400,
        message: 'Mobile number 9876543210 is already registered',
        error: 'Bad Request',
      },
    },
  })
  async registerReferralPartner(
    @Body() createDto: CreateReferralPartnerDto,
  ): Promise<ICreateReferralPartnerResponse> {
    return this.referralPartnersService.registerReferralPartner(createDto);
  }

  /**
   * Get paginated list of referral partners
   * 
   * Protected endpoint (requires JWT)
   * Lists all registered referral partners with filtering and pagination
   * 
   * Features:
   * - Pagination (page, limit)
   * - Filtering by status, partner_type, is_active
   * - Search by mobile, name, or email
   * - Sorted by creation date (newest first)
   * 
   * Response Status:
   * - 200: List retrieved successfully
   * - 401: Missing or invalid JWT token
   * 
   * @param req - Express request with authenticated user
   * @param page - Page number (default: 1)
   * @param limit - Items per page (default: 10)
   * @param status - Filter by status (pending, under_review, approved, rejected)
   * @param partnerType - Filter by type (agent, verified_user)
   * @param search - Search term
   * @param isActive - Filter by active status (true/false)
   * @returns Paginated list with metadata
   * 
   * @example
   * GET /v1/referral-partners?page=1&limit=10&status=approved&search=Mumbai
   */
  @Get()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get referral partners list',
    description: 'Retrieve paginated list of referral partners with filtering',
  })
  @ApiQuery({
    name: 'page',
    required: false,
    type: Number,
    description: 'Page number (default: 1)',
    example: 1,
  })
  @ApiQuery({
    name: 'limit',
    required: false,
    type: Number,
    description: 'Items per page (default: 10)',
    example: 10,
  })
  @ApiQuery({
    name: 'status',
    required: false,
    type: String,
    description: 'Filter by status (pending, under_review, approved, rejected)',
    example: 'approved',
  })
  @ApiQuery({
    name: 'partnerType',
    required: false,
    type: String,
    description: 'Filter by partner type (agent, verified_user)',
    example: 'agent',
  })
  @ApiQuery({
    name: 'search',
    required: false,
    type: String,
    description: 'Search by mobile, name, or email',
    example: '9876543210',
  })
  @ApiQuery({
    name: 'isActive',
    required: false,
    type: Boolean,
    description: 'Filter by active status',
    example: true,
  })
  @ApiOkResponse({
    description: 'Partners list retrieved successfully',
    schema: {
      example: {
        data: [
          {
            id: 1,
            mobile_number: '9876543210',
            full_name: 'Rajesh Kumar',
            partner_type: 'agent',
            status: 'approved',
            is_active: true,
            total_commission_earned: 150000,
            created_at: '2024-01-15T10:30:00Z',
          },
        ],
        total: 1,
        page: 1,
        limit: 10,
        total_pages: 1,
      },
    },
  })
  @ApiUnauthorizedResponse({ description: 'Invalid or missing JWT token' })
  async listReferralPartners(
    @Request() req: any,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
    @Query('status') status?: string,
    @Query('partnerType') partnerType?: string,
    @Query('search') search?: string,
    @Query('isActive') isActive?: boolean,
  ) {
    return this.referralPartnersService.listReferralPartners(
      page || 1,
      limit || 10,
      status,
      partnerType,
      search,
      isActive,
    );
  }

  /**
   * Get referral partner detail
   * 
   * Protected endpoint (requires JWT)
   * Returns complete partner information including commission history
   * 
   * Includes:
   * - Full partner profile
   * - Commission status and history
   * - Commission ledger
   * 
   * Response Status:
   * - 200: Partner details retrieved
   * - 401: Missing or invalid JWT token
   * - 404: Partner not found
   * 
   * @param id - Partner ID
   * @param req - Express request with authenticated user
   * @returns Partner details with commission history
   * 
   * @example
   * GET /v1/referral-partners/1
   */
  @Get(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get referral partner detail',
    description: 'Retrieve complete partner information with commission history',
  })
  @ApiParam({
    name: 'id',
    type: Number,
    description: 'Partner ID',
    example: 1,
  })
  @ApiOkResponse({
    description: 'Partner details retrieved successfully',
    schema: {
      example: {
        id: 1,
        user_id: 100,
        mobile_number: '9876543210',
        partner_type: 'agent',
        full_name: 'Rajesh Kumar',
        email: 'rajesh@example.com',
        city: 'Mumbai',
        agent_license_number: 'MH2024-ABC12345',
        agency_name: 'Premium Real Estate',
        status: 'approved',
        is_active: true,
        commission_enabled: true,
        total_commission_earned: 150000,
        yearly_maintenance_fee_status: 'paid',
        commission_ledger: [
          {
            id: 1,
            deal_id: 10,
            amount: 50000,
            commission_type: 'referral_fee',
            status: 'paid',
            created_at: '2024-01-15T10:30:00Z',
          },
        ],
        created_at: '2024-01-10T10:30:00Z',
        updated_at: '2024-01-15T10:30:00Z',
      },
    },
  })
  @ApiUnauthorizedResponse({ description: 'Invalid or missing JWT token' })
  @ApiNotFoundResponse({ description: 'Partner not found' })
  async getReferralPartnerDetail(
    @Param('id', ParseIntPipe) id: number,
    @Request() req: any,
  ) {
    return this.referralPartnersService.getReferralPartnerDetail(id);
  }

  /**
   * Update referral partner information
   * 
   * Protected endpoint (requires JWT)
   * Both self-service and admin updates
   * 
   * Rules:
   * - Non-admins can only update their own profile
   * - Mobile number cannot be updated
   * - Partner type cannot be updated
   * - Status cannot be updated via this endpoint
   * 
   * Response Status:
   * - 200: Partner updated successfully
   * - 400: Validation error
   * - 401: Missing or invalid JWT token
   * - 403: Forbidden (trying to update another user's profile)
   * - 404: Partner not found
   * 
   * @param id - Partner ID to update
   * @param updateDto - Fields to update
   * @param req - Express request with authenticated user
   * @returns Updated partner details
   * 
   * @example
   * PUT /v1/referral-partners/1
   * {
   *   "full_name": "Rajesh Kumar Singh",
   *   "email": "rajesh.new@example.com"
   * }
   */
  @Put(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Update referral partner',
    description: 'Update partner information (self-service or admin)',
  })
  @ApiParam({
    name: 'id',
    type: Number,
    description: 'Partner ID',
    example: 1,
  })
  @ApiBody({ type: UpdateReferralPartnerDto })
  @ApiOkResponse({
    description: 'Partner updated successfully',
    schema: {
      example: {
        id: 1,
        mobile_number: '9876543210',
        full_name: 'Rajesh Kumar Singh',
        email: 'rajesh.new@example.com',
        city: 'Mumbai',
        partner_type: 'agent',
        status: 'approved',
      },
    },
  })
  @ApiBadRequestResponse({ description: 'Validation error or email duplicate' })
  @ApiUnauthorizedResponse({ description: 'Invalid or missing JWT token' })
  @ApiNotFoundResponse({ description: 'Partner not found' })
  async updateReferralPartner(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: UpdateReferralPartnerDto,
    @Request() req: any,
  ): Promise<IReferralPartnerDetail> {
    // TODO: Get isAdmin from request (from auth guard or decorator)
    // For now, checking if req.user has admin role
    const isAdmin = req.user?.is_admin === true;
    const requestingPartnerId = req.user?.id; // From JWT payload

    return this.referralPartnersService.updateReferralPartner(
      id,
      updateDto,
      isAdmin,
      requestingPartnerId,
    );
  }

  /**
   * Approve referral partner
   * 
   * Admin-only endpoint
   * Changes partner status from pending/under_review to approved
   * Enables commission tracking
   * 
   * Response Status:
   * - 200: Partner approved successfully
   * - 401: Missing or invalid JWT token
   * - 403: Not authorized (admin only)
   * - 404: Partner not found
   * - 400: Partner not in approvable status
   * 
   * @param id - Partner ID to approve
   * @param req - Express request with authenticated user
   * @returns Status transition response
   * 
   * @example
   * POST /v1/referral-partners/1/approve
   */
  @Post(':id/approve')
  @UseGuards(JwtAuthGuard)
  @IsAdmin()
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Approve referral partner',
    description: 'Admin-only: Approve pending or under-review partner for commissions',
  })
  @ApiParam({
    name: 'id',
    type: Number,
    description: 'Partner ID',
    example: 1,
  })
  @ApiOkResponse({
    description: 'Partner approved successfully',
    schema: {
      example: {
        id: 1,
        mobile_number: '9876543210',
        previous_status: 'pending',
        new_status: 'approved',
        timestamp: '2024-01-15T10:30:00Z',
      },
    },
  })
  @ApiUnauthorizedResponse({ description: 'Invalid or missing JWT token' })
  @ApiNotFoundResponse({ description: 'Partner not found' })
  async approvReferralPartner(
    @Param('id', ParseIntPipe) id: number,
    @Request() req: any,
  ): Promise<IStatusTransitionResponse> {
    return this.referralPartnersService.approveReferralPartner(id);
  }

  /**
   * Reject referral partner
   * 
   * Admin-only endpoint
   * Changes partner status to rejected
   * Disables commissions and deactivates account
   * 
   * Response Status:
   * - 200: Partner rejected successfully
   * - 401: Missing or invalid JWT token
   * - 403: Not authorized (admin only)
   * - 404: Partner not found
   * - 400: Partner not in rejectable status
   * 
   * @param id - Partner ID to reject
   * @param reason - Rejection reason (optional)
   * @param req - Express request with authenticated user
   * @returns Status transition response
   * 
   * @example
   * POST /v1/referral-partners/1/reject?reason=Invalid%20license
   */
  @Post(':id/reject')
  @UseGuards(JwtAuthGuard)
  @IsAdmin()
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Reject referral partner',
    description: 'Admin-only: Reject pending or under-review partner',
  })
  @ApiParam({
    name: 'id',
    type: Number,
    description: 'Partner ID',
    example: 1,
  })
  @ApiQuery({
    name: 'reason',
    required: false,
    type: String,
    description: 'Rejection reason',
  })
  @ApiOkResponse({
    description: 'Partner rejected successfully',
    schema: {
      example: {
        id: 1,
        mobile_number: '9876543210',
        previous_status: 'pending',
        new_status: 'rejected',
        timestamp: '2024-01-15T10:30:00Z',
      },
    },
  })
  @ApiUnauthorizedResponse({ description: 'Invalid or missing JWT token' })
  @ApiNotFoundResponse({ description: 'Partner not found' })
  async rejectReferralPartner(
    @Param('id', ParseIntPipe) id: number,
    @Query('reason') reason?: string,
    @Request() req?: any,
  ): Promise<IStatusTransitionResponse> {
    return this.referralPartnersService.rejectReferralPartner(id, reason);
  }

  /**
   * Suspend referral partner
   * 
   * Admin-only endpoint
   * Deactivates account and disables new commissions
   * Partner can be reactivated later
   * 
   * Response Status:
   * - 200: Partner suspended successfully
   * - 401: Missing or invalid JWT token
   * - 403: Not authorized (admin only)
   * - 404: Partner not found
   * 
   * @param id - Partner ID to suspend
   * @param req - Express request with authenticated user
   * @returns Status transition response
   * 
   * @example
   * POST /v1/referral-partners/1/suspend
   */
  @Post(':id/suspend')
  @UseGuards(JwtAuthGuard)
  @IsAdmin()
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Suspend referral partner',
    description: 'Admin-only: Temporarily suspend an active partner',
  })
  @ApiParam({
    name: 'id',
    type: Number,
    description: 'Partner ID',
    example: 1,
  })
  @ApiOkResponse({
    description: 'Partner suspended successfully',
    schema: {
      example: {
        id: 1,
        mobile_number: '9876543210',
        previous_status: 'active',
        new_status: 'suspended',
        timestamp: '2024-01-15T10:30:00Z',
      },
    },
  })
  @ApiUnauthorizedResponse({ description: 'Invalid or missing JWT token' })
  @ApiNotFoundResponse({ description: 'Partner not found' })
  async suspendReferralPartner(
    @Param('id', ParseIntPipe) id: number,
    @Request() req: any,
  ): Promise<IStatusTransitionResponse> {
    return this.referralPartnersService.suspendReferralPartner(id);
  }

  /**
   * Reactivate referral partner
   * 
   * Admin-only endpoint
   * Reactivates a suspended partner
   * Re-enables commissions if status is approved
   * 
   * Response Status:
   * - 200: Partner reactivated successfully
   * - 401: Missing or invalid JWT token
   * - 403: Not authorized (admin only)
   * - 404: Partner not found
   * 
   * @param id - Partner ID to reactivate
   * @param req - Express request with authenticated user
   * @returns Status transition response
   * 
   * @example
   * POST /v1/referral-partners/1/reactivate
   */
  @Post(':id/reactivate')
  @UseGuards(JwtAuthGuard)
  @IsAdmin()
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Reactivate referral partner',
    description: 'Admin-only: Reactivate a suspended partner',
  })
  @ApiParam({
    name: 'id',
    type: Number,
    description: 'Partner ID',
    example: 1,
  })
  @ApiOkResponse({
    description: 'Partner reactivated successfully',
    schema: {
      example: {
        id: 1,
        mobile_number: '9876543210',
        previous_status: 'suspended',
        new_status: 'active',
        timestamp: '2024-01-15T10:30:00Z',
      },
    },
  })
  @ApiUnauthorizedResponse({ description: 'Invalid or missing JWT token' })
  @ApiNotFoundResponse({ description: 'Partner not found' })
  async reactivateReferralPartner(
    @Param('id', ParseIntPipe) id: number,
    @Request() req: any,
  ): Promise<IStatusTransitionResponse> {
    return this.referralPartnersService.reactivateReferralPartner(id);
  }

  /**
   * Get commission summary for partner
   * 
   * Protected endpoint (requires JWT)
   * Returns earnings summary and commission ledger
   * 
   * Includes:
   * - Total earned amount
   * - Pending amount
   * - Paid amount
   * - Full commission ledger with status
   * 
   * Response Status:
   * - 200: Commission summary retrieved
   * - 401: Missing or invalid JWT token
   * - 404: Partner not found
   * 
   * @param id - Partner ID
   * @param req - Express request with authenticated user
   * @returns Commission summary with ledger
   * 
   * @example
   * GET /v1/referral-partners/1/commission-summary
   */
  @Get(':id/commission-summary')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get commission summary',
    description: 'Retrieve earnings summary and commission ledger for a partner',
  })
  @ApiParam({
    name: 'id',
    type: Number,
    description: 'Partner ID',
    example: 1,
  })
  @ApiOkResponse({
    description: 'Commission summary retrieved successfully',
    schema: {
      example: {
        partner_id: 1,
        total_earned: 250000,
        pending_amount: 50000,
        paid_amount: 200000,
        commission_ledger: [
          {
            id: 1,
            deal_id: 10,
            amount: 50000,
            commission_type: 'referral_fee',
            status: 'paid',
            created_at: '2024-01-15T10:30:00Z',
          },
        ],
      },
    },
  })
  @ApiUnauthorizedResponse({ description: 'Invalid or missing JWT token' })
  @ApiNotFoundResponse({ description: 'Partner not found' })
  async getCommissionSummary(
    @Param('id', ParseIntPipe) id: number,
    @Request() req: any,
  ): Promise<ICommissionSummary> {
    return this.referralPartnersService.getCommissionSummary(id);
  }

  /**
   * Verify mobile number
   * 
   * Public endpoint (no authentication required)
   * Checks if mobile exists in User database
   * Returns user details if found
   * 
   * Used for:
   * - Pre-registration validation
   * - Checking if user can be referred
   * - Linking partner to existing user
   * 
   * Response Status:
   * - 200: Verification completed
   * 
   * @param mobile - Mobile number to verify (query parameter)
   * @returns Verification result with user details if found
   * 
   * @example
   * GET /v1/referral-partners/verify-mobile?mobile=9876543210
   */
  @Get('/verify-mobile')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Verify mobile number',
    description:
      'Check if mobile number exists in User database (public endpoint)',
  })
  @ApiQuery({
    name: 'mobile',
    type: String,
    description: 'Mobile number to verify',
    example: '9876543210',
  })
  @ApiOkResponse({
    description: 'Mobile verification completed',
    schema: {
      example: {
        mobile_number: '9876543210',
        is_valid_user: true,
        partner_exists: false,
        user_details: {
          id: 100,
          full_name: 'Rajesh Kumar',
          profile_type: 'seller',
        },
      },
    },
  })
  async verifyMobileNumber(
    @Query('mobile') mobile: string,
  ): Promise<IMobileVerificationResponse> {
    return this.referralPartnersService.verifyMobileNumber(mobile);
  }
}
