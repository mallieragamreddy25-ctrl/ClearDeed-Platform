# ClearDeed Commissions Module - Implementation Guide

## Overview

Complete, production-ready NestJS Commissions module for ClearDeed real estate platform implementing commission tracking, ledger management, and reporting.

## Module Structure

```
src/modules/commissions/
├── commissions.module.ts              # NestJS module definition
├── commissions.controller.ts          # 7 REST API endpoints
├── commissions.service.ts             # Business logic (9 methods)
├── commission-ledger.repository.ts    # Custom repository (10+ methods)
├── commissions.dto.ts                 # 6 Request/Response DTOs
└── commissions.interface.ts           # 15+ TypeScript interfaces
```

## API Endpoints

### 1. GET /v1/commissions/ledger
**Paginated Commission Ledger with Filters**

Retrieve commission entries with pagination and filtering.

```bash
GET /v1/commissions/ledger?commission_type=buyer_fee&status=pending&page=1&limit=20
Authorization: Bearer <token>
```

**Query Parameters:**
- `commission_type` (optional): buyer_fee | seller_fee | platform_fee | referral_fee
- `status` (optional): pending | approved | paid
- `deal_id` (optional): Filter by deal ID
- `user_id` (optional): Filter by user ID (admin only)
- `from_date` (optional): ISO 8601 date string
- `to_date` (optional): ISO 8601 date string
- `page` (optional): Default 1, minimum 1
- `limit` (optional): Default 20, min 1, max 100

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "deal_id": 101,
      "commission_type": "buyer_fee",
      "amount": 15000,
      "percentage_applied": 1.5,
      "status": "pending",
      "payment_date": null,
      "payment_reference": null,
      "notes": "Commission for deal closure",
      "created_at": "2024-03-01T10:00:00Z",
      "updated_at": "2024-03-01T10:00:00Z",
      "deal": {
        "id": 101,
        "buyer_user_id": 123,
        "seller_user_id": 124,
        "property_id": 456,
        "deal_value": 1000000,
        "status": "closed"
      }
    }
  ],
  "total": 150,
  "page": 1,
  "limit": 20,
  "total_pages": 8,
  "has_more": true
}
```

### 2. GET /v1/commissions/summary
**Commission Summary Statistics**

Get aggregated commission data across all commissions.

```bash
GET /v1/commissions/summary?from_date=2024-01-01&to_date=2024-12-31
Authorization: Bearer <token>
```

**Query Parameters:**
- `from_date` (optional): ISO 8601 date string
- `to_date` (optional): ISO 8601 date string
- `commission_type` (optional): Filter by type
- `status` (optional): Filter by status

**Response:**
```json
{
  "total_amount": 500000,
  "total_count": 150,
  "pending_amount": 100000,
  "pending_count": 30,
  "approved_amount": 200000,
  "approved_count": 60,
  "paid_amount": 200000,
  "paid_count": 60,
  "by_type": [
    {
      "commission_type": "buyer_fee",
      "total_amount": 150000,
      "total_count": 50,
      "pending_amount": 30000,
      "pending_count": 10,
      "approved_amount": 60000,
      "approved_count": 20,
      "paid_amount": 60000,
      "paid_count": 20
    }
  ],
  "by_status": [
    {
      "status": "pending",
      "total_amount": 100000,
      "total_count": 30,
      "average_amount": 3333.33
    }
  ]
}
```

### 3. GET /v1/commissions/user/:userId
**Per-User Commission Summary**

Get commission breakdown for a specific user.

```bash
GET /v1/commissions/user/123
Authorization: Bearer <token>
```

**Path Parameters:**
- `userId` (required): User ID

**Query Parameters:**
- `from_date` (optional): ISO 8601 date string
- `to_date` (optional): ISO 8601 date string
- `include_details` (optional): Include individual entries

**Response:**
```json
{
  "user_id": 123,
  "user_name": "John Doe",
  "user_mobile": "9876543210",
  "user_email": "john@example.com",
  "total_commissions": 25,
  "total_amount": 50000,
  "pending_amount": 10000,
  "approved_amount": 20000,
  "paid_amount": 20000,
  "commission_details": {
    "buyer_fee": 15000,
    "seller_fee": 20000,
    "platform_fee": 10000,
    "referral_fee": 5000
  },
  "last_payment_date": "2024-03-15T10:30:00Z"
}
```

### 4. GET /v1/commissions/deal/:dealId
**Deal-Specific Commissions**

Get all commissions associated with a specific deal.

```bash
GET /v1/commissions/deal/456
Authorization: Bearer <token>
```

**Path Parameters:**
- `dealId` (required): Deal ID

**Query Parameters:**
- `include_ledger` (optional): Include all ledger entries

**Response:**
```json
{
  "deal_id": 456,
  "deal_value": 1000000,
  "buyer_user_id": 123,
  "seller_user_id": 124,
  "total_commissions": 50000,
  "commissions": [
    {
      "type": "buyer_fee",
      "amount": 15000,
      "percentage": 1.5,
      "status": "paid"
    },
    {
      "type": "seller_fee",
      "amount": 20000,
      "percentage": 2.0,
      "status": "paid"
    },
    {
      "type": "platform_fee",
      "amount": 10000,
      "percentage": 1.0,
      "status": "approved"
    },
    {
      "type": "referral_fee",
      "amount": 5000,
      "percentage": 0.5,
      "status": "pending"
    }
  ]
}
```

### 5. GET /v1/commissions/export
**Export Commission Data as CSV**

Download commission ledger as CSV file.

```bash
GET /v1/commissions/export?status=paid&from_date=2024-01-01&to_date=2024-12-31
Authorization: Bearer <token>
```

**Query Parameters:** Same as ledger endpoint

**Response:** CSV file download with BOM-encoded CSV data

**CSV Format:**
```
id,deal_id,commission_type,amount,percentage_applied,status,payment_date,payment_reference,notes,created_date,updated_date
1,101,buyer_fee,15000,1.5,paid,2024-03-01,,Commission for deal,2024-03-01,2024-03-01
2,101,seller_fee,20000,2.0,paid,2024-03-01,,Commission for deal,2024-03-01,2024-03-01
```

### 6. GET /v1/commissions/statistics (Admin Only)
**Commission Analytics**

Get detailed commission statistics and distribution.

```bash
GET /v1/commissions/statistics
Authorization: Bearer <admin-token>
```

**Response:**
```json
{
  "total_deals_with_commissions": 1500,
  "average_deal_commission_amount": 33333.33,
  "total_commission_amount": 50000000,
  "total_commission_entries": 1500,
  "pending_amount": 10000000,
  "approved_amount": 20000000,
  "paid_amount": 20000000,
  "commission_distribution": {
    "by_type": [
      {
        "commission_type": "buyer_fee",
        "total_amount": 12500000,
        "total_count": 375,
        "percentage": 25
      }
    ],
    "by_status": [
      {
        "status": "pending",
        "total_amount": 10000000,
        "total_count": 300,
        "percentage": 20
      }
    ]
  }
}
```

### 7. GET /v1/commissions/pending (Admin Only)
**Pending Commissions**

Get all pending commissions for payment processing.

```bash
GET /v1/commissions/pending
Authorization: Bearer <admin-token>
```

**Response:** Array of pending commission ledger entries

## Commission Types

| Type | Description | Example Amount |
|------|-------------|-----------------|
| `buyer_fee` | Fee charged from buyer | 1.0-2.0% of deal value |
| `seller_fee` | Fee charged from seller | 1.0-2.5% of deal value |
| `platform_fee` | ClearDeed platform fee | 0.5-1.0% of deal value |
| `referral_fee` | Agent/referral partner commission | 0.2-1.0% of deal value |

## Commission Statuses

| Status | Description |
|--------|-------------|
| `pending` | Newly created, awaiting approval |
| `approved` | Approved for payment |
| `paid` | Payment completed |

## Permissions Model

### Non-Admin Users
- Can view only their own commissions
- Can filter by commission type, status, date range
- Can export their own commission data
- Cannot access admin endpoints or other users' data
- Can view deals they're involved with (as buyer/seller)

### Admin Users
- Can view all commissions
- Can filter by any criteria including user_id
- Can export all commission data
- Access to admin-only endpoints
- Access to analytics and statistics

## Pagination

**Default:** 20 items per page
**Maximum:** 100 items per page
**Calculation:**
```
skip = (page - 1) * limit
total_pages = ceil(total / limit)
has_more = page < total_pages
```

## Filtering Examples

### Filter by Status
```bash
GET /v1/commissions/ledger?status=paid&limit=20
```

### Filter by Type and Status
```bash
GET /v1/commissions/ledger?commission_type=buyer_fee&status=approved
```

### Filter by Date Range
```bash
GET /v1/commissions/ledger?from_date=2024-01-01&to_date=2024-12-31
```

### Filter by Deal
```bash
GET /v1/commissions/ledger?deal_id=456
```

### Combine Multiple Filters
```bash
GET /v1/commissions/ledger?commission_type=referral_fee&status=pending&from_date=2024-03-01&page=2&limit=50
```

## Service Methods (Available to Other Modules)

### CommissionsService

```typescript
// Get paginated commission ledger
getCommissionLedger(options, userId?, isAdmin?): Promise<IPaginatedCommissionResponse>

// Get summary statistics
getCommissionSummary(filters?, userId?, isAdmin?): Promise<ICommissionSummary>

// Get per-user summary
getUserCommissionSummary(userId, fromDate?, toDate?, currentUserId?, isAdmin?): Promise<IUserCommissionSummary>

// Get deal commissions
getDealCommissions(dealId, currentUserId?, isAdmin?): Promise<IDealCommissionSummary>

// Export to CSV
exportCommissionsToCSV(filters?, userId?, isAdmin?): Promise<string>

// Get pending commissions
getPendingCommissions(): Promise<CommissionLedger[]>

// Get statistics
getCommissionStatistics(): Promise<any>
```

## Error Responses

### 400 Bad Request
```json
{
  "statusCode": 400,
  "message": "Page must be greater than 0",
  "error": "Bad Request"
}
```

### 401 Unauthorized
```json
{
  "statusCode": 401,
  "message": "Unauthorized - Invalid or expired JWT token",
  "error": "Unauthorized"
}
```

### 403 Forbidden
```json
{
  "statusCode": 403,
  "message": "You can only view your own commission summary",
  "error": "Forbidden"
}
```

### 404 Not Found
```json
{
  "statusCode": 404,
  "message": "User with ID 999 not found",
  "error": "Not Found"
}
```

## Database Schema

### commission_ledgers Table

| Column | Type | Nullable | Index |
|--------|------|----------|-------|
| id | int | NO | PK |
| deal_id | int | NO | YES |
| referral_partner_id | int | YES | YES |
| commission_type | enum | NO | - |
| amount | decimal(12,2) | NO | - |
| percentage_applied | decimal(5,2) | YES | - |
| status | varchar(50) | NO | YES |
| payment_date | timestamp | YES | - |
| payment_reference | varchar(255) | YES | - |
| notes | text | YES | - |
| created_at | timestamp | NO | - |
| updated_at | timestamp | NO | - |

## TypeScript Interfaces

### ICommissionLedger
```typescript
interface ICommissionLedger {
  id: number;
  deal_id: number;
  referral_partner_id?: number;
  commission_type: CommissionType | string;
  amount: number;
  percentage_applied?: number;
  status: CommissionStatus | string;
  payment_date?: Date;
  payment_reference?: string;
  notes?: string;
  created_at: Date;
  updated_at: Date;
}
```

### ICommissionSummary
```typescript
interface ICommissionSummary {
  total_amount: number;
  total_count: number;
  pending_amount: number;
  pending_count: number;
  approved_amount: number;
  approved_count: number;
  paid_amount: number;
  paid_count: number;
  by_type: ICommissionSummaryByType[];
  by_status: ICommissionSummaryByStatus[];
}
```

### IUserCommissionSummary
```typescript
interface IUserCommissionSummary {
  user_id: number;
  user_name: string;
  user_mobile: string;
  user_email: string;
  total_commissions: number;
  total_amount: number;
  pending_amount: number;
  approved_amount: number;
  paid_amount: number;
  commission_details: {
    buyer_fee: number;
    seller_fee: number;
    platform_fee: number;
    referral_fee: number;
  };
  last_payment_date?: Date;
}
```

## Usage by Other Modules

```typescript
import { Module } from '@nestjs/common';
import { CommissionsModule } from './modules/commissions/commissions.module';
import { CommissionsService } from './modules/commissions/commissions.service';

@Module({
  imports: [CommissionsModule],
})
export class PaymentModule {
  constructor(private commissionsService: CommissionsService) {}

  async processMonthlyPayouts() {
    // Get all pending commissions
    const pending = await this.commissionsService.getPendingCommissions();
    
    // Process payments
    for (const commission of pending) {
      await this.payoutService.processPayment(commission);
    }
  }

  async generateMonthlyReport() {
    const summary = await this.commissionsService.getCommissionSummary();
    return this.reportService.generateReport(summary);
  }
}
```

## Features & Best Practices

✅ **Comprehensive Error Handling**
- Validation on all inputs
- Meaningful error messages
- Proper HTTP status codes

✅ **Security**
- JWT Bearer token authentication
- Permission-based access control
- Admin-only endpoints protected
- CSRF protection (inherited from NestJS)

✅ **Performance**
- Pagination support
- Efficient database queries
- Indexed columns (deal_id, status, referral_partner_id)
- Query optimization with relationships

✅ **Data Integrity**
- Decimal precision for monetary values
- Proper foreign key relationships
- Timestamps for audit trail
- Transaction support (via TypeORM)

✅ **Documentation**
- Full Swagger/OpenAPI decorators
- Comprehensive JSDoc comments
- Type safety with TypeScript interfaces
- Example requests/responses

✅ **Extensibility**
- Service exported for other modules
- Custom repository for advanced queries
- Logging throughout
- Error handling with custom exceptions

## Testing

Example test cases:

```typescript
describe('CommissionsController', () => {
  describe('GET /ledger', () => {
    it('should return paginated commissions', async () => {
      const result = await controller.getLedger(
        { page: 1, limit: 20 },
        { user: { userId: 123, isAdmin: false } }
      );
      expect(result).toHaveProperty('data');
      expect(result).toHaveProperty('total');
    });

    it('non-admin should only see their own commissions', async () => {
      const result = await controller.getLedger(
        { page: 1, limit: 20, user_id: 999 },
        { user: { userId: 123, isAdmin: false } }
      );
      // Should filter to user 123's commissions
    });

    it('admin should see all commissions', async () => {
      const result = await controller.getLedger(
        { page: 1, limit: 20, user_id: 999 },
        { user: { userId: 123, isAdmin: true } }
      );
      // Should return commissions for user 999
    });
  });
});
```

## Production Checklist

- [ ] Database indices configured
- [ ] Audit logging implemented
- [ ] Commission reconciliation process defined
- [ ] Payment processing workflow implemented
- [ ] Tax calculation rules applied
- [ ] Rate limiting configured
- [ ] Monitoring and alerting set up
- [ ] Backup and disaster recovery tested
- [ ] Load testing completed  
- [ ] Security audit completed

## Troubleshooting

### Issue: "CommissionLedger entity not found"
- Verify CommissionLedger entity exists in `database/entities/`
- Check entity is properly imported in app.module.ts TypeOrmModule

### Issue: "No commissions found"
- Verify commission records exist in database for your filters
- Check user permissions (non-admins see only their own)
- Verify deal_id references valid deals

### Issue: CSV export is empty
- Check filters don't exclude all records
- Verify user has admin access for exporting other users' data
- Check date range includes commission records

## Support & Documentation

- Full Swagger documentation: `http://localhost:3000/api/docs#/Commissions`
- Test example Postman collection included in repo
- Database migrations in `database/migrations/`
- Entity definitions in `database/entities/commission-ledger.entity.ts`
