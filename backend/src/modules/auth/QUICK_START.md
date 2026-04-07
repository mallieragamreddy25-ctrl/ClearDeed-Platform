# ClearDeed Auth Module - Quick Start Guide

## 🎯 QUICK START (5 minutes)

### Files Created (8 Core Files)

All files are in `src/modules/auth/`:

| File | Purpose | Status |
|------|---------|--------|
| `auth.module.ts` | Module definition & DI setup | ✅ Ready |
| `auth.controller.ts` | 3 HTTP endpoints | ✅ Ready |
| `auth.service.ts` | Business logic & OTP handling | ✅ Ready |
| `otp.service.ts` | OTP generation & verification | ✅ Ready |
| `jwt.strategy.ts` | Passport JWT strategy | ✅ Ready |
| `guards/jwt-auth.guard.ts` | Route protection guard | ✅ Ready |
| `auth.dto.ts` | Input/output DTOs | ✅ Ready |
| `auth.interface.ts` | TypeScript interfaces | ✅ Ready |

---

## ⚡ Copy-Paste Usage

### 1. Environment Setup
Add to `.env`:
```env
JWT_SECRET=my-super-secret-key-min-32-characters-long
NODE_ENV=development
```

### 2. Start Server
```bash
npm run dev
```

### 3. Send OTP Request
```bash
curl -X POST http://localhost:3000/v1/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"mobile_number": "9876543210"}'
```

**Response (200)**:
```json
{
  "success": true,
  "message": "OTP sent successfully to your mobile number"
}
```

**In dev mode, OTP is logged to console**:
```
📱 [DEV] OTP Generated for 9876543210: 456789
⏱️  Valid for 10 minutes
```

### 4. Verify OTP & Get Token
```bash
curl -X POST http://localhost:3000/v1/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"mobile_number": "9876543210", "otp": "456789"}'
```

**Response (200)**:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1NTBlODQwMC1lMjliLTQxZDQtYTcxNi00NDY2NTU0NDAwMDAiLCJtb2JpbGVfbnVtYmVyIjoiOTg3NjU0MzIxMCIsImlhdCI6MTY3MDAwMDAwMCwiZXhwIjoxNjcwMDg2NDAwfQ.signature",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "mobile_number": "9876543210",
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

### 5. Logout (with token)
```bash
curl -X POST http://localhost:3000/v1/auth/logout \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200)**:
```json
{
  "success": true
}
```

---

## 🛡️ Using in Other Modules

### Protect a Route
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
    // req.user = { sub: "user-id", mobile_number: "9876543210", iat, exp }
    const userId = req.user.sub;
    const mobile = req.user.mobile_number;
    // ... your logic
  }
}
```

### Inject AuthService
```typescript
import { AuthService } from './modules/auth/auth.service';

@Injectable()
export class UserService {
  constructor(private authService: AuthService) {}

  getStats() {
    return this.authService.getStats();
    // { totalUsers, activeSessions, otpCacheSize }
  }

  validateToken(token: string) {
    return this.authService.validateToken(token);
    // Returns { sub, mobile_number, iat, exp }
  }
}
```

---

## 📋 Endpoint Reference

### POST /v1/auth/send-otp
**Send OTP to mobile number**

Request:
```json
{
  "mobile_number": "9876543210"
}
```

Responses:
- `200`: OTP sent successfully
- `400`: Invalid mobile number format
- `429`: Rate limit exceeded (wait 1 minute) or too many requests (max 5/hour)

---

### POST /v1/auth/verify-otp
**Verify OTP and get JWT token**

Request:
```json
{
  "mobile_number": "9876543210",
  "otp": "123456"
}
```

Responses:
- `200`: Success - returns token and user
- `400`: OTP not found or expired
- `401`: Invalid OTP code
- `429`: Max verification attempts (5 max)

---

### POST /v1/auth/logout
**Logout user**

Header:
```
Authorization: Bearer <jwt_token>
```

Responses:
- `200`: Logout successful
- `401`: Missing or invalid token

---

## 🔍 Testing Scenarios

### Test Rate Limiting
```bash
# First request - success
curl -X POST http://localhost:3000/v1/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"mobile_number": "9876543210"}'

# Second request within 1 minute - should fail with 429
curl -X POST http://localhost:3000/v1/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"mobile_number": "9876543210"}'

# Error:
# {
#   "statusCode": 429,
#   "message": "Please wait before requesting a new OTP",
#   "error": "Too Many Requests"
# }
```

### Test Verify OTP Attempts
```bash
# First attempt - fail with wrong OTP
curl -X POST http://localhost:3000/v1/auth/verify-otp \
  -d '{"mobile_number": "9876543210", "otp": "000000"}'

# Repeat 5 times - 5th attempt fails with 429
# Error: "Maximum OTP verification attempts exceeded"
```

### Test Token Expiry
JWT token is valid for 24 hours. After that:
```bash
curl -X POST http://localhost:3000/v1/auth/logout \
  -H "Authorization: Bearer <expired_token>"

# Error:
# {
#   "statusCode": 401,
#   "message": "Invalid or expired token",
#   "error": "Unauthorized"
# }
```

---

## 🐛 Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| **OTP not logged to console** | Make sure `NODE_ENV=development` in `.env` |
| **"OTP not found"** | Send OTP first with `/send-otp` endpoint |
| **"Please wait 1 minute"** | Rate limit: minimum 1 minute between requests |
| **"Too many OTP requests"** | Max 5 per hour. Limit resets hourly |
| **"Invalid OTP"** | Check the OTP code from console. Max 5 attempts |
| **"OTP expired"** | Expired after 10 minutes. Request new OTP |
| **"Invalid token"** | Token might be expired (24h) or malformed |

---

## 📚 More Information

- **Full Documentation**: [./README.md](./README.md)
- **Implementation Details**: [./IMPLEMENTATION_COMPLETE.md](./IMPLEMENTATION_COMPLETE.md)

---

## ✨ Features At a Glance

✅ 6-digit OTP generation
✅ 10-minute OTP expiry
✅ Rate limiting (5 requests/hour)
✅ 1-minute cooldown between requests
✅ Max 5 verification attempts
✅ JWT token (24-hour validity)
✅ Automatic user creation on first login
✅ In-memory storage (no database needed)
✅ Phone number normalization
✅ Swagger documentation
✅ Type-safe TypeScript
✅ Production-ready error handling

---

**Ready to use! No additional setup required.** 🚀
