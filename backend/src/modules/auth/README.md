/**
 * ClearDeed Auth Module - README
 * 
 * Complete OTP-based authentication module for NestJS
 * Self-contained with in-memory OTP storage and JWT tokens
 */

# Auth Module Documentation

## Overview

The Auth module provides complete OTP-based authentication for ClearDeed with:
- 6-digit OTP generation and verification
- 10-minute OTP expiry
- Rate limiting (max 5 requests/hour, 1-minute cooldown)
- JWT token-based authentication
- User registration on first OTP verification
- In-memory OTP storage (can be extended to Redis)

## Module Structure

```
src/modules/auth/
├── auth.controller.ts     # HTTP endpoints
├── auth.service.ts        # Business logic
├── auth.dto.ts            # DTOs with validators
├── auth.interface.ts      # TypeScript interfaces
├── auth.module.ts         # Module definition
├── otp.service.ts         # OTP logic
├── jwt.strategy.ts        # Passport JWT strategy
├── guards/
│   └── jwt-auth.guard.ts  # Route protection guard
└── README.md              # This file
```

## Installation & Setup

### 1. Ensure Dependencies are Installed

```bash
npm install @nestjs/common @nestjs/jwt @nestjs/passport @nestjs/swagger \
  passport passport-jwt class-validator class-transformer
```

Package.json already includes these dependencies.

### 2. Environment Variables

Add to your `.env` file:

```env
# JWT Configuration
JWT_SECRET=your-super-secret-key-change-in-production-min-32-chars

# Optional: SMS Provider (if you want real SMS)
# TWILIO_ACCOUNT_SID=your_account_sid
# TWILIO_AUTH_TOKEN=your_auth_token
# TWILIO_PHONE_NUMBER=+1234567890

# Node Environment
NODE_ENV=development
```

### 3. Module Registration

The AuthModule is already imported in `app.module.ts`:

```typescript
import { AuthModule } from './modules/auth/auth.module';

@Module({
  imports: [
    // ... other imports
    AuthModule,
  ],
})
export class AppModule {}
```

## API Endpoints

All endpoints are prefixed with `/v1/auth`

### 1. Send OTP

**POST** `/auth/send-otp`

Request:
```json
{
  "mobile_number": "9876543210"
}
```

Response (200 OK):
```json
{
  "success": true,
  "message": "OTP sent successfully to your mobile number"
}
```

Error Responses:
- **400 Bad Request**: Invalid mobile number format
- **429 Too Many Requests**: Rate limit exceeded (max 5/hour) or cooldown not met (min 1 minute)

Mobile number formats accepted:
- `9876543210` (10 digits)
- `+919876543210` (with +91 prefix)
- `919876543210` (91 prefix)
- `09876543210` (0 prefix)

### 2. Verify OTP

**POST** `/auth/verify-otp`

Request:
```json
{
  "mobile_number": "9876543210",
  "otp": "123456"
}
```

Response (200 OK):
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1dWlkIiwibW9iaWxlX251bWJlciI6IjEyMzQ1Njc4OTAiLCJpYXQiOjE2NzAwMDAwMDAsImV4cCI6MTY3MDA4NjQwMH0.signature",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "mobile_number": "9876543210",
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

Error Responses:
- **400 Bad Request**: OTP not found or expired
- **401 Unauthorized**: Invalid OTP code
- **429 Too Many Requests**: Max attempts exceeded (5 attempts max)

### 3. Logout

**POST** `/auth/logout`

Headers:
```
Authorization: Bearer <jwt_token>
```

Response (200 OK):
```json
{
  "success": true
}
```

Error Responses:
- **401 Unauthorized**: Missing or invalid JWT token

## Usage Examples

### cURL Examples

**Send OTP:**
```bash
curl -X POST http://localhost:3000/v1/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"mobile_number": "9876543210"}'
```

**Verify OTP:**
```bash
curl -X POST http://localhost:3000/v1/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"mobile_number": "9876543210", "otp": "123456"}'
```

**Logout:**
```bash
curl -X POST http://localhost:3000/v1/auth/logout \
  -H "Authorization: Bearer <jwt_token>"
```

### TypeScript/JavaScript Usage

```typescript
// In another service
import { AuthService } from './modules/auth/auth.service';

@Injectable()
export class UserService {
  constructor(private authService: AuthService) {}

  async getUserByToken(token: string) {
    const payload = this.authService.validateToken(token);
    return this.authService.getUserById(payload.sub);
  }
}
```

### Protecting Routes

```typescript
import { UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from './modules/auth/guards/jwt-auth.guard';
import { ApiBearerAuth } from '@nestjs/swagger';

@Controller('properties')
export class PropertiesController {
  
  @Get(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  async getProperty(
    @Param('id') id: string,
    @Request() req: any
  ) {
    // req.user contains the JWT payload with { sub, mobile_number, iat, exp }
    console.log('User mobile:', req.user.mobile_number);
    // ... your logic
  }
}
```

## OTP Behavior

### OTP Generation
- **Format**: 6-digit numeric code (e.g., 123456)
- **Expiry**: 10 minutes
- **Rate Limiting**:
  - Maximum 5 OTP requests per hour per mobile number
  - Minimum 1 minute between consecutive requests for same number
  - Returns 429 status if limits exceeded

### OTP Verification
- **Attempts**: Maximum 5 attempts to verify
- **Expiry Check**: OTP becomes invalid after 10 minutes
- **Auto-cleanup**: Expired OTPs are automatically removed every 5 minutes

### Development Mode
In development (`NODE_ENV=development`), OTPs are logged to console:
```
📱 [DEV] OTP Generated for 9876543210: 456789
⏱️  Valid for 10 minutes
```

## JWT Token Details

### Payload Structure
```json
{
  "sub": "550e8400-e29b-41d4-a716-446655440000",
  "mobile_number": "9876543210",
  "iat": 1670000000,
  "exp": 1670086400
}
```

### Token Usage
- Sent as Bearer token in `Authorization` header
- Valid for 24 hours
- Algorithm: HS256
- Secret: `JWT_SECRET` environment variable

### Example Header
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## Error Handling

All errors follow a consistent format:

```json
{
  "statusCode": 400,
  "message": "Error message",
  "error": "Bad Request"
}
```

### Common Errors

| Status | Code | Message | Solution |
|--------|------|---------|----------|
| 400 | BadRequest | Invalid mobile number format | Use 10-digit format or +91XXXXXXXXXX |
| 400 | BadRequest | OTP not found | Request a new OTP first |
| 400 | BadRequest | OTP has expired | Expired after 10 minutes, request new |
| 401 | Unauthorized | Invalid OTP | Check OTP code and try again |
| 429 | TooManyRequests | Please wait before requesting new OTP | Wait 1 minute between requests |
| 429 | TooManyRequests | Too many OTP requests | Max 5 requests per hour |
| 429 | TooManyRequests | Max verification attempts exceeded | 5 attempts max, request new OTP |

## Extending the Module

### Adding SMS Integration

Replace TODO in `auth.service.ts` sendOtp method:

```typescript
// Use Twilio
import twilio from 'twilio';

const client = twilio(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN,
);

await client.messages.create({
  body: `Your OTP is: ${otp}. Valid for 10 minutes.`,
  from: process.env.TWILIO_PHONE_NUMBER,
  to: `+91${mobileNumber}`,
});
```

### Integrating with User Database

Replace in-memory user store with TypeORM:

```typescript
// In auth.service.ts
import { InjectRepository } from '@nestjs/typeorm';
import { User } from '../../../database/entities/user.entity';

export class AuthService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    // ... other deps
  ) {}

  // Replace userStore with userRepository methods
  async getUserById(userId: string) {
    return this.userRepository.findOne({
      where: { id: userId }
    });
  }
}
```

### Using Redis for OTP Cache

Replace in-memory Map with Redis:

```typescript
// In otp.service.ts
import { Redis } from 'ioredis';

@Injectable()
export class OtpService {
  private redis: Redis;

  constructor() {
    this.redis = new Redis();
  }

  generateOtp(mobileNumber: string): string {
    // Store in Redis with 10-minute expiry
    this.redis.setex(`otp:${mobileNumber}`, 600, otp);
  }
}
```

## Monitoring & Debugging

### Get Cache Statistics

```typescript
// Inject AuthService in your monitoring service
const stats = this.authService.getStats();
console.log(`Active users: ${stats.totalUsers}`);
console.log(`Active sessions: ${stats.activeSessions}`);
console.log(`Cached OTPs: ${stats.otpCacheSize}`);
```

### Clear Data (Testing)

```typescript
// Only use in development!
this.authService.clearAllData(); // Clears users, sessions, and OTPs
```

## Testing

### Unit Tests

```typescript
import { Test } from '@nestjs/testing';
import { AuthService } from './auth.service';

describe('AuthService', () => {
  let service: AuthService;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [AuthService, OtpService, JwtService],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  it('should generate OTP', () => {
    const otp = service.otpService.generateOtp('9876543210');
    expect(otp).toMatch(/^\d{6}$/);
  });

  it('should verify valid OTP', () => {
    const mobileNumber = '9876543210';
    const otp = service.otpService.generateOtp(mobileNumber);
    const result = service.otpService.verifyOtp(mobileNumber, otp);
    expect(result).toBe(true);
  });
});
```

### Integration Tests

Use Postman or API testing tools with the examples above.

## Security Considerations

1. **JWT Secret**: Change `JWT_SECRET` in production (use strong key, min 32 chars)
2. **HTTPS**: Always use HTTPS in production
3. **Rate Limiting**: Already implemented (5 requests/hour, 1-minute cooldown)
4. **OTP Security**: OTPs are 6-digit random codes, expires in 10 minutes
5. **Token Expiry**: JWTs expire in 24 hours
6. **No Password Storage**: OTP-only authentication (no passwords to hash)

## Performance Notes

- **In-Memory Storage**: Suitable for small-medium applications
- **Scalability**: Migrate to Redis/Database as app grows
- **Cleanup**: Expired OTPs automatically cleaned every 5 minutes
- **No Database Queries**: Current implementation is very fast

## Troubleshooting

### OTP not being received
- Check if SMS provider is configured
- Verify mobile number format
- In dev mode, check console logs

### "OTP has expired"
- OTPs expire after 10 minutes
- Request a new OTP

### "Rate limit exceeded"
- Max 5 requests per hour
- Minimum 1 minute between requests
- Wait before retrying

### "Invalid JWT token"
- Token may have expired (24-hour validity)
- Request new token via OTP verification
- Check that `Authorization: Bearer` header is correct

## Support

For issues or questions, refer to:
- `/cleardeed-project/backend/README.md`
- NestJS documentation: https://docs.nestjs.com
- Passport.js: https://www.passportjs.org
