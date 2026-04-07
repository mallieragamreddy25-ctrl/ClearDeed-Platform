import {
  Injectable,
  BadRequestException,
  ForbiddenException,
  ConflictException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Property } from '../../database/entities/property.entity';
import { PropertyDocument } from '../../database/entities/property-document.entity';
import { PropertyGallery } from '../../database/entities/property-gallery.entity';
import { PropertyVerification } from '../../database/entities/property-verification.entity';
import { ExpressInterest } from '../../database/entities/express-interest.entity';
import { User } from '../../database/entities/user.entity';
import { CreatePropertyDto } from './dto/create-property.dto';
import { UpdatePropertyDto } from './dto/update-property.dto';
import { UploadPropertyDocumentDto } from './dto/upload-document.dto';
import { UploadPropertyGalleryDto } from './dto/upload-gallery.dto';
import { PropertyFilterDto } from './dto/property-filter.dto';
import { ResourceNotFoundException } from '../../common/exceptions/business.exception';
import {
  IProperty,
  IPropertyDocument,
  IPropertyGallery,
  IExpressInterest,
  IPropertyDetailResponse,
  IPropertyListResponse,
  PropertyStatus,
  DocumentType,
} from './properties.interface';

/**
 * Properties Service - Core Property Management
 * 
 * Handles all property operations:
 * 1. **Seller Operations** (POST, PUT)
 *    - Create new property listings (status: submitted)
 *    - Update property details (only if status is submitted/under_verification)
 *    - Upload verification documents
 *    - Upload gallery images
 *    - View their own properties
 * 
 * 2. **Admin Operations** (Verification Workflow)
 *    - Change status to 'under_verification'
 *    - Verify property (transition to 'verified')
 *    - Reject property with reason
 *    - View all properties for approval
 * 
 * 3. **Buyer Operations** (Discover & Express Interest)
 *    - List verified and live properties
 *    - Filter by category, city, price range
 *    - View detailed property info
 *    - Express interest in property
 * 
 * **Status Lifecycle:**
 * submitted → under_verification → verified → live → sold
 *                                           → rejected
 * 
 * **Business Rules:**
 * - Only sellers (profile_type='seller') can upload properties
 * - Edits only allowed if status is 'submitted' or 'under_verification'
 * - Only admins can verify properties
 * - Buyers see only 'verified' or 'live' properties
 * - Prevent duplicate express interest (unique constraint)
 * - Gallery images ordered by display_order (1, 2, 3, ...)
 */
@Injectable()
export class PropertiesService {
  constructor(
    @InjectRepository(Property)
    private propertiesRepository: Repository<Property>,
    @InjectRepository(PropertyDocument)
    private documentsRepository: Repository<PropertyDocument>,
    @InjectRepository(PropertyGallery)
    private galleryRepository: Repository<PropertyGallery>,
    @InjectRepository(PropertyVerification)
    private verificationRepository: Repository<PropertyVerification>,
    @InjectRepository(ExpressInterest)
    private expressInterestRepository: Repository<ExpressInterest>,
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  /**
   * Create a new property listing
   * 
   * @param userId - Seller user ID
   * @param createPropertyDto - Property details
   * @returns Created property with verification initialized
   */
  async createProperty(userId: number, createPropertyDto: CreatePropertyDto): Promise<Property> {
    const property = this.propertiesRepository.create({
      seller_user_id: userId,
      ...createPropertyDto,
      status: 'submitted',
      is_verified: false,
      area_unit: createPropertyDto.area_unit || 'sqft',
    });

    const savedProperty = await this.propertiesRepository.save(property);

    // Create verification record
    await this.verificationRepository.create({
      property_id: savedProperty.id,
      verification_status: 'pending',
    });

    return savedProperty;
  }

  /**
   * Get property by ID
   * 
   * @param propertyId - Property ID
   * @returns Property with verification details
   */
  async getPropertyById(propertyId: number): Promise<{
    property: Property;
    verification: PropertyVerification | null;
    documents: PropertyDocument[];
    gallery: PropertyGallery[];
  }> {
    const property = await this.propertiesRepository.findOne({
      where: { id: propertyId },
      relations: ['seller_user'],
    });

    if (!property) {
      throw new ResourceNotFoundException('Property', propertyId);
    }

    const verification = await this.verificationRepository.findOne({
      where: { property_id: propertyId },
    });

    const documents = await this.documentsRepository.find({
      where: { property_id: propertyId },
    });

    const gallery = await this.galleryRepository.find({
      where: { property_id: propertyId },
      order: { display_order: 'ASC' },
    });

    return { property, verification, documents, gallery };
  }

  /**
   * Update property details
   * Only seller who created it can update
   * Cannot update if verification has started
   * 
   * @param propertyId - Property ID
   * @param userId - Current user ID (seller)
   * @param updatePropertyDto - Updated details
   * @returns Updated property
   */
  async updateProperty(
    propertyId: number,
    userId: number,
    updatePropertyDto: UpdatePropertyDto,
  ): Promise<Property> {
    const property = await this.propertiesRepository.findOne({
      where: { id: propertyId },
    });

    if (!property) {
      throw new ResourceNotFoundException('Property', propertyId);
    }

    // Only seller can update
    if (property.seller_user_id !== userId) {
      throw new ForbiddenException('You can only update your own properties');
    }

    // Cannot update if verification has started
    if (property.status !== 'submitted') {
      throw new BadRequestException(
        'Cannot update property. Verification already in progress or property is live.',
      );
    }

    // Update allowed fields
    Object.assign(property, updatePropertyDto);
    return await this.propertiesRepository.save(property);
  }

  /**
   * List verified properties (for buyers)
   * Filters and pagination
   * 
   * @param filters - Filter criteria
   * @returns Paginated list of verified properties
   */
  async listVerifiedProperties(filters: {
    category?: string;
    city?: string;
    min_price?: number;
    max_price?: number;
    page?: number;
    limit?: number;
  }): Promise<{
    data: Property[];
    total: number;
    page: number;
    limit: number;
  }> {
    let query = this.propertiesRepository
      .createQueryBuilder('property')
      .where('property.status = :status', { status: 'verified' })
      .orWhere('property.status = :liveStatus', { liveStatus: 'live' });

    if (filters.category) {
      query = query.andWhere('property.category = :category', { category: filters.category });
    }

    if (filters.city) {
      query = query.andWhere('property.city = :city', { city: filters.city });
    }

    if (filters.min_price) {
      query = query.andWhere('property.price >= :min_price', { min_price: filters.min_price });
    }

    if (filters.max_price) {
      query = query.andWhere('property.price <= :max_price', { max_price: filters.max_price });
    }

    const page = filters.page || 1;
    const limit = filters.limit || 20;
    const skip = (page - 1) * limit;

    query = query.orderBy('property.created_at', 'DESC').skip(skip).take(limit);

    const [data, total] = await query.getManyAndCount();

    return { data, total, page, limit };
  }

  /**
   * Get seller's properties
   * 
   * @param userId - Seller user ID
   * @returns List of seller's properties
   */
  async getSellerProperties(userId: number, limit: number = 20, offset: number = 0): Promise<{
    data: Property[];
    total: number;
    limit: number;
    offset: number;
  }> {
    const [data, total] = await this.propertiesRepository.findAndCount({
      where: { seller_user_id: userId },
      order: { created_at: 'DESC' },
      take: limit,
      skip: offset,
    });

    return { data, total, limit, offset };
  }

  /**
   * Verify property (admin only)
   * 
   * @param propertyId - Property ID
   * @param adminId - Admin user ID
   * @param verificationNotes - Notes from admin
   * @returns Updated property
   */
  async verifyProperty(
    propertyId: number,
    adminId: number,
    verificationNotes: string,
  ): Promise<Property> {
    const property = await this.propertiesRepository.findOne({
      where: { id: propertyId },
    });

    if (!property) {
      throw new ResourceNotFoundException('Property', propertyId);
    }

    // Update property status
    property.status = 'verified';
    property.is_verified = true;
    property.verified_badge = true;
    property.verified_at = new Date();

    const updatedProperty = await this.propertiesRepository.save(property);

    // Update verification record
    await this.verificationRepository.update(
      { property_id: propertyId },
      {
        verification_status: 'approved',
        verified_by_admin_id: adminId,
        verification_notes: verificationNotes,
        verified_at: new Date(),
      },
    );

    return updatedProperty;
  }

  /**
   * Reject property verification (admin only)
   * 
   * @param propertyId - Property ID
   * @param rejectionReason - Reason for rejection
   * @returns Updated property
   */
  async rejectProperty(propertyId: number, rejectionReason: string): Promise<Property> {
    const property = await this.propertiesRepository.findOne({
      where: { id: propertyId },
    });

    if (!property) {
      throw new ResourceNotFoundException('Property', propertyId);
    }

    property.status = 'rejected';
    property.is_verified = false;

    const updatedProperty = await this.propertiesRepository.save(property);

    // Update verification record
    await this.verificationRepository.update(
      { property_id: propertyId },
      {
        verification_status: 'rejected',
        rejection_reason: rejectionReason,
      },
    );

    return updatedProperty;
  }

  /**
   * Add document to property
   * 
   * @param propertyId - Property ID
   * @param document - Document details
   * @returns Created document
   */
  async addDocument(
    propertyId: number,
    document: { document_type: string; document_name: string; document_url: string },
  ): Promise<PropertyDocument> {
    const property = await this.propertiesRepository.findOne({
      where: { id: propertyId },
    });

    if (!property) {
      throw new ResourceNotFoundException('Property', propertyId);
    }

    const newDocument = this.documentsRepository.create({
      property_id: propertyId,
      ...document,
    });

    return await this.documentsRepository.save(newDocument);
  }

  /**
   * Add gallery image to property
   * 
   * @param propertyId - Property ID
   * @param image - Image details
   * @returns Created gallery entry
   */
  async addGalleryImage(
    propertyId: number,
    image: { image_url: string; image_title?: string; display_order?: number },
  ): Promise<PropertyGallery> {
    const property = await this.propertiesRepository.findOne({
      where: { id: propertyId },
    });

    if (!property) {
      throw new ResourceNotFoundException('Property', propertyId);
    }

    const newImage = this.galleryRepository.create({
      property_id: propertyId,
      ...image,
    });

    return await this.galleryRepository.save(newImage);
  }

  /**
   * Delete property (seller only, if not verified)
   * 
   * @param propertyId - Property ID
   * @param userId - Current user ID (seller)
   */
  async deleteProperty(propertyId: number, userId: number): Promise<{ success: boolean; message: string }> {
    const property = await this.propertiesRepository.findOne({
      where: { id: propertyId },
    });

    if (!property) {
      throw new ResourceNotFoundException('Property', propertyId);
    }

    // Only seller can delete
    if (property.seller_user_id !== userId) {
      throw new ForbiddenException('You can only delete your own properties');
    }

    // Cannot delete if verified or live
    if (property.status !== 'submitted') {
      throw new BadRequestException(
        'Cannot delete property. Property is already verified or live.',
      );
    }

    await this.propertiesRepository.delete(propertyId);

    return { success: true, message: 'Property deleted successfully' };
  }

  /**
   * Transition property status
   * Manages the property lifecycle: submitted → under_verification → verified → live → sold
   * 
   * @param propertyId - Property ID
   * @param newStatus - New status to transition to
   * @returns Updated property
   */
  async transitionPropertyStatus(
    propertyId: number,
    newStatus: 'submitted' | 'under_verification' | 'verified' | 'live' | 'sold' | 'rejected',
  ): Promise<Property> {
    const property = await this.propertiesRepository.findOne({
      where: { id: propertyId },
    });

    if (!property) {
      throw new ResourceNotFoundException('Property', propertyId);
    }

    const validTransitions: Record<string, string[]> = {
      submitted: ['under_verification', 'rejected'],
      under_verification: ['verified', 'rejected'],
      verified: ['live', 'rejected'],
      live: ['sold', 'rejected'],
      sold: [],
      rejected: ['submitted'],
    };

    if (!validTransitions[property.status].includes(newStatus)) {
      throw new BadRequestException(
        `Cannot transition from ${property.status} to ${newStatus}`,
      );
    }

    property.status = newStatus;
    if (newStatus === 'live') {
      property.verified_badge = true;
    }

    return await this.propertiesRepository.save(property);
  }

  /**
   * Get property summary statistics
   * 
   * @param userId - Seller user ID
   * @returns Statistics about seller's properties
   */
  async getPropertyStats(userId: number): Promise<{
    total: number;
    submitted: number;
    under_verification: number;
    verified: number;
    live: number;
    sold: number;
    rejected: number;
  }> {
    const properties = await this.propertiesRepository.find({
      where: { seller_user_id: userId },
    });

    return {
      total: properties.length,
      submitted: properties.filter((p) => p.status === 'submitted').length,
      under_verification: properties.filter((p) => p.status === 'under_verification').length,
      verified: properties.filter((p) => p.status === 'verified').length,
      live: properties.filter((p) => p.status === 'live').length,
      sold: properties.filter((p) => p.status === 'sold').length,
      rejected: properties.filter((p) => p.status === 'rejected').length,
    };
  }

  /**
   * Create express interest for a property
   * 
   * @param propertyId - Property ID
   * @param buyerId - Buyer user ID
   * @returns Success message
   */
  async createExpressInterest(propertyId: number, buyerId: number): Promise<{ success: boolean; message: string }> {
    const property = await this.propertiesRepository.findOne({
      where: { id: propertyId },
    });

    if (!property) {
      throw new ResourceNotFoundException('Property', propertyId);
    }

    // Check if interest already exists
    const existingInterest = await this.expressInterestRepository.findOne({
      where: {
        property_id: propertyId,
        user_id: buyerId,
      },
    });

    if (existingInterest) {
      throw new ConflictException('Interest already expressed for this property');
    }

    // Create express interest record
    await this.expressInterestRepository.save({
      property_id: propertyId,
      user_id: buyerId,
    });

    return { 
      success: true, 
      message: 'Interest expressed successfully. Seller will be notified.' 
    };
  }

  /**
   * Delete document
   * 
   * @param documentId - Document ID
   * @returns Success message
   */
  async deleteDocument(documentId: number): Promise<{ success: boolean; message: string }> {
    const result = await this.documentsRepository.delete(documentId);
    if (result.affected === 0) {
      throw new ResourceNotFoundException('Document', documentId);
    }
    return { success: true, message: 'Document deleted successfully' };
  }

  /**
   * Delete gallery image
   * 
   * @param imageId - Image ID
   * @returns Success message
   */
  async deleteGalleryImage(imageId: number): Promise<{ success: boolean; message: string }> {
    const result = await this.galleryRepository.delete(imageId);
    if (result.affected === 0) {
      throw new ResourceNotFoundException('Gallery Image', imageId);
    }
    return { success: true, message: 'Gallery image deleted successfully' };
  }

  /**
   * Update gallery image display order
   * 
   * @param imageId - Image ID
   * @param displayOrder - New display order
   * @returns Updated gallery entry
   */
  async updateGalleryImageOrder(imageId: number, displayOrder: number): Promise<PropertyGallery> {
    const image = await this.galleryRepository.findOne({
      where: { id: imageId },
    });

    if (!image) {
      throw new ResourceNotFoundException('Gallery Image', imageId);
    }

    image.display_order = displayOrder;
    return await this.galleryRepository.save(image);
  }

  /**
   * Get documents by type
   * 
   * @param propertyId - Property ID
   * @param documentType - Type of document
   * @returns List of documents of specified type
   */
  async getDocumentsByType(
    propertyId: number,
    documentType: string,
  ): Promise<PropertyDocument[]> {
    return await this.documentsRepository.find({
      where: { 
        property_id: propertyId, 
        doc_type: documentType as any,
      },
    });
  }

  /**
   * Search properties by keyword
   * Searches in title, description, location, and city
   * 
   * @param keyword - Search keyword
   * @returns List of matching properties
   */
  async searchProperties(keyword: string): Promise<Property[]> {
    return await this.propertiesRepository
      .createQueryBuilder('property')
      .where('property.title ILIKE :keyword', { keyword: `%${keyword}%` })
      .orWhere('property.description ILIKE :keyword', { keyword: `%${keyword}%` })
      .orWhere('property.location ILIKE :keyword', { keyword: `%${keyword}%` })
      .orWhere('property.city ILIKE :keyword', { keyword: `%${keyword}%` })
      .andWhere('(property.status = :status1 OR property.status = :status2)', {
        status1: 'verified',
        status2: 'live',
      })
      .orderBy('property.created_at', 'DESC')
      .limit(50)
      .getMany();
  }
}
