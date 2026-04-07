# ClearDeed Backend - Phase 1 Implementation Guide

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- PostgreSQL 12+
- npm or yarn

### Setup

1. **Install dependencies**
```bash
npm install
```

2. **Setup PostgreSQL database**
```bash
# Create database
createdb cleardeed_db

# Set credentials
# Default: user=cleardeed, password=cleardeed123
```

3. **Configure environment**
```bash
# Copy example config
cp .env.example .env.development

# Edit with your database credentials
```

4. **Run migrations (production only)**
```bash
npm run migrate
```

5. **Start development server**
```bash
npm run dev
```

Server will run on: http://localhost:3000/v1

## 📁 Project Structure

```
backend/
├── src/
│   ├── common/                 # Shared infrastructure
│   │   ├── decorators/         # @IsAdmin() decorator
│   │   ├── guards/             # JWT authentication guard
│   │   ├── filters/            # Global HTTP exception filter
│   │   └── exceptions/         # Business exceptions
│   │
│   ├── database/               # Database layer
│   │   ├── data-source.ts      # TypeORM configuration
│   │   ├── entities/           # 15 entity files (User, Property, Deal, etc.)
│   │   └── migrations/         # Database migrations template
│   │
│   ├── modules/                # Feature modules
│   │   ├── auth/               # OTP authentication
│   │   │   ├── auth.service.ts
│   │   │   ├── auth.controller.ts
│   │   │   ├── auth.module.ts
│   │   │   ├── strategies/jwt.strategy.ts
│   │   │   └── dto/
│   │   ├── users/              # User management
│   │   │   ├── users.service.ts
│   │   │   ├── users.controller.ts
│   │   │   ├── users.module.ts
│   │   │   └── dto/
│   │   └── properties/         # Property listings
│   │       ├── properties.service.ts
│   │       ├── properties.controller.ts
│   │       ├── properties.module.ts
│   │       └── dto/
│   │
│   ├── app.module.ts           # Root module
│   ├── app.service.ts          # Health checks
│   ├── app.controller.ts       # Root endpoints
│   └── main.ts                 # Bootstrap
│
├── .env.example               # Environment template
├── .env.development           # Development config
├── .env.production            # Production config
├── package.json               # Dependencies
├── tsconfig.json              # TypeScript config
└── README.md                  # This file
```

## 🔗 API Endpoints

### Authentication
```
POST   /v1/auth/send-otp         - Send OTP to mobile
POST   /v1/auth/verify-otp       - Verify OTP, get JWT
POST   /v1/auth/logout           - Logout (requires auth)
```

### Profile
```
GET    /v1/profile               - Get profile
POST   /v1/profile               - Create profile
PUT    /v1/profile               - Update profile
POST   /v1/profile/mode-select    - Select role (buyer/seller/investor)
```

### Properties
```
GET    /v1/properties            - List verified properties
POST   /v1/properties            - Create property (seller)
GET    /v1/properties/:id        - Get property details
PUT    /v1/properties/:id        - Update property
DELETE /v1/properties/:id        - Delete property
GET    /v1/properties/seller/my-properties - List seller's properties
POST   /v1/properties/:id/documents        - Add document
POST   /v1/properties/:id/gallery          - Add gallery image
```

### Health
```
GET    /v1/                      - API info
GET    /v1/health                - Health status
```

## 🔐 Authentication Flow

1. User requests OTP: `POST /v1/auth/send-otp`
2. System generates OTP, stores hash, sends via SMS
3. User verifies OTP: `POST /v1/auth/verify-otp`
4. System returns JWT token (valid for 24h)
5. User includes token in Authorization header: `Authorization: Bearer <token>`
6. All protected endpoints validate JWT using JwtAuthGuard

## 📊 Database Schema

**15 Core Tables:**
- users
- referral_partners
- properties
- property_verifications
- property_documents
- property_gallery
- projects
- express_interests
- deals
- deal_referral_mappings
- commission_ledgers
- agent_maintenance
- notifications
- admin_activity_logs

**Status Enums:**
- User Roles: builder, seller, investor
- Property Status: submitted, under_verification, verified, live, sold, rejected
- Deal Status: created, pending_verification, verified, active, closed

## 🧪 Testing API

### Using Swagger UI
Navigate to: http://localhost:3000/api/docs

### Using cURL
```bash
# Send OTP
curl -X POST http://localhost:3000/v1/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"mobile_number": "+919876543210"}'

# Verify OTP (use OTP from console/SMS)
curl -X POST http://localhost:3000/v1/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"mobile_number": "+919876543210", "otp": "123456"}'

# Access protected endpoint with JWT
curl -X GET http://localhost:3000/v1/profile \
  -H "Authorization: Bearer <jwt_token>"
```

## 📦 Available Scripts

```bash
# Development
npm run dev              # Start with nodemon

# Building
npm run build            # Compile TypeScript

# Production
npm start                # Run compiled app

# Database
npm run migrate          # Run pending migrations
npm run seed             # Seed database (if available)

# Testing
npm test                 # Run test suite
npm run test:cov         # Run with coverage

# Code Quality
npm run lint             # Lint TypeScript files
```

## 🛠️ Technology Stack

- **Framework**: NestJS 10
- **Language**: TypeScript 5
- **Database**: PostgreSQL 12+
- **ORM**: TypeORM
- **Authentication**: JWT + Passport
- **Validation**: class-validator
- **API Docs**: Swagger/OpenAPI
- **Development**: Nodemon + ts-node

## 🔑 Key Features - Phase 1

✅ OTP-based authentication (SMS)
✅ User profile management
✅ Referral validation
✅ Property CRUD operations
✅ Property verification workflow
✅ Document and gallery management
✅ JWT token generation and validation
✅ Global error handling
✅ Database entity relationships
✅ Environment configuration
✅ Swagger API documentation
✅ TypeScript strict mode

## 📚 Next Phases

**Phase 2**: Deals, Commissions, Notifications
**Phase 3**: Admin Dashboard, Analytics, Advanced Search
**Phase 4**: Payment Integration, Advanced Matching

## 🐛 Troubleshooting

### Database Connection Issues
```bash
# Check PostgreSQL is running
psql -U cleardeed -d cleardeed_db

# Recreate database
dropdb cleardeed_db
createdb cleardeed_db
```

### Port Already in Use
```bash
# Change PORT in .env
PORT=3001 npm run dev
```

### OTP Not Sending (Development)
- OTPs are logged to console in development
- Check terminal output for OTP value
- Configure Twilio in .env for production

## 📖 Additional Resources

- [NestJS Documentation](https://docs.nestjs.com)
- [TypeORM Documentation](https://typeorm.io)
- [Passport Authentication](https://www.passportjs.org)
- [API Specification](../docs/API_SPECIFICATION.yaml)
- [Database Schema](../docs/DATABASE_SCHEMA.sql)

## 📝 Notes

- All endpoints require JWT authentication except `/auth/send-otp` and `/auth/verify-otp`
- Validation errors return 400 with detailed error messages
- Unauthorized requests return 401
- Business logic errors return appropriate 4xx codes with error codes
- Server errors (5xx) are logged for debugging
- CORS is enabled by default in development

---

**Status**: ✅ Phase 1 Ready for Production
**Last Updated**: 2026-03-29
**Maintained By**: ClearDeed Dev Team
