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
  NotFoundException,
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
} from '@nestjs/swagger';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { AdminGuard } from '../../common/guards/admin.guard';
import { IUserListResponse, IUserProfile } from './user.interface';

/**
 * Users Controller - Complete User Profile Management
 *
 * REST API endpoints for user profile operations.
 * All endpoints require JWT Bearer token authentication (from Auth module).
 *
 * Endpoints:
 * - GET /users/profile - Retrieve authenticated user's profile
 * - POST /users/profile - Create/complete profile after OTP verification
 * - PUT /users/profile - Update profile (partial updates supported)
 * - POST /users/mode-select - Switch user role (buyer/seller/investor)
 * - GET /users/referral-validation/:mobile - Validate referral mobile number
 *
 * Security:
 * - All endpoints protected by JWT authentication guard
 * - Requires valid Bearer token in Authorization header
 * - Token issued by Auth module after OTP verification
 * - User ID extracted from JWT payload (req.user.userId)
 *
 * Error Handling:
 * - 400: Validation errors, duplicate email, invalid referral
 * - 401: Missing/invalid JWT token
 * - 404: User not found
 *
 * Flow:
 * 1. User registers with mobile number (Auth module)
 * 2. OTP verification returns JWT token (Auth module)
 * 3. User creates profile with profile data (this endpoint)
 * 4. User can update profile, switch roles, validate referrals
 */
@ApiTags('Users')
@ApiBearerAuth()
@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  @UseGuards(AdminGuard)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'List platform users',
    description: 'Admin-only user listing for deal creation, search, and reporting.',
  })
  @ApiOkResponse({
    description: 'Users retrieved successfully',
    type: Object,
  })
  @ApiUnauthorizedResponse({
    description: 'Unauthorized - Invalid or expired JWT token',
  })
  async listUsers(
    @Query('limit') limit?: string,
    @Query('offset') offset?: string,
    @Query('profile_type') profileType?: 'buyer' | 'seller' | 'investor',
    @Query('search') search?: string,
  ): Promise<IUserListResponse> {
    return await this.usersService.getAllUsers({
      limit: limit ? parseInt(limit, 10) : 20,
      offset: offset ? parseInt(offset, 10) : 0,
      profile_type: profileType,
      search,
    });
  }

  /**
   * Get current user profile
   * 
   * Returns the authenticated user's profile without sensitive fields
   * 
   * @param req - Express request with authenticated user (userId in payload)
   * @returns User profile object
   * @throws 401 Unauthorized if token is invalid/expired
   * @throws 404 Not Found if user not found
   */
  @Get('profile')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get current user profile',
    description: 'Retrieves the authenticated user\'s profile information without sensitive fields',
  })
  @ApiOkResponse({
    description: 'User profile retrieved successfully',
    type: Object,
  })
  @ApiUnauthorizedResponse({
    description: 'Unauthorized - Invalid or expired JWT token',
  })
  @ApiNotFoundResponse({
    description: 'User not found',
  })
  async getProfile(@Request() req: any): Promise<Partial<IUserProfile>> {
    const userId = req.user.userId;
    return await this.usersService.getUserProfile(userId);
  }

  /**
   * Create or complete user profile
   * 
   * Called after OTP verification to complete user profile.
   * If email is not unique, returns 400 error.
   * If referral_mobile_number is invalid, returns 400 error.
   * 
   * @param req - Express request with authenticated user (userId in payload)
   * @param createUserDto - Profile creation data
   * @returns Created/updated user profile
   * @throws 400 Bad Request if data is invalid or email/referral is invalid
   * @throws 401 Unauthorized if token is invalid/expired
   * @throws 404 Not Found if user not found
   */
  @Post('profile')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create or complete user profile',
    description: 'Creates or completes a user profile after OTP verification. Validates referral number if provided.',
  })
  @ApiBody({
    type: CreateUserDto,
    examples: {
      buyer: {
        value: {
          full_name: 'John Doe',
          email: 'john@example.com',
          city: 'Mumbai',
          profile_type: 'buyer',
          budget_range: '50-100 Lakhs',
          referral_mobile_number: '9876543210',
        },
      },
      seller: {
        value: {
          full_name: 'Jane Smith',
          email: 'jane@example.com',
          city: 'Bangalore',
          profile_type: 'seller',
        },
      },
    },
  })
  @ApiCreatedResponse({
    description: 'Profile created/completed successfully',
    type: Object,
  })
  @ApiBadRequestResponse({
    description: 'Invalid input data, email already exists, or invalid referral number',
  })
  @ApiUnauthorizedResponse({
    description: 'Unauthorized - Invalid or expired JWT token',
  })
  @ApiNotFoundResponse({
    description: 'User not found',
  })
  async createProfile(
    @Request() req: any,
    @Body() createUserDto: CreateUserDto,
  ): Promise<Partial<IUserProfile>> {
    const userId = req.user.userId;
    return await this.usersService.createOrCompleteProfile(userId, createUserDto);
  }

  /**
   * Update user profile
   * 
   * Allows partial updates to user profile.
   * Validates email uniqueness if email is being updated.
   * 
   * @param req - Express request with authenticated user (userId in payload)
   * @param updateUserDto - Partial profile update data
   * @returns Updated user profile
   * @throws 400 Bad Request if email already exists
   * @throws 401 Unauthorized if token is invalid/expired
   * @throws 404 Not Found if user not found
   */
  @Put('profile')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Update user profile',
    description: 'Updates user profile information. All fields are optional. Validates email uniqueness.',
  })
  @ApiBody({
    type: UpdateUserDto,
    examples: {
      partial: {
        value: {
          city: 'Bangalore',
          budget_range: '100-150 Lakhs',
        },
      },
      full: {
        value: {
          full_name: 'Jane Updated',
          email: 'jane.new@example.com',
          city: 'Pune',
          budget_range: '75-125 Lakhs',
        },
      },
    },
  })
  @ApiOkResponse({
    description: 'Profile updated successfully',
    type: Object,
  })
  @ApiBadRequestResponse({
    description: 'Invalid input data or email already in use',
  })
  @ApiUnauthorizedResponse({
    description: 'Unauthorized - Invalid or expired JWT token',
  })
  @ApiNotFoundResponse({
    description: 'User not found',
  })
  async updateProfile(
    @Request() req: any,
    @Body() updateUserDto: UpdateUserDto,
  ): Promise<Partial<IUserProfile>> {
    const userId = req.user.userId;
    return await this.usersService.updateUserProfile(userId, updateUserDto);
  }

  /**
   * Change profile type/role
   * 
   * Allows user to switch between available profile types.
   * 
   * @param req - Express request with authenticated user (userId in payload)
   * @param body - Profile type selection request
   * @returns Updated user profile with new profile type
   * @throws 400 Bad Request if profile_type value is invalid
   * @throws 401 Unauthorized if token is invalid/expired
   * @throws 404 Not Found if user not found
   */
  @Post('mode-select')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Change profile type/role',
    description: 'Allows authenticated users to switch between buyer, seller, and investor profile types. The selected type becomes active for subsequent operations.',
  })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        profile_type: {
          type: 'string',
          enum: ['buyer', 'seller', 'investor'],
          example: 'seller',
          description: 'The profile type to activate',
        },
      },
      required: ['profile_type'],
    },
    examples: {
      buyer: {
        value: { profile_type: 'buyer' },
      },
      seller: {
        value: { profile_type: 'seller' },
      },
      investor: {
        value: { profile_type: 'investor' },
      },
    },
  })
  @ApiOkResponse({
    description: 'Profile type changed successfully',
    type: Object,
  })
  @ApiBadRequestResponse({
    description: 'Invalid profile_type value',
  })
  @ApiUnauthorizedResponse({
    description: 'Unauthorized - Invalid or expired JWT token',
  })
  @ApiNotFoundResponse({
    description: 'User not found',
  })
  async selectMode(
    @Request() req: any,
    @Body() body: { profile_type: 'buyer' | 'seller' | 'investor' },
  ): Promise<Partial<IUserProfile>> {
    const userId = req.user.userId;
    return await this.usersService.selectProfileType(userId, body.profile_type);
  }

  /**
   * Validate referral mobile number
   * 
   * Validates if a referral mobile number is from a valid partner/agent.
   * Returns 200 if valid, 404 if not found or not eligible.
   * 
   * @param mobile - Mobile number to validate (format: 10 digits, +91, or 0)
   * @returns 200 if valid, 404 if not found
   * @throws 404 Not Found if mobile is not a valid partner
   */
  @Get('referral-validation/:mobile')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Validate referral mobile number',
    description: 'Validates if a mobile number belongs to a valid partner or agent. Returns 200 if valid partner, 404 if invalid.',
  })
  @ApiParam({
    name: 'mobile',
    type: 'string',
    description: 'Mobile number to validate (10 digits, +91, or 0 prefix)',
    example: '9876543210',
  })
  @ApiOkResponse({
    description: 'Mobile number is valid partner/agent',
    schema: {
      type: 'object',
      properties: {
        valid: { type: 'boolean' },
        message: { type: 'string' },
      },
    },
  })
  @ApiUnauthorizedResponse({
    description: 'Unauthorized - Invalid or expired JWT token',
  })
  @ApiNotFoundResponse({
    description: 'Mobile number is not a valid partner/agent',
  })
  async validateReferral(@Param('mobile') mobile: string): Promise<{ valid: boolean; message: string }> {
    const isValid = await this.usersService.validateReferralMobile(mobile);
    if (!isValid) {
      throw new NotFoundException('Mobile number is not a valid partner or agent');
    }
    return {
      valid: true,
      message: 'Mobile number is a valid partner',
    };
  }
}
