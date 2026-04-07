# ClearDeed Backend (NestJS)

## Project Structure

```
src/
├── main.ts                  # Application entry point
├── app.module.ts           # Root module
├── common/
│   ├── guards/            # Auth guards
│   ├── decorators/        # Custom decorators
│   ├── exceptions/        # Custom exceptions
│   └── filters/           # Global exception filters
├── database/
│   ├── entities/          # TypeORM entities
│   ├── migrations/        # Database migrations
│   ├── seeds/
│   └── data-source.ts     # TypeORM configuration
└── modules/
    ├── auth/
    │   ├── auth.module.ts
    │   ├── auth.service.ts
    │   ├── auth.controller.ts
    │   ├── dto/           # Data Transfer Objects
    │   └── strategies/    # JWT strategy
    ├── users/
    │   ├── users.module.ts
    │   ├── users.service.ts
    │   ├── users.controller.ts
    │   └── dto/
    ├── properties/
    │   ├── properties.module.ts
    │   ├── properties.service.ts
    │   ├── properties.controller.ts
    │   └── dto/
    ├── projects/
    ├── deals/
    ├── commissions/
    ├── referral-partners/
    ├── notifications/
    └── admin/
        ├── admin.module.ts
        ├── verification.service.ts
        └── admin.controller.ts
```

## Setup

1. **Install dependencies**: `npm install`
2. **Configure environment**: Create `.env` file
3. **Run migrations**: `npm run migrate`
4. **Seed database**: `npm run seed`
5. **Start development**: `npm run dev`

## Environment Variables

```
NODE_ENV=development
DATABASE_URL=postgresql://user:password@localhost:5432/cleardeed
JWT_SECRET=your-secret-key
JWT_EXPIRY=24h

# Twilio (SMS/WhatsApp)
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_PHONE_NUMBER=

# File Storage
AWS_S3_BUCKET=cleardeed-uploads
AWS_REGION=ap-south-1

# CORS
CORS_ORIGIN=http://localhost:3000

# Verification
VERIFICATION_SLA_HOURS=48
AUTO_REJECT_AFTER_DAYS=7
```

## API Documentation

- **Swagger UI**: http://localhost:3000/api/docs
- **OpenAPI Spec**: See `docs/API_SPECIFICATION.yaml`

## Key Services

### Auth Module
- OTP generation & verification
- JWT token management
- Session handling

### Users Module
- User profile CRUD
- Referral validation
- Role management (Buyer/Seller/Investor)

### Properties Module
- Property CRUD
- Image/document upload (S3)
- Verification workflow
- Status tracking

### Deals Module
- Deal creation (admin)
- Commission calculation
- Referral partner mapping

### Notifications Module
- SMS/WhatsApp via Twilio
- Push notifications
- Notification queuing & retry

## Testing

```bash
# Run tests
npm run test

# Coverage
npm run test:cov
```

## Deployment

- Docker support included
- Environment-based configuration
- Database migrations automated
- Monitoring & logging configured

