import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
  HttpCode,
  HttpStatus,
  ParseIntPipe,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiParam,
  ApiQuery,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { PropertiesService } from './properties.service';
import { CreatePropertyDto } from './dto/create-property.dto';
import { UpdatePropertyDto } from './dto/update-property.dto';
import { PropertyFilterDto } from './dto/property-filter.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { AdminGuard } from '../../common/guards/admin.guard';

/**
 * Properties Controller
 * 
 * Endpoints:
 * - GET /properties: List verified properties (buyers)
 * - POST /properties: Create new property (sellers)
 * - GET /properties/:id: Get property details
 * - PUT /properties/:id: Update property (seller only)
 * - DELETE /properties/:id: Delete property (seller only)
 * - GET /properties/seller/my-properties: Get seller's properties
 * - POST /properties/:id/documents: Add documents
 * - POST /properties/:id/gallery: Add gallery images
 * - POST /properties/:id/verify: Verify property (admin only)
 * - POST /properties/:id/reject: Reject property (admin only)
 */
@ApiTags('Properties')
@ApiBearerAuth()
@Controller('properties')
@UseGuards(JwtAuthGuard)
export class PropertiesController {
  constructor(private readonly propertiesService: PropertiesService) {}

  /**
   * List verified properties (buyer view)
   * Supports filtering by category, city, price range, and pagination
   * 
   * @param category - Property category filter
   * @param city - City filter
   * @param min_price - Minimum price filter
   * @param max_price - Maximum price filter
   * @param page - Page number (default: 1)
   * @param limit - Records per page (default: 20, max: 100)
   * @returns Paginated list of verified properties
   */
  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'List verified properties',
    description: 'Get a list of verified and live properties with optional filters for buyers',
  })
  @ApiQuery({ name: 'category', required: false, description: 'Filter by property category' })
  @ApiQuery({ name: 'city', required: false, description: 'Filter by city' })
  @ApiQuery({ name: 'min_price', required: false, description: 'Minimum price filter' })
  @ApiQuery({ name: 'max_price', required: false, description: 'Maximum price filter' })
  @ApiQuery({ name: 'page', required: false, description: 'Page number (default: 1)' })
  @ApiQuery({ name: 'limit', required: false, description: 'Records per page (default: 20)' })
  @ApiResponse({
    status: 200,
    description: 'Successfully retrieved verified properties list',
    schema: {
      example: {
        data: [],
        total: 0,
        page: 1,
        limit: 20,
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - JWT token invalid or missing' })
  async listProperties(
    @Request() req: any,
    @Query('category') category?: string,
    @Query('city') city?: string,
    @Query('min_price') min_price?: string,
    @Query('max_price') max_price?: string,
    @Query('status') status?: string,
    @Query('search') search?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return await this.propertiesService.listVerifiedProperties({
      category,
      city,
      min_price: min_price ? parseFloat(min_price) : undefined,
      max_price: max_price ? parseFloat(max_price) : undefined,
      status,
      search,
      page: page ? parseInt(page) : 1,
      limit: limit ? parseInt(limit) : 20,
      isAdmin: !!req.user?.isAdmin,
    });
  }

  /**
   * Create new property
   * Only sellers can create properties
   * Property starts in 'submitted' status and goes through verification
   * 
   * @param req - Express request with authenticated user
   * @param createPropertyDto - Property details
   * @returns Created property with initial verification record
   */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create a new property listing',
    description:
      'Create a new property submission for verification. Only authenticated sellers can create properties.',
  })
  @ApiResponse({
    status: 201,
    description: 'Property created successfully and sent for verification',
    schema: {
      example: {
        id: 1,
        title: 'Beautiful 2BHK House',
        category: 'individual_house',
        location: 'Bangalore, Karnataka',
        city: 'Bangalore',
        price: 5000000,
        area: 1500,
        status: 'submitted',
        is_verified: false,
        created_at: '2024-01-15T10:30:00Z',
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Invalid property data provided' })
  @ApiResponse({ status: 401, description: 'Unauthorized - JWT token invalid or missing' })
  async createProperty(@Request() req: any, @Body() createPropertyDto: CreatePropertyDto) {
    const userId = req.user.userId;
    return await this.propertiesService.createProperty(userId, createPropertyDto);
  }

  /**
   * Get property details with verification, documents, and gallery
   * Returns complete property information including related data
   * 
   * @param id - Property ID
   * @returns Property with verification details, documents, and gallery images
   */
  @Get(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get property details',
    description: 'Retrieve complete property information including verification status, documents, and gallery',
  })
  @ApiParam({ name: 'id', description: 'Property ID', type: 'number' })
  @ApiResponse({
    status: 200,
    description: 'Property details retrieved successfully',
    schema: {
      example: {
        property: {
          id: 1,
          title: 'Beautiful House',
          category: 'individual_house',
          price: 5000000,
          status: 'verified',
        },
        verification: {
          id: 1,
          property_id: 1,
          verification_status: 'approved',
          verified_by_admin_id: 5,
          verified_at: '2024-01-20T14:30:00Z',
        },
        documents: [],
        gallery: [],
      },
    },
  })
  @ApiResponse({ status: 404, description: 'Property not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getProperty(@Param('id', ParseIntPipe) id: number) {
    return await this.propertiesService.getPropertyById(id);
  }

  /**
   * Update property details
   * Only seller who created property can update
   * Cannot update if verification has already started
   * Status must be 'submitted' or 'under_verification' to allow updates
   * 
   * @param req - Express request with authenticated user
   * @param id - Property ID
   * @param updatePropertyDto - Updated property details
   * @returns Updated property
   */
  @Put(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Update property details',
    description:
      'Update property information. Only property creator (seller) can update. Property must be in submitted status.',
  })
  @ApiParam({ name: 'id', description: 'Property ID', type: 'number' })
  @ApiResponse({
    status: 200,
    description: 'Property updated successfully',
  })
  @ApiResponse({ status: 400, description: 'Cannot update property in current status' })
  @ApiResponse({ status: 403, description: 'Forbidden - You can only update your own properties' })
  @ApiResponse({ status: 404, description: 'Property not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async updateProperty(
    @Request() req: any,
    @Param('id', ParseIntPipe) id: number,
    @Body() updatePropertyDto: UpdatePropertyDto,
  ) {
    const userId = req.user.userId;
    return await this.propertiesService.updateProperty(id, userId, updatePropertyDto);
  }

  /**
   * Delete property
   * Only seller can delete, and only if property status is 'submitted'
   * Cannot delete verified, live, or sold properties
   * 
   * @param req - Express request with authenticated user
   * @param id - Property ID
   * @returns Success response
   */
  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Delete property',
    description:
      'Delete a property listing. Only property creator can delete. Property must be in submitted status.',
  })
  @ApiParam({ name: 'id', description: 'Property ID', type: 'number' })
  @ApiResponse({
    status: 200,
    description: 'Property deleted successfully',
    schema: {
      example: {
        success: true,
        message: 'Property deleted successfully',
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Cannot delete property in current status' })
  @ApiResponse({ status: 403, description: 'Forbidden - You can only delete your own properties' })
  @ApiResponse({ status: 404, description: 'Property not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async deleteProperty(@Request() req: any, @Param('id', ParseIntPipe) id: number) {
    const userId = req.user.userId;
    return await this.propertiesService.deleteProperty(id, userId);
  }

  /**
   * Get seller's properties
   * Returns all properties created by the authenticated seller
   * Includes properties in all statuses (submitted, under verification, verified, live, sold, rejected)
   * 
   * @param req - Express request with authenticated user
   * @param limit - Records per page (default: 20)
   * @param offset - Page offset (default: 0)
   * @returns List of seller's properties with pagination
   */
  @Get('seller/my-properties')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get seller\'s properties',
    description: 'Retrieve all properties created by the authenticated seller with pagination',
  })
  @ApiQuery({ name: 'limit', required: false, description: 'Records per page (default: 20)' })
  @ApiQuery({ name: 'offset', required: false, description: 'Page offset (default: 0)' })
  @ApiResponse({
    status: 200,
    description: 'Seller properties retrieved successfully',
    schema: {
      example: {
        data: [],
        total: 0,
        limit: 20,
        offset: 0,
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getSellerProperties(
    @Request() req: any,
    @Query('limit') limit?: string,
    @Query('offset') offset?: string,
  ) {
    const userId = req.user.userId;
    return await this.propertiesService.getSellerProperties(
      userId,
      limit ? parseInt(limit) : 20,
      offset ? parseInt(offset) : 0,
    );
  }

  /**
   * Add document to property
   * Documents support: title_deed, survey, tax_proof, approval_letter
   * Documents are used for verification process
   * 
   * @param id - Property ID
   * @param body - Document details (type, name, URL)
   * @returns Created document record
   */
  @Post(':id/documents')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Add document to property',
    description:
      'Upload property verification documents such as title deeds, surveys, tax proofs, etc.',
  })
  @ApiParam({ name: 'id', description: 'Property ID', type: 'number' })
  @ApiResponse({
    status: 201,
    description: 'Document added successfully',
    schema: {
      example: {
        id: 1,
        property_id: 1,
        document_type: 'title_deed',
        document_name: 'Title Deed 2024',
        document_url: 'https://example.com/documents/title-deed.pdf',
        uploaded_at: '2024-01-15T10:30:00Z',
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Invalid document data' })
  @ApiResponse({ status: 404, description: 'Property not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async addDocument(
    @Param('id', ParseIntPipe) id: number,
    @Body() body: { document_type: string; document_name: string; document_url: string },
  ) {
    return await this.propertiesService.addDocument(id, body);
  }

  /**
   * Add gallery image to property
   * Supports multiple images with custom display ordering
   * Images are displayed in order of display_order field
   * 
   * @param id - Property ID
   * @param body - Image details (URL, title, display order)
   * @returns Created gallery entry
   */
  @Post(':id/gallery')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Add gallery image to property',
    description:
      'Upload gallery images for property display. Supports multiple images with custom ordering.',
  })
  @ApiParam({ name: 'id', description: 'Property ID', type: 'number' })
  @ApiResponse({
    status: 201,
    description: 'Gallery image added successfully',
    schema: {
      example: {
        id: 1,
        property_id: 1,
        image_url: 'https://example.com/images/property-1.jpg',
        image_title: 'Front View',
        display_order: 1,
        uploaded_at: '2024-01-15T10:30:00Z',
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Invalid image data' })
  @ApiResponse({ status: 404, description: 'Property not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async addGalleryImage(
    @Param('id', ParseIntPipe) id: number,
    @Body() body: { image_url: string; image_title?: string; display_order?: number },
  ) {
    return await this.propertiesService.addGalleryImage(id, body);
  }

  /**
   * Verify property (admin only)
   * Updates property status from 'under_verification' to 'verified'
   * Creates verified badge and marks property ready for listing
   * 
   * @param id - Property ID
   * @param body - Verification details (admin notes)
   * @returns Updated property with verified status
   */
  @Post(':id/verify')
  @UseGuards(AdminGuard)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Verify property (Admin)',
    description:
      'Admin endpoint to approve property verification. Updates property status to verified and enables listing.',
  })
  @ApiParam({ name: 'id', description: 'Property ID', type: 'number' })
  @ApiResponse({
    status: 200,
    description: 'Property verified successfully',
    schema: {
      example: {
        id: 1,
        status: 'verified',
        is_verified: true,
        verified_badge: true,
        verified_at: '2024-01-20T14:30:00Z',
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Invalid verification data' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin only' })
  @ApiResponse({ status: 404, description: 'Property not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async verifyProperty(
    @Request() req: any,
    @Param('id', ParseIntPipe) id: number,
    @Body() body: { verification_notes: string },
  ) {
    const adminId = req.user.userId;
    return await this.propertiesService.verifyProperty(id, adminId, body.verification_notes);
  }

  /**
   * Reject property verification (admin only)
   * Updates property status to 'rejected'
   * Property can be resubmitted after addressing rejection reason
   * 
   * @param id - Property ID
   * @param body - Rejection details (reason)
   * @returns Updated property with rejected status
   */
  @Post(':id/reject')
  @UseGuards(AdminGuard)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Reject property verification (Admin)',
    description:
      'Admin endpoint to reject property verification. Seller can resubmit after addressing the rejection reason.',
  })
  @ApiParam({ name: 'id', description: 'Property ID', type: 'number' })
  @ApiResponse({
    status: 200,
    description: 'Property rejected successfully',
    schema: {
      example: {
        id: 1,
        status: 'rejected',
        is_verified: false,
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Invalid rejection data' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin only' })
  @ApiResponse({ status: 404, description: 'Property not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async rejectProperty(
    @Param('id', ParseIntPipe) id: number,
    @Body() body: { rejection_reason: string },
  ) {
    return await this.propertiesService.rejectProperty(id, body.rejection_reason);
  }
}
