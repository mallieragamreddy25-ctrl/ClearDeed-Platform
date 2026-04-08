/**
 * Test Fixtures
 * Reusable mock data and test utilities for Jest tests
 */

import { CreateUserDto } from '../../modules/users/dto/create-user.dto';
import { CreatePropertyDto } from '../../modules/properties/dto/create-property.dto';
import { CreateDealDto } from '../../modules/deals/dto/create-deal.dto';

type MockFn<TArgs extends any[] = any[], TResult = any> = ((
  ...args: TArgs
) => TResult) & {
  calls: TArgs[];
};

const createMockFn = <TArgs extends any[] = any[], TResult = any>(
  returnValue?: TResult,
): MockFn<TArgs, TResult> => {
  const fn = ((...args: TArgs) => {
    fn.calls.push(args);
    return returnValue as TResult;
  }) as MockFn<TArgs, TResult>;

  fn.calls = [];
  return fn;
};

/**
 * Mock user data for testing
 */
export const mockUsers = {
  admin: {
    id: 1,
    mobileNumber: '+919999999999',
    fullName: 'Admin User',
    email: 'admin@cleardeed.com',
    city: 'Mumbai',
    profileType: 'buyer',
    isActive: true,
    isVerified: true,
  },
  buyer: {
    id: 2,
    mobileNumber: '+919000000001',
    fullName: 'Test Buyer',
    email: 'buyer@test.com',
    city: 'Bangalore',
    profileType: 'buyer',
    budgetRange: '50L-1Cr',
    isActive: true,
    isVerified: true,
  },
  seller: {
    id: 3,
    mobileNumber: '+919000000002',
    fullName: 'Test Seller',
    email: 'seller@test.com',
    city: 'Mumbai',
    profileType: 'seller',
    isActive: true,
    isVerified: false,
  },
  investor: {
    id: 4,
    mobileNumber: '+919000000003',
    fullName: 'Test Investor',
    email: 'investor@test.com',
    city: 'Delhi',
    profileType: 'investor',
    netWorthRange: '1Cr+',
    isActive: true,
    isVerified: true,
  },
};

/**
 * Mock referral partner data
 */
export const mockReferralPartners = {
  agent1: {
    id: 1,
    mobileNumber: '+919888888881',
    partnerType: 'agent',
    fullName: 'John Agent',
    email: 'john@agents.com',
    city: 'Mumbai',
    agentLicenseNumber: 'AGENT001',
    agencyName: 'Premier Agents',
    status: 'approved',
    isActive: true,
    commissionEnabled: true,
    totalCommissionEarned: 500000,
  },
  agent2: {
    id: 2,
    mobileNumber: '+919888888882',
    partnerType: 'agent',
    fullName: 'Sarah Agent',
    email: 'sarah@agents.com',
    city: 'Bangalore',
    agentLicenseNumber: 'AGENT002',
    agencyName: 'Elite Realty',
    status: 'approved',
    isActive: true,
    commissionEnabled: true,
    totalCommissionEarned: 750000,
  },
};

/**
 * Mock property data
 */
export const mockProperties = {
  land: {
    id: 1,
    title: 'Premium Land in Bandra',
    description: 'Beautiful 5000 sqft land plot',
    category: 'land',
    location: 'Bandra, Mumbai',
    city: 'Mumbai',
    pincode: '400050',
    price: 50000000,
    area: 5000,
    areaUnit: 'sqft',
    ownershipStatus: 'owned',
    status: 'verified',
    isVerified: true,
    verifiedBadge: true,
  },
  house: {
    id: 2,
    title: '3 BHK House in BTM Layout',
    description: 'Spacious 3 bedroom house with garden',
    category: 'individual_house',
    location: 'BTM Layout, Bangalore',
    city: 'Bangalore',
    pincode: '560068',
    price: 10000000,
    area: 2500,
    areaUnit: 'sqft',
    ownershipStatus: 'owned',
    status: 'verified',
    isVerified: true,
    verifiedBadge: true,
  },
  commercial: {
    id: 3,
    title: 'Commercial Space in Delhi',
    description: 'Prime commercial property for business',
    category: 'commercial',
    location: 'Connaught Place, Delhi',
    city: 'Delhi',
    pincode: '110001',
    price: 25000000,
    area: 3000,
    areaUnit: 'sqft',
    ownershipStatus: 'owned',
    status: 'submitted',
    isVerified: false,
    verifiedBadge: false,
  },
};

/**
 * Mock deal data
 */
export const mockDeals = {
  deal1: {
    id: 1,
    buyerUserId: mockUsers.buyer.id,
    sellerUserId: mockUsers.seller.id,
    propertyId: mockProperties.land.id,
    status: 'active',
    transactionValue: 50000000,
    createdAt: new Date('2024-01-15'),
  },
  deal2: {
    id: 2,
    buyerUserId: mockUsers.investor.id,
    sellerUserId: mockUsers.seller.id,
    propertyId: mockProperties.house.id,
    status: 'closed',
    transactionValue: 10000000,
    dealClosedAt: new Date('2024-01-20'),
  },
};

/**
 * Mock commission data
 */
export const mockCommissions = {
  commission1: {
    id: 1,
    dealId: mockDeals.deal1.id,
    referralPartnerId: mockReferralPartners.agent1.id,
    commissionType: 'referral_fee',
    amount: 500000,
    percentageApplied: 1,
    status: 'pending',
  },
  commission2: {
    id: 2,
    dealId: mockDeals.deal2.id,
    referralPartnerId: mockReferralPartners.agent2.id,
    commissionType: 'referral_fee',
    amount: 100000,
    percentageApplied: 1,
    status: 'paid',
  },
};

/**
 * Mock notification data
 */
export const mockNotifications = {
  otp: {
    id: 1,
    userId: mockUsers.buyer.id,
    notificationType: 'otp_verification',
    title: 'Your OTP Code',
    body: 'Your OTP code is 123456. Valid for 5 minutes.',
    channel: 'sms',
    recipientMobile: mockUsers.buyer.mobileNumber,
    deliveryStatus: 'sent',
  },
  dealCreated: {
    id: 2,
    userId: mockUsers.buyer.id,
    notificationType: 'deal_created',
    title: 'New Deal Created',
    body: 'A new deal has been created for your property interest.',
    channel: 'sms',
    recipientMobile: mockUsers.buyer.mobileNumber,
    deliveryStatus: 'pending',
  },
};

/**
 * Generate Auth DTO for testing
 */
export const createUserDto = (): CreateUserDto => ({
  full_name: 'Test User',
  email: 'test@example.com',
  city: 'Mumbai',
  profile_type: 'buyer',
});

/**
 * Generate Property DTO for testing
 */
export const createPropertyDto = (): CreatePropertyDto => ({
  title: 'Test Property',
  description: 'A test property for unit testing',
  category: 'land',
  location: 'Test Location',
  city: 'Test City',
  price: 1000000,
  area: 1000,
  area_unit: 'sqft',
  ownership_type: 'freehold',
});

/**
 * Generate Deal DTO for testing
 */
export const createDealDto = (): CreateDealDto => ({
  buyer_user_id: mockUsers.buyer.id,
  seller_user_id: mockUsers.seller.id,
  property_id: mockProperties.land.id,
  transaction_value: 50000000,
});

/**
 * JWT Token fixtures
 */
export const jwtTokens = {
  admin: 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwibW9iaWxlTnVtYmVyIjoiKzkxOTk5OTk5OTk5Iiwicm9sZSI6ImFkbWluIn0.signature',
  buyer: 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MiwibW9iaWxlTnVtYmVyIjoiKzkxOTAwMDAwMDAxIiwicm9sZSI6ImJ1eWVyIn0.signature',
  seller: 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MywibW9iaWxlTnVtYmVyIjoiKzkxOTAwMDAwMDAyIiwicm9sZSI6InNlbGxlciJ9.signature',
};

/**
 * Mock API Responses
 */
export const mockApiResponses = {
  success: {
    statusCode: 200,
    message: 'Success',
    data: null,
    timestamp: new Date(),
  },
  created: {
    statusCode: 201,
    message: 'Created',
    data: null,
    timestamp: new Date(),
  },
  badRequest: {
    statusCode: 400,
    message: 'Bad Request',
    errors: [],
    timestamp: new Date(),
  },
  unauthorized: {
    statusCode: 401,
    message: 'Unauthorized',
    timestamp: new Date(),
  },
  forbidden: {
    statusCode: 403,
    message: 'Forbidden',
    timestamp: new Date(),
  },
  notFound: {
    statusCode: 404,
    message: 'Not Found',
    timestamp: new Date(),
  },
};

/**
 * Test utility functions
 */
export class TestFixtures {
  /**
   * Create a mock JWT token
   */
  static createMockJwt(userId: number, role: string = 'user'): string {
    const payload = Buffer.from(JSON.stringify({ userId, role })).toString('base64');
    const header = Buffer.from(JSON.stringify({ alg: 'HS256', typ: 'JWT' })).toString('base64');
    return `${header}.${payload}.signature`;
  }

  /**
   * Create a mock OTP
   */
  static createMockOtp(length: number = 6): string {
    return Array.from({ length }, () => Math.floor(Math.random() * 10)).join('');
  }

  /**
   * Create a mock user response
   */
  static createMockUserResponse(overrides = {}) {
    return {
      ...mockUsers.buyer,
      ...overrides,
    };
  }

  /**
   * Create a mock property response
   */
  static createMockPropertyResponse(overrides = {}) {
    return {
      ...mockProperties.land,
      sellerUserId: mockUsers.seller.id,
      ...overrides,
    };
  }

  /**
   * Create a mock deal response
   */
  static createMockDealResponse(overrides = {}) {
    return {
      ...mockDeals.deal1,
      ...overrides,
    };
  }

  /**
   * Wait for a given number of milliseconds (for async tests)
   */
  static async wait(ms: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  /**
   * Create a mock request object
   */
  static createMockRequest(overrides = {}) {
    return {
      user: mockUsers.buyer,
      headers: {
        authorization: jwtTokens.buyer,
      },
      ...overrides,
    };
  }

  /**
   * Create a mock response object
   */
  static createMockResponse() {
    return {
      status: createMockFn(),
      json: createMockFn(),
      send: createMockFn(),
      setHeader: createMockFn(),
    };
  }
}

/**
 * Database test utilities
 */
export class DatabaseTestFixtures {
  /**
   * Seed database with test data
   */
  static async seedDatabase(dataSource: any): Promise<void> {
    // This would typically insert test data into the database
    // Implementation depends on the ORM being used
  }

  /**
   * Clear database tables
   */
  static async clearDatabase(dataSource: any): Promise<void> {
    // This would typically delete all test data from the database
    // Implementation depends on the ORM being used
  }
}
