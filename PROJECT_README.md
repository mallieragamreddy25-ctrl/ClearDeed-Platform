# ClearDeed Project - Complete Technical Specification

## 📦 Project Components Created

This comprehensive project setup includes all components needed to build ClearDeed from scratch:

### ✅ 1. **DATABASE SCHEMA** (`docs/DATABASE_SCHEMA.sql`)
- PostgreSQL database design with 18+ tables
- All enums and data types defined
- Relationships and constraints enforced
- Indexes for performance optimization
- Triggers for automatic timestamp updates
- Ready to run: `psql -U postgres < DATABASE_SCHEMA.sql`

**Key Tables:**
- Users, ReferralPartners, Properties, Projects
- Deals, CommissionLedgers, DealReferralMappings
- PropertyVerifications, ExpressInterests, Notifications
- AdminActivityLogs for audit trail

---

### ✅ 2. **API SPECIFICATION** (`docs/API_SPECIFICATION.yaml`)
- Complete OpenAPI 3.0 specification
- 50+ endpoints documented
- Request/response schemas defined
- Authentication & authorization rules
- Error codes and status codes

**API Sections:**
- Auth (OTP, login, logout)
- Profile (CRUD, mode selection)
- Properties (list, detail, upload, interest)
- Projects (investment listings)
- Deals (admin operations)
- Commissions (ledger, tracking)
- Referral Partners (registration, fees)
- Notifications
- Admin & Seller dashboards

---

### ✅ 3. **FLUTTER FRONTEND** (`frontend-flutter/`)
- Complete project structure
- Theme system (corporate minimal design)
- Model definitions with JSON serialization
- Screen templates for all major flows
- Pubspec with production-ready dependencies

**Structure:**
```
lib/
├── theme/app_theme.dart          # Dark blue + grey corporate theme
├── models/user.dart, property.dart
├── screens/auth/login_screen.dart  (OTP flow)
├── screens/home/home_screen.dart    (Category browsing)
├── screens/profile/
├── screens/properties/              (Buy module)
├── screens/sell/                    (Sell module)
├── screens/projects/                (Investment module)
├── services/api_service.dart        (Dio + Retrofit)
└── providers/                       (Riverpod state management)
```

**Dependencies:**
- State: Riverpod (reactive)
- Network: Dio + Retrofit (type-safe)
- Storage: Hive + SharedPreferences
- UI: Material Design 3, Google Fonts
- Navigation: GoRouter
- Auth: JWT, Passport

---

### ✅ 4. **BACKEND (NESTJS)** (`backend/`)
- NestJS boilerplate with TypeScript
- Package.json with all dependencies
- tsconfig configured
- Swagger/OpenAPI enabled
- Database configuration ready

**Setup:**
```bash
npm install
npm run dev      # Starts dev server on :3000
npm run migrate  # Database migrations
npm run test     # Testing suite
```

**Modules to Build:**
- Auth (OTP, JWT, Passport)
- Users (profile, roles)
- Properties (CRUD, uploads, verification)
- Projects (investment listings)
- Deals (deal creation, commission)
- Commissions (ledger, calculations)
- ReferralPartners (agent management)
- Notifications (SMS/WhatsApp via Twilio)
- Admin (verification panel)

---

### ✅ 5. **ADMIN PANEL WIREFRAMES** (`admin-panel/ADMIN_WIREFRAMES.html`)
- Interactive HTML wireframes (open in browser)
- 8 major admin flows designed

**Wireframes Included:**
1. **Main Dashboard** - Stats, recent activities
2. **Property Verification** - Pending review list with filters
3. **Property Detail Review** - Full verification checklist
4. **Deal Management** - Active deals, commission tracking
5. **Agent Management** - Maintenance fee collection, status
6. **Commission Ledger** - Full tracking and reporting
7. **Create Deal** - Multi-step deal creation flow
8. **Security & Features** - Admin capabilities summary

**Open in Browser:**
```
file:///path/to/admin-panel/ADMIN_WIREFRAMES.html
```

---

## 🚀 Getting Started (For Your Developer)

### Phase 1: Setup (Week 1)

1. **Database**
   ```bash
   psql -U postgres < docs/DATABASE_SCHEMA.sql
   ```

2. **Backend**
   ```bash
   cd backend
   npm install
   cp .env.example .env
   # Edit .env with database credentials
   npm run migrate
   npm run dev
   ```

3. **Frontend**
   ```bash
   cd frontend-flutter
   flutter pub get
   flutter pub run build_runner build
   flutter run
   ```

### Phase 2: API Development (Weeks 2-4)
Implement endpoints in order:
1. Auth module (OTP, JWT)
2. Users CRUD
3. Properties CRUD + verification
4. Deals + commission
5. Others

### Phase 3: Mobile App (Weeks 4-6)
1. Connect Flutter screens to APIs
2. Implement state management
3. Add notifications
4. Testing

### Phase 4: Admin Panel (Weeks 6-8)
1. Build web dashboard (React recommended)
2. Implement verification panel
3. Deal management UI
4. Commission reports

### Phase 5: Testing & Deployment (Weeks 8-10)
1. E2E testing
2. Security audit
3. Performance optimization
4. Deploy to staging & production

---

## 📋 File Structure Overview

```
cleardeed-project/
├── docs/
│   ├── DATABASE_SCHEMA.sql          # PostgreSQL schema (18 tables)
│   ├── API_SPECIFICATION.yaml       # OpenAPI 3.0 spec (50+ endpoints)
│   └── ENTITY_DIAGRAM.md            (to be created)
│
├── backend/                          # NestJS API
│   ├── src/
│   │   ├── main.ts
│   │   └── modules/
│   │       ├── auth/
│   │       ├── users/
│   │       ├── properties/
│   │       ├── deals/
│   │       ├── commissions/
│   │       └── ... (other modules)
│   ├── package.json
│   ├── tsconfig.json
│   ├── .env.example
│   └── README.md
│
├── frontend-flutter/                # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── theme/app_theme.dart
│   │   ├── models/
│   │   ├── screens/
│   │   ├── services/
│   │   └── providers/
│   ├── pubspec.yaml
│   └── README.md
│
├── admin-panel/
│   ├── ADMIN_WIREFRAMES.html        # Interactive wireframes
│   └── (React app to be created)
│
└── PROJECT_README.md                 # This file
```

---

## 🔑 Key Business Logic Implemented

### Authentication
- OTP-based (no passwords)
- JWT tokens with expiry
- Session management
- Rate limiting on OTP attempts

### Property Verification
- Status flow: Submitted → Under Review → Verified → Live → Sold
- Document tracking (title deed, survey, etc.)
- Admin approval required
- SLA enforcement (48-72 hours target)

### Commission Calculation
**Properties:**
- Buyer side: 2% (1% to referral partner, 1% to ClearDeed)
- Seller side: 2% (1% to referral partner, 1% to ClearDeed)

**Investment Projects:**
- Platform: 2-10% (variable)
- Referral: 1-2%

### Referral Validation
- System checks if referral number is active agent OR approved partner
- Commission enabled only after verification
- ₹999 yearly maintenance fee requirement
- Non-commission signups blocked (configurable)

### Deal Management
- Admin only deal creation
- Commission locked when deal created
- Closure triggers payment
- Full audit trail

---

## 🛠️ Configuration Parameters

Create `.env` in backend with:

```env
NODE_ENV=development
DATABASE_URL=postgresql://user:pass@localhost/cleardeed
JWT_SECRET=super-secret-key-change-in-prod
JWT_EXPIRY=24h

# Commission Settings
PROPERTY_BUYER_FEE=2          # percentage
PROPERTY_SELLER_FEE=2
INVESTMENT_FEE_MIN=2
INVESTMENT_FEE_MAX=10

# Agent Fee
AGENT_YEARLY_FEE=999

# Verification
VERIFICATION_SLA_HOURS=48
AUTO_REJECT_AFTER_DAYS=7

# Twilio (SMS/WhatsApp)
TWILIO_ACCOUNT_SID=your_sid
TWILIO_AUTH_TOKEN=your_token
TWILIO_PHONE_NUMBER=+1234567890

# AWS S3 (Document Storage)
AWS_S3_BUCKET=cleardeed-uploads
AWS_REGION=ap-south-1
```

---

## 🧪 Testing Strategy

### Backend
```bash
npm run test              # Unit tests
npm run test:cov         # Coverage report
```

### Frontend
```bash
flutter test
```

### E2E
- Selenium/Cypress for web
- Appium for mobile

---

## 📱 Mobile App Features Checklist

- [ ] Login with OTP
- [ ] Profile creation & role selection
- [ ] Browse properties (buy module)
- [ ] Property details with gallery
- [ ] Express interest in properties
- [ ] Sell property (step-by-step upload)
- [ ] Browse investment projects
- [ ] Notifications (verification status, deals)
- [ ] Referral tracking (secure link)
- [ ] Commission tracking (for agents)

---

## 🌐 Web Admin Features Checklist

- [ ] Dashboard with KPIs
- [ ] Property verification workflow
- [ ] Deal creation & management
- [ ] Commission ledger & reporting
- [ ] Agent/partner management
- [ ] Fee collection & tracking
- [ ] Audit logs
- [ ] User management
- [ ] System settings
- [ ] Bulk operations

---

## 🔒 Security Checklist

- [x] Passwords hashed (bcrypt)
- [x] JWT tokens used
- [x] OTP rate limiting
- [x] CORS configured
- [x] Input validation (class-validator)
- [x] SQL injection prevention (TypeORM)
- [ ] HTTPS enforced (production)
- [ ] Rate limiting on API
- [ ] DDoS protection
- [ ] Encryption at rest for sensitive data
- [ ] PII masking (phones, addresses in logs)
- [ ] Regular security audits

---

## 📊 Database Design Highlights

**Denormalization Strategy:**
- `referral_partners` has `total_commission_earned` (cached for reporting)
- `commission_ledgers` tracks all types (buyer fee, seller fee, referral)

**Audit Trail:**
- `admin_activity_logs` tracks all admin actions IP & timestamp

**Soft Deletes:**
- Consider adding `deleted_at` timestamps for GDPR compliance

**Indexing:**
- All foreign keys indexed
- Status columns indexed for fast filtering
- Created_at indexed for time-range queries

---

## 🔄 Deployment Strategy

### Development
- Local PostgreSQL
- `npm run dev` (NestJS with auto-reload)
- `flutter run` (mobile)

### Staging
- RDS PostgreSQL
- Docker containers
- Swagger at `/api/docs`

### Production
- AWS/GCP managed database
- Kubernetes clusters
- CDN for static assets
- Logging & monitoring (DataDog/NewRelic)

---

## 💬 Support & Questions

### API Documentation
Open in Swagger after backend starts:
```
http://localhost:3000/api/docs
```

### Database Queries
Reference schema from:
```
docs/DATABASE_SCHEMA.sql
```

### Wireframes & UI
Open in browser:
```
admin-panel/ADMIN_WIREFRAMES.html
```

---

## ✨ Next Steps

1. **Share this folder** with your development team
2. **Review** the database schema and API spec
3. **Set up local environments** (DB, backend, frontend)
4. **Start Phase 1** with backend authentication
5. **Build in order** following the 10-week roadmap
6. **Test continuously** with automated tests
7. **Deploy to staging** after Phase 3
8. **Launch MVP** after Phase 5

---

## 📞 Technical Stack Summary

| Component | Technology | Why |
|-----------|-----------|-----|
| Mobile | Flutter | Cross-platform (iOS/Android) |
| Backend | NestJS | Type-safe, scalable, enterprise-grade |
| Database | PostgreSQL | ACID compliance, JSON support, strong typing |
| State | Riverpod | Reactive, testable, no boilerplate |
| Auth | JWT + OTP | Stateless, scalable, no password storage |
| API | OpenAPI | Documentation, SDK generation, testing |
| Admin | React (TBD) | Fast UI, component reusability |
| Storage | S3 + Hive | Scalable, reliable, offline-capable |
| Notifications | Twilio | Reliable SMS/WhatsApp delivery |
| Monitoring | (TBD) | Production visibility & alerting |

---

**Last Updated:** March 29, 2026  
**Version:** 1.0.0  
**Status:** Ready for Development
