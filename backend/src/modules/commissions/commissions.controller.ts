import {
  Controller,
  Get,
  Query,
  Param,
  UseGuards,
  Request,
  HttpCode,
  HttpStatus,
  ForbiddenException,
  BadRequestException,
  Logger,
  Response,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiOkResponse,
  ApiBadRequestResponse,
  ApiUnauthorizedResponse,
  ApiNotFoundResponse,
  ApiForbiddenResponse,
  ApiParam,
  ApiQuery,
} from '@nestjs/swagger';
import { Response as ExpressResponse } from 'express';
import { CommissionsService } from './commissions.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { IsAdmin } from '../../common/decorators/is-admin.decorator';
import {
  CommissionLedgerQueryDto,
  CommissionSummaryQueryDto,
  UserCommissionQueryDto,
  DealCommissionQueryDto,
  CommissionExportQueryDto,
} from './commissions.dto';
import {
  IPaginatedCommissionResponse,
  ICommissionSummary,
  IUserCommissionSummary,
  IDealCommissionSummary,
} from './commissions.interface';

/**
 * Commissions Controller
 *
 * REST API endpoints for commission ledger tracking, reporting, and analysis.
 * Provides endpoints for:
 * - Viewing commission ledger with pagination and filters
 * - Generating commission summaries and statistics
 * - Retrieving user and deal-specific commission data
 * - Exporting commission data in CSV format
 * - Admin-only endpoints for comprehensive reporting
 *
 * All endpoints protected by JWT authentication.
 * User-level permission checks ensure users can only view their own commissions
 * (except admins who can view all).
 *
 * Base Path: /v1/commissions
 *
 * Endpoints:
 * - GET /ledger - Paginated commission ledger with filters
 * - GET /summary - Overall commission summary
 * - GET /user/:userId - Per-user commission summary
 * - GET /deal/:dealId - Deal-specific commissions
 * - GET /export - CSV export of commission data
 * - GET /statistics - Commission analytics and statistics
 * - GET /pending - Pending commissions (admin only)
 */
@ApiTags('Commissions')
@ApiBearerAuth()
@Controller('commissions')
@UseGuards(JwtAuthGuard)
export class CommissionsController {
  private readonly logger = new Logger(CommissionsController.name);

  constructor(private readonly commissionsService: CommissionsService) {}

  /**
   * Get paginated commission ledger with filters
   *
   * Retrieves commission entries with optional filtering by:
   * - commission_type: buyer_fee, seller_fee, platform_fee, referral_fee
   * - status: pending, approved, paid
   * - deal_id: Filter by specific deal
   * - date range: from_date and to_date (ISO 8601)
   * - user_id: Filter by user (for admin only)
   *
   * Non-admin users automatically see only their own commissions.
   * Returns 20 entries per page by default.
   *
   * @param query - Query parameters with filters and pagination
   * @param req - Express request with authenticated user
   * @returns Paginated list of commission ledger entries with deal details
   * @throws 400 Bad Request if page/limit are invalid
   * @throws 401 Unauthorized if token is invalid
   *
   * @example
   * GET /commissions/ledger?commission_type=buyer_fee&status=pending&page=1&limit=20
   * 
   * Response:
   * {
   *   "data": [...],
   *   "total": 150,
   *   "page": 1,
   *   "limit": 20,
   *   "total_pages": 8,
   *   "has_more": true
   * }
   */
  @Get('ledger')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get commission ledger with filters and pagination',
    description:
      'Retrieve paginated list of commission entries with optional filtering by type, status, deal, and date range. Non-admin users can only view their own commissions.',
  })
  @ApiQuery({
    name: 'commission_type',
    required: false,
    enum: ['buyer_fee', 'seller_fee', 'platform_fee', 'referral_fee'],
    description: 'Filter by commission type',
  })
  @ApiQuery({
    name: 'status',
    required: false,
    enum: ['pending', 'approved', 'paid'],
    description: 'Filter by commission status',
  })
  @ApiQuery({
    name: 'deal_id',
    required: false,
    type: Number,
    description: 'Filter by deal ID',
  })
  @ApiQuery({
    name: 'user_id',
    required: false,
    type: Number,
    description: 'Filter by user ID (admin only)',
  })
  @ApiQuery({
    name: 'from_date',
    required: false,
    type: String,
    description: 'Start date (ISO 8601 format)',
  })
  @ApiQuery({
    name: 'to_date',
    required: false,
    type: String,
    description: 'End date (ISO 8601 format)',
  })
  @ApiQuery({
    name: 'page',
    required: false,
    type: Number,
    description: 'Page number (default: 1)',
  })
  @ApiQuery({
    name: 'limit',
    required: false,
    type: Number,
    description: 'Items per page (default: 20, max: 100)',
  })
  @ApiOkResponse({
    description: 'Paginated commission ledger retrieved successfully',
    type: Object,
  })
  @ApiBadRequestResponse({
    description: 'Invalid query parameters',
  })
  @ApiUnauthorizedResponse({
    description: 'Unauthorized - Invalid or expired JWT token',
  })
  async getLedger(
    @Query() query: CommissionLedgerQueryDto,
    @Request() req: any,
  ): Promise<IPaginatedCommissionResponse> {
    const userId = req.user.userId;
    const isAdmin = req.user.isAdmin || false;

    this.logger.debug(
      `User ${userId} (admin: ${isAdmin}) requested commission ledger with filters: ${JSON.stringify(query)}`,
    );

    const options = {
      page: query.page || 1,
      limit: query.limit || 20,
      commission_type: query.commission_type,
      status: query.status,
      deal_id: query.deal_id,
      user_id: query.user_id,
      from_date: query.from_date ? new Date(query.from_date) : undefined,
      to_date: query.to_date ? new Date(query.to_date) : undefined,
    };

    return await this.commissionsService.getCommissionLedger(
      options,
      userId,
      isAdmin,
    );
  }

  /**
   * Get overall commission summary statistics
   *
   * Returns aggregated commission data across all commissions:
   * - Total amount and count
   * - Breakdown by commission type (buyer_fee, seller_fee, etc.)
   * - Breakdown by status (pending, approved, paid)
   * - Average amounts by status
   *
   * Optional date range filtering.
   * Non-admin users see only their own summaries.
   *
   * @param query - Query parameters with optional date filters
   * @param req - Express request with authenticated user
   * @returns Commission summary with aggregated data
   * @throws 401 Unauthorized if token is invalid
   *
   * @example
   * GET /commissions/summary?from_date=2024-01-01&to_date=2024-12-31
   * 
   * Response:
   * {
   *   "total_amount": 500000,
   *   "total_count": 150,
   *   "pending_amount": 100000,
   *   "pending_count": 30,
   *   "approved_amount": 200000,
   *   "approved_count": 60,
   *   "paid_amount": 200000,
   *   "paid_count": 60,
   *   "by_type": [...],
   *   "by_status": [...]
   * }
   */
  @Get('summary')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get commission summary and statistics',
    description:
      'Retrieve aggregated commission data including totals by type and status, with optional date range filtering. Non-admin users see only their own summary.',
  })
  @ApiQuery({
    name: 'from_date',
    required: false,
    type: String,
    description: 'Start date (ISO 8601 format)',
  })
  @ApiQuery({
    name: 'to_date',
    required: false,
    type: String,
    description: 'End date (ISO 8601 format)',
  })
  @ApiQuery({
    name: 'commission_type',
    required: false,
    enum: ['buyer_fee', 'seller_fee', 'platform_fee', 'referral_fee'],
    description: 'Filter by commission type',
  })
  @ApiQuery({
    name: 'status',
    required: false,
    enum: ['pending', 'approved', 'paid'],
    description: 'Filter by status',
  })
  @ApiOkResponse({
    description: 'Commission summary retrieved successfully',
    type: Object,
  })
  @ApiUnauthorizedResponse({
    description: 'Unauthorized - Invalid or expired JWT token',
  })
  async getSummary(
    @Query() query: CommissionSummaryQueryDto,
    @Request() req: any,
  ): Promise<ICommissionSummary> {
    const userId = req.user.userId;
    const isAdmin = req.user.isAdmin || false;

    this.logger.debug(
      `User ${userId} (admin: ${isAdmin}) requested commission summary with filters: ${JSON.stringify(query)}`,
    );

    const filters = {
      from_date: query.from_date ? new Date(query.from_date) : undefined,
      to_date: query.to_date ? new Date(query.to_date) : undefined,
      commission_type: query.commission_type,
      status: query.status,
    };

    return await this.commissionsService.getCommissionSummary(
      filters,
      userId,
      isAdmin,
    );
  }

  /**
   * Get per-user commission summary
   *
   * Returns commission breakdown for a specific user:
   * - Total commissions and amounts
   * - Missing breakdown by status (pending, approved, paid)
   * - Breakdown by commission type (buyer_fee, seller_fee, etc.)
   * - Last payment date
   *
   * Non-admin users can only view their own summary.
   * Admins can view any user's summary.
   *
   * @param userId - ID of the user to query
   * @param query - Optional date filters
   * @param req - Express request with authenticated user
   * @returns User commission summary
   * @throws 403 Forbidden if user tries to access other's data (non-admin)
   * @throws 404 Not Found if user does not exist
   * @throws 401 Unauthorized if token is invalid
   *
   * @example
   * GET /commissions/user/123
   * 
   * Response:
   * {
   *   "user_id": 123,
   *   "user_name": "John Doe",
   *   "user_mobile": "9876543210",
   *   "user_email": "john@example.com",
   *   "total_commissions": 25,
   *   "total_amount": 50000,
   *   "pending_amount": 10000,
   *   "approved_amount": 20000,
   *   "paid_amount": 20000,
   *   "commission_details": {
   *     "buyer_fee": 15000,
   *     "seller_fee": 20000,
   *     "platform_fee": 10000,
   *     "referral_fee": 5000
   *   },
   *   "last_payment_date": "2024-03-15T10:30:00Z"
   * }
   */
  @Get('user/:userId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get per-user commission summary',
    description:
      'Retrieve commission summary for a specific user including totals by status and type. Non-admin users can only view their own summary.',
  })
  @ApiParam({
    name: 'userId',
    type: Number,
    description: 'ID of the user to query',
  })
  @ApiQuery({
    name: 'from_date',
    required: false,
    type: String,
    description: 'Start date (ISO 8601 format)',
  })
  @ApiQuery({
    name: 'to_date',
    required: false,
    type: String,
    description: 'End date (ISO 8601 format)',
  })
  @ApiQuery({
    name: 'include_details',
    required: false,
    type: Boolean,
    description: 'Include individual commission entries',
  })
  @ApiOkResponse({
    description: 'User commission summary retrieved successfully',
    type: Object,
  })
  @ApiForbiddenResponse({
    description: 'Forbidden - Cannot view other users\' commissions (non-admin)',
  })
  @ApiNotFoundResponse({
    description: 'User not found',
  })
  @ApiUnauthorizedResponse({
    description: 'Unauthorized - Invalid or expired JWT token',
  })
  async getUserCommissions(
    @Param('userId') userId: number,
    @Query() query: UserCommissionQueryDto,
    @Request() req: any,
  ): Promise<IUserCommissionSummary> {
    const currentUserId = req.user.userId;
    const isAdmin = req.user.isAdmin || false;

    // Permission check
    if (!isAdmin && currentUserId !== userId) {
      this.logger.warn(
        `User ${currentUserId} attempted to access commissions of user ${userId} without admin privileges`,
      );
      throw new ForbiddenException(
        'You can only view your own commission summary',
      );
    }

    this.logger.debug(
      `User ${currentUserId} (admin: ${isAdmin}) requested commission summary for user ${userId}`,
    );

    return await this.commissionsService.getUserCommissionSummary(
      userId,
      query.from_date ? new Date(query.from_date) : undefined,
      query.to_date ? new Date(query.to_date) : undefined,
      currentUserId,
      isAdmin,
    );
  }

  /**
   * Get commissions for a specific deal
   *
   * Returns all commission entries associated with a single deal:
   * - Commission breakdown by type
   * - Current status and payment information
   * - Buyer and seller information
   * - Total commissions for the deal
   *
   * Non-admin users can only view commissions for deals they're involved with
   * (as buyer or seller).
   * Admins can view any deal's commissions.
   *
   * @param dealId - ID of the deal to query
   * @param query - Optional parameters
   * @param req - Express request with authenticated user
   * @returns Deal commission summary with all entries
   * @throws 403 Forbidden if user not involved in deal (non-admin)
   * @throws 404 Not Found if deal does not exist
   * @throws 401 Unauthorized if token is invalid
   *
   * @example
   * GET /commissions/deal/456
   * 
   * Response:
   * {
   *   "deal_id": 456,
   *   "deal_value": 1000000,
   *   "buyer_user_id": 123,
   *   "seller_user_id": 124,
   *   "total_commissions": 50000,
   *   "commissions": [
   *     {
   *       "type": "buyer_fee",
   *       "amount": 15000,
   *       "percentage": 1.5,
   *       "status": "paid"
   *     },
   *     ...
   *   ]
   * }
   */
  @Get('deal/:dealId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get commissions for a specific deal',
    description:
      'Retrieve all commission entries associated with a single deal. Non-admin users can only view commissions for deals they are involved with.',
  })
  @ApiParam({
    name: 'dealId',
    type: Number,
    description: 'ID of the deal to query',
  })
  @ApiQuery({
    name: 'include_ledger',
    required: false,
    type: Boolean,
    description: 'Include all commission ledger entries',
  })
  @ApiOkResponse({
    description: 'Deal commissions retrieved successfully',
    type: Object,
  })
  @ApiForbiddenResponse({
    description: 'Forbidden - Not involved in this deal (non-admin)',
  })
  @ApiNotFoundResponse({
    description: 'Deal not found',
  })
  @ApiUnauthorizedResponse({
    description: 'Unauthorized - Invalid or expired JWT token',
  })
  async getDealCommissions(
    @Param('dealId') dealId: number,
    @Query() query: DealCommissionQueryDto,
    @Request() req: any,
  ): Promise<IDealCommissionSummary> {
    const userId = req.user.userId;
    const isAdmin = req.user.isAdmin || false;

    this.logger.debug(
      `User ${userId} (admin: ${isAdmin}) requested commissions for deal ${dealId}`,
    );

    return await this.commissionsService.getDealCommissions(
      dealId,
      userId,
      isAdmin,
    );
  }

  /**
   * Export commission data as CSV
   *
   * Generates a CSV file with commission ledger data based on filters.
   * Each row represents one commission entry with all details.
   *
   * CSV Format:
   * - Columns: id, deal_id, commission_type, amount, percentage_applied,
   *            status, payment_date, payment_reference, notes,
   *            created_date, updated_date
   * - Values are properly escaped for CSV format
   * - Date fields formatted as YYYY-MM-DD
   *
   * Non-admin users can only export their own commissions.
   * Admins can export any filtered subset.
   *
   * @param query - Query parameters with optional filters
   * @param req - Express request with authenticated user
   * @param res - Express response for file download
   * @throws 400 Bad Request if no data matches filters
   * @throws 401 Unauthorized if token is invalid
   *
   * @example
   * GET /commissions/export?status=paid&from_date=2024-01-01&to_date=2024-12-31
   * 
   * Response: CSV file download
   * id,deal_id,commission_type,amount,percentage_applied,status,...
   * 1,101,buyer_fee,15000,1.5,paid,...
   * ...
   */
  @Get('export')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Export commission data as CSV',
    description:
      'Download commission ledger as CSV file with optional filtering. Non-admin users can only export their own commissions.',
  })
  @ApiQuery({
    name: 'commission_type',
    required: false,
    enum: ['buyer_fee', 'seller_fee', 'platform_fee', 'referral_fee'],
    description: 'Filter by commission type',
  })
  @ApiQuery({
    name: 'status',
    required: false,
    enum: ['pending', 'approved', 'paid'],
    description: 'Filter by status',
  })
  @ApiQuery({
    name: 'from_date',
    required: false,
    type: String,
    description: 'Start date (ISO 8601 format)',
  })
  @ApiQuery({
    name: 'to_date',
    required: false,
    type: String,
    description: 'End date (ISO 8601 format)',
  })
  @ApiQuery({
    name: 'format',
    required: false,
    type: String,
    description: 'Export format (default: csv)',
  })
  @ApiOkResponse({
    description: 'CSV file generated successfully',
    content: {
      'text/csv': {
        schema: {
          type: 'string',
        },
      },
    },
  })
  @ApiBadRequestResponse({
    description: 'No data found for export with given criteria',
  })
  @ApiUnauthorizedResponse({
    description: 'Unauthorized - Invalid or expired JWT token',
  })
  async exportCommissions(
    @Query() query: CommissionExportQueryDto,
    @Request() req: any,
    @Response() res: ExpressResponse,
  ): Promise<void> {
    const userId = req.user.userId;
    const isAdmin = req.user.isAdmin || false;

    this.logger.debug(
      `User ${userId} (admin: ${isAdmin}) requested commission export with filters: ${JSON.stringify(query)}`,
    );

    const filters = {
      commission_type: query.commission_type,
      status: query.status,
      from_date: query.from_date ? new Date(query.from_date) : undefined,
      to_date: query.to_date ? new Date(query.to_date) : undefined,
    };

    const csvData = await this.commissionsService.exportCommissionsToCSV(
      filters,
      userId,
      isAdmin,
    );

    // Set response headers for file download
    const timestamp = new Date().toISOString().split('T')[0];
    res.setHeader('Content-Type', 'text/csv; charset=utf-8');
    res.setHeader(
      'Content-Disposition',
      `attachment; filename="commissions_${timestamp}.csv"`,
    );
    res.setHeader('Content-Length', Buffer.byteLength(csvData, 'utf-8'));

    this.logger.log(
      `Commission export generated for user ${userId}: ${csvData.split('\n').length - 1} rows`,
    );

    res.send(csvData);
  }

  /**
   * Get commission statistics and analytics (admin only)
   *
   * Returns detailed commission statistics:
   * - Total deals with commissions
   * - Average commission amounts
   * - Commission distribution by type and status
   * - Commission trend data
   *
   * Admin-only endpoint.
   *
   * @param req - Express request with authenticated user
   * @returns Commission statistics object
   * @throws 403 Forbidden if user is not admin
   * @throws 401 Unauthorized if token is invalid
   *
   * @example
   * GET /commissions/statistics
   * 
   * Response:
   * {
   *   "total_deals_with_commissions": 1500,
   *   "average_deal_commission_amount": 33333.33,
   *   "total_commission_amount": 50000000,
   *   "total_commission_entries": 1500,
   *   "commission_distribution": {...}
   * }
   */
  @Get('statistics')
  @HttpCode(HttpStatus.OK)
  @IsAdmin()
  @ApiOperation({
    summary: 'Get commission statistics and analytics (admin only)',
    description:
      'Retrieve detailed commission statistics including distribution by type and status. Admin-only endpoint.',
  })
  @ApiOkResponse({
    description: 'Commission statistics retrieved successfully',
    type: Object,
  })
  @ApiForbiddenResponse({
    description: 'Forbidden - Admin access required',
  })
  @ApiUnauthorizedResponse({
    description: 'Unauthorized - Invalid or expired JWT token',
  })
  async getStatistics(@Request() req: any): Promise<any> {
    const userId = req.user.userId;
    this.logger.debug(`Admin user ${userId} requested commission statistics`);

    return await this.commissionsService.getCommissionStatistics();
  }

  /**
   * Get pending commissions (admin only)
   *
   * Retrieves all commissions with pending status.
   * Used for payment processing and administrative reporting.
   *
   * Admin-only endpoint.
   *
   * @param req - Express request with authenticated user
   * @returns Array of pending commission entries
   * @throws 403 Forbidden if user is not admin
   * @throws 401 Unauthorized if token is invalid
   *
   * @example
   * GET /commissions/pending
   * 
   * Response: [
   *   {
   *     "id": 1,
   *     "deal_id": 101,
   *     "commission_type": "buyer_fee",
   *     "amount": 15000,
   *     "status": "pending",
   *     ...
   *   },
   *   ...
   * ]
   */
  @Get('pending')
  @HttpCode(HttpStatus.OK)
  @IsAdmin()
  @ApiOperation({
    summary: 'Get pending commissions (admin only)',
    description:
      'Retrieve all commissions with pending status for payment processing. Admin-only endpoint.',
  })
  @ApiOkResponse({
    description: 'Pending commissions retrieved successfully',
    type: Array,
  })
  @ApiForbiddenResponse({
    description: 'Forbidden - Admin access required',
  })
  @ApiUnauthorizedResponse({
    description: 'Unauthorized - Invalid or expired JWT token',
  })
  async getPendingCommissions(@Request() req: any): Promise<any> {
    const userId = req.user.userId;
    this.logger.debug(`Admin user ${userId} requested pending commissions`);

    return await this.commissionsService.getPendingCommissions();
  }
}
