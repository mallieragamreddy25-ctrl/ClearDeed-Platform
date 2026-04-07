/**
 * Properties Module Interfaces
 * 
 * Type-safe interfaces for property management
 */

/**
 * Property Status Enum
 * 
 * Workflow:
 * - submitted: Initial seller submission
 * - under_verification: Admin review in progress
 * - verified: Admin approval completed
 * - live: Available for buyer discovery
 * - sold: Transaction completed
 * - rejected: Failed verification
 */
export enum PropertyStatus {
  SUBMITTED = 'submitted',
  UNDER_VERIFICATION = 'under_verification',
  VERIFIED = 'verified',
  LIVE = 'live',
  SOLD = 'sold',
  REJECTED = 'rejected',
}

/**
 * Property Category Enum
 */
export enum PropertyCategory {
  LAND = 'land',
  HOUSE = 'individual_house',
  COMMERCIAL = 'commercial',
  AGRICULTURE = 'agriculture',
}

/**
 * Ownership Type Enum
 */
export enum OwnershipType {
  FREEHOLD = 'freehold',
  LEASEHOLD = 'leasehold',
}

/**
 * Document Type Enum
 * 
 * Required documents for property verification:
 * - title_deed: Proof of ownership
 * - survey: Property survey and measurement
 * - tax_proof: Property tax receipts
 * - approval_letter: Municipal/government approval
 */
export enum DocumentType {
  TITLE_DEED = 'title_deed',
  SURVEY = 'survey',
  TAX_PROOF = 'tax_proof',
  APPROVAL_LETTER = 'approval_letter',
}

/**
 * Property Interface
 * Represents a real estate listing
 */
export interface IProperty {
  id: number;
  seller_user_id: number;
  category: PropertyCategory | string;
  title: string;
  description?: string;
  location: string;
  city?: string;
  pincode?: string;
  price: number;
  area: number;
  area_unit: string;
  ownership_status?: string;
  status: PropertyStatus | string;
  is_verified: boolean;
  verified_badge: boolean;
  primary_image_url?: string;
  created_at: Date;
  updated_at: Date;
  verified_at?: Date;
}

/**
 * Property Document Interface
 * Stores property verification documents
 */
export interface IPropertyDocument {
  id: number;
  property_id: number;
  doc_type: DocumentType | string;
  file_url: string;
  created_at: Date;
}

/**
 * Property Gallery Interface
 * Stores property images with display order
 */
export interface IPropertyGallery {
  id: number;
  property_id: number;
  image_url: string;
  display_order: number;
  created_at: Date;
}

/**
 * Express Interest Interface
 * Tracks buyer interest in properties
 */
export interface IExpressInterest {
  id: number;
  property_id: number;
  user_id: number;
  interested_at: Date;
}

/**
 * Property Verification Interface
 * Tracks verification status and details
 */
export interface IPropertyVerification {
  id: number;
  property_id: number;
  verification_status: 'pending' | 'approved' | 'rejected';
  verification_notes?: string;
  verified_by_admin_id?: number;
  verified_at?: Date;
}

/**
 * Property Filter Response
 */
export interface IPropertyListResponse {
  data: IProperty[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

/**
 * Property Detail Response
 */
export interface IPropertyDetailResponse {
  property: IProperty;
  documents: IPropertyDocument[];
  gallery: IPropertyGallery[];
  expressInterestCount: number;
  userHasExpressedInterest: boolean;
}

/**
 * Create Property Request
 */
export interface ICreatePropertyRequest {
  category: PropertyCategory | string;
  title: string;
  description?: string;
  location: string;
  city?: string;
  pincode?: string;
  price: number;
  area: number;
  area_unit?: string;
  ownership_status?: string;
  primary_image_url?: string;
}

/**
 * Update Property Request
 * Only allowed before verification starts
 */
export interface IUpdatePropertyRequest {
  title?: string;
  description?: string;
  location?: string;
  city?: string;
  pincode?: string;
  price?: number;
  area?: number;
  primary_image_url?: string;
}

/**
 * Upload Document Request
 */
export interface IUploadDocumentRequest {
  doc_type: DocumentType | string;
  file_url: string;
}

/**
 * Upload Gallery Request
 */
export interface IUploadGalleryRequest {
  image_url: string;
  display_order: number;
}

/**
 * Paginated Response Metadata
 */
export interface IPaginationMeta {
  total: number;
  page: number;
  limit: number;
  totalPages: number;
  hasNextPage: boolean;
  hasPreviousPage: boolean;
}

/**
 * Property Filter Options
 */
export interface IPropertyFilterOptions {
  category?: string;
  city?: string;
  min_price?: number;
  max_price?: number;
  status?: string;
  search?: string;
  page?: number;
  limit?: number;
}
