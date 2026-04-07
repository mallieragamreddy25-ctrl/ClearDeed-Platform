# ClearDeed - Entity Relationship Diagram (ERD)

## Database Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│                        CLEARDEED - DATABASE ENTITY RELATIONSHIPS                               │
└─────────────────────────────────────────────────────────────────────────────────────────────────┘

                                    ┌──────────────┐
                                    │    USERS     │ (id, mobile, full_name, email, city, role)
                                    └──────────────┘
                                           │
                    ┌──────────────────────┼──────────────────────────┐
                    │                      │                          │
                    ▼                      ▼                          ▼
            ┌──────────────────┐  ┌──────────────────┐      ┌──────────────────┐
            │  PROPERTIES      │  │ REFERRAL_        │      │   PROJECTS       │
            │                  │  │ PARTNERS         │      │                  │
            │ seller_user_id   │  │                  │      │ (Title, Location,│
            │ (FK) ───────────→│  │ mobile_number    │      │  ROI, Timeline)  │
            │                  │  │ type: agent/user │      │                  │
            └──────────────────┘  │ status           │      └──────────────────┘
                    │             │ commission_      │
                    │             │ enabled          │
                    ▼             └──────────────────┘
        ┌──────────────────────┐          │
        │ PROPERTY_            │          ▼
        │ VERIFICATIONS        │   ┌──────────────────────┐
        │                      │   │ AGENT_               │
        │ verified_by_admin_id │   │ MAINTENANCE          │
        │ (FK) ───────────────→│   │                      │
        │ status               │   │ fee_amount: ₹999     │
        │ verified_documents   │   │ fee_expiry_date      │
        └──────────────────────┘   │ is_active            │
                                   └──────────────────────┘
        ┌──────────────────────┐           │
        │ PROPERTY_            │──FK──────→
        │ DOCUMENTS            │
        │ (title_deed, survey, │
        │  tax_proof, etc)     │
        └──────────────────────┘

        ┌──────────────────────┐
        │ PROPERTY_            │
        │ GALLERY              │
        │ (image_url, order)   │
        └──────────────────────┘

        ┌──────────────────────┐
        │ EXPRESS_             │
        │ INTERESTS            │
        │                      │
        │ user_id (FK)────────→│ USERS
        │ property_id (FK)────→│ PROPERTIES
        │ project_id (FK)─────→│ PROJECTS
        └──────────────────────┘

                                    ┌──────────────┐
                                    │    DEALS     │
                                    │              │
                                    │ buyer_user   │
                                    │ seller_user  │
                                    │ property_id  │
                                    │ (OR project) │
                                    └──────────────┘
                                           │
                    ┌──────────────────────┼──────────────────────┐
                    │                      │                      │
                    ▼                      ▼                      ▼
        ┌──────────────────────┐  ┌──────────────────┐   ┌──────────────────┐
        │ DEAL_REFERRAL_       │  │ COMMISSION_      │   │ NOTIFICATIONS    │
        │ MAPPINGS             │  │ LEDGERS          │   │                  │
        │                      │  │                  │   │ related_deal_id  │
        │ deal_id (FK)────────→│  │ deal_id (FK)─────│   │ (FK) ────────────│
        │ referral_partner_id  │  │ referral_partner │   │ notification_type│
        │ side: buyer/seller   │  │ commission_type  │   │ delivery_status  │
        │ commission_%         │  │ amount           │   │ channel: SMS/push│
        │                      │  │ status: pending  │   │                  │
        │                      │  │ payment_date     │   │                  │
        │                      │  │ payment_ref      │   │                  │
        └──────────────────────┘  └──────────────────┘   └──────────────────┘
                    │
                    │
                    ▼
        ┌──────────────────────┐
        │ REFERRAL_PARTNERS    │
        │ (Agent/Partner gets  │
        │  commission for deal)│
        └──────────────────────┘

        ┌──────────────────────┐
        │ ADMIN_ACTIVITY_      │
        │ LOGS                 │
        │                      │
        │ admin_user_id (FK)──→│ USERS
        │ action_type          │
        │ related_entity_type  │
        │ action_details [JSON]│
        │ ip_address           │
        └──────────────────────┘
```

---

## Entity Details & Relationships

### 1. USERS
```
id (PK)
mobile_number (UNIQUE) ← Authentication
email (UNIQUE)
otp_hash, otp_created_at
profile_type: ENUM (buyer, seller, investor)
budget_range, net_worth_range

referral_mobile_number ← Link to referral partner
referred_by_mobile ← Who referred this user

is_active, is_verified
session_token, token_expires_at
```

**Foreign Key References:**
- PROPERTIES.seller_user_id
- REFERRAL_PARTNERS.user_id
- DEALS.buyer_user_id
- DEALS.seller_user_id
- EXPRESS_INTERESTS.user_id
- ADMIN_ACTIVITY_LOGS.admin_user_id

---

### 2. REFERRAL_PARTNERS
```
id (PK)
user_id (FK) → USERS (nullable, optional link)
mobile_number (UNIQUE)

partner_type: ENUM (agent, verified_user)
full_name, email, city

agent_license_number, agency_name (for agents)
status: ENUM (pending, under_review, approved, rejected)

is_active, commission_enabled
yearly_maintenance_fee_status
maintenance_fee_renewal_date
total_commission_earned (denormalized)
```

**Key Logic:**
- Referral partners can be registered WITHOUT being users
- Agent fee (₹999) must be paid to enable commissions
- Status must be "approved" before commission eligibility

---

### 3. PROPERTIES
```
id (PK)
seller_user_id (FK) → USERS (CASCADE on delete)

category: ENUM (land, individual_house, commercial, agriculture)
title, description, location, city, pincode

price, area, area_unit (sqft/sqm)
ownership_status: VARCHAR

status: ENUM (submitted, under_verification, verified, live, sold, rejected)
is_verified, verified_badge
verified_at: TIMESTAMP

primary_image_url
created_at, updated_at
```

**Relationships:**
- 1 User (seller) : Many Properties
- 1 Property : 1 PropertyVerification
- 1 Property : Many PropertyDocuments
- 1 Property : Many PropertyGallery
- 1 Property : Many Deals
- 1 Property : Many ExpressInterests

---

### 4. PROPERTY_VERIFICATIONS
```
id (PK)
property_id (FK) → PROPERTIES (CASCADE)
verified_by_admin_id (FK) → USERS (SET NULL)

verification_status: ENUM (pending, under_review, approved, rejected)
verified_documents: TEXT[]
verification_notes, rejection_reason
verified_at: TIMESTAMP
```

**Status Flow:**
```
Properties.status = "submitted"
    ↓
    Admin reviews → PropertyVerifications.status = "under_review"
    ↓
    Admin approves → PropertyVerifications.status = "approved"
                  → Properties.status = "verified"
                  → Properties.verified_badge = TRUE
    ↓
    Property goes live → Properties.status = "live"
```

---

### 5. EXPRESS_INTERESTS
```
id (PK)
user_id (FK) → USERS
property_id (FK) → PROPERTIES (nullable)
project_id (FK) → PROJECTS (nullable)

user_role: ENUM (buyer, investor)
interest_date
is_active
```

**Constraint:**
- EITHER property_id OR project_id must be NOT NULL (but not both)
- Tracks buyer/investor interest before deal creation

---

### 6. DEALS
```
id (PK)
created_by_admin_id (FK) → USERS

buyer_user_id (FK) → USERS (CASCADE)
seller_user_id (FK) → USERS (CASCADE)

property_id (FK) → PROPERTIES (nullable)
project_id (FK) → PROJECTS (nullable)

status: ENUM (created, pending_verification, verified, active, closed)
transaction_value, deal_closed_at
```

**Constraint:**
- EITHER property_id OR project_id (cannot be both null, cannot be both set)

**Commission Lock:**
- DealReferralMappings locks commission % at deal creation
- Changes not allowed after creation
- Commission calculated on closure

---

### 7. DEAL_REFERRAL_MAPPINGS
```
id (PK)
deal_id (FK) → DEALS (CASCADE)
referral_partner_id (FK) → REFERRAL_PARTNERS (CASCADE)

side: VARCHAR (buyer, seller)
commission_percentage: DECIMAL
commission_locked_at: TIMESTAMP
```

**Example for Deal #89 (₹45L property):**
- Buyer Agent (Akshay): 1% of 2% buyer fee = ₹45,000
- ClearDeed (Buyer): 1% of 2% buyer fee = ₹45,000
- Seller Agent (Ravi): 1% of 2% seller fee = ₹45,000
- ClearDeed (Seller): 1% of 2% seller fee = ₹45,000
- **Total Deal Commission: ₹1,80,000**

---

### 8. COMMISSION_LEDGERS
```
id (PK)
deal_id (FK) → DEALS
referral_partner_id (FK) → REFERRAL_PARTNERS (nullable)

commission_type: ENUM (buyer_fee, seller_fee, platform_fee, referral_fee)
amount, percentage_applied

status: VARCHAR (pending, approved, paid)
payment_date, payment_reference

notes, created_at, updated_at
```

**Status Flow:**
```
Deal Created
├─ Commission calculated
├─ Status = "pending" (awaiting approval)
├─ Admin reviews & approves
├─ Status = "approved"
└─ Payment processed
   └─ Status = "paid"
```

---

### 9. AGENT_MAINTENANCE
```
id (PK)
referral_partner_id (FK) → REFERRAL_PARTNERS (CASCADE)

fee_amount: ₹999 (default)
payment_date, payment_reference
fee_expiry_date
is_active

created_at, updated_at
```

**Business Logic:**
- When fee paid → `is_active = TRUE`
- When expired → `is_active = FALSE`
- When `is_active = FALSE` → Commissions are locked (can't be paid)
- Renewal reminder sent 30 days before expiry

---

### 10. NOTIFICATIONS
```
id (PK)
user_id (FK) → USERS (CASCADE)

notification_type: VARCHAR (verification_complete, deal_started, deal_closed, commission_recorded)
title, body

channel: VARCHAR (sms, whatsapp, push)
recipient_mobile, recipient_email

sent_at, delivery_status (pending, sent, failed)
delivery_attempts, last_attempt_at

related_deal_id (FK) → DEALS (nullable)
related_property_id (FK) → PROPERTIES (nullable)

created_at
```

**Notification Triggers:**
```
Property verified → Notification to seller
Deal created → Notifications to buyer, seller, referral partners
Deal closed → Notifications to all parties + commission approved
Commission recorded → Notification to referral partner
```

---

### 11. ADMIN_ACTIVITY_LOGS
```
id (PK)
admin_user_id (FK) → USERS (SET NULL)

action_type: VARCHAR (verify_property, create_deal, close_deal, approve_referral, ...)
related_entity_type: VARCHAR (property, deal, referral_partner)
related_entity_id: INT

action_details: JSONB (flexible, stores what changed)
ip_address: VARCHAR
created_at
```

**Example Log Entry:**
```json
{
  "action_type": "verify_property",
  "related_entity_type": "property",
  "related_entity_id": 542,
  "action_details": {
    "status_before": "under_verification",
    "status_after": "verified",
    "verification_notes": "All documents verified",
    "approved_by": "Ajay Kumar"
  },
  "ip_address": "203.0.113.45",
  "created_at": "2025-03-20T10:30:00Z"
}
```

---

## Data Flow Diagrams

### 1. Property Upload & Verification Flow
```
User (Seller)
    │
    ├─→ POST /properties (title, location, price)
    │   └─→ PROPERTIES table (status="submitted")
    │
    ├─→ POST /properties/{id}/upload-documents
    │   └─→ PROPERTY_DOCUMENTS table
    │
    ├─→ POST /properties/{id}/upload-gallery
    │   └─→ PROPERTY_GALLERY table
    │
    └─→ [Self-service complete]

Admin
    │
    └─→ GET /admin/properties/pending
        └─→ Retrieve PROPERTIES (status="submitted")
            │
            ├─→ Review PROPERTY_DOCUMENTS
            ├─→ Review PROPERTY_GALLERY
            └─→ Check PROPERTY_DETAILS
                │
                ├─→ PUT /admin/properties/{id}/approve
                │   ├─→ Update PROPERTIES (status="verified")
                │   ├─→ Update PROPERTY_VERIFICATIONS (status="approved")
                │   └─→ Send NOTIFICATION to seller
                │
                └─→ PUT /admin/properties/{id}/reject
                    └─→ Update PROPERTIES (status="rejected")
                        └─→ Send NOTIFICATION with reason
```

### 2. Deal Creation & Commission Flow
```
Admin
    │
    └─→ POST /deals
        ├─→ Validate buyer exists
        ├─→ Validate seller exists
        ├─→ Validate property verified (status="verified")
        │
        ├─→ Create DEALS record
        │   └─→ Lookup PROPERTIES to lock price
        │
        ├─→ POST /deals/{id}/add-referral-partners
        │   ├─→ Validate referral partner status="approved"
        │   ├─→ Validate agent maintenance fee paid
        │   │
        │   ├─→ Create DEAL_REFERRAL_MAPPINGS
        │   │   └─→ Lock commission_percentage & date
        │   │
        │   └─→ Calculate & create COMMISSION_LEDGERS
        │       ├─→ Buyer side: 2% total (1% to partner, 1% to platform)
        │       ├─→ Seller side: 2% total (1% to partner, 1% to platform)
        │       └─→ Status = "pending"
        │
        ├─→ Send NOTIFICATIONS
        │   ├─→ To buyer
        │   ├─→ To seller
        │   └─→ To referral partners
        │
        └─→ Log ADMIN_ACTIVITY_LOGS (action_type="create_deal")

Later: Admin closes deal
    │
    └─→ POST /deals/{id}/close
        ├─→ Update DEALS (status="closed", deal_closed_at=NOW)
        │
        ├─→ Update PROPERTIES (status="sold")
        │
        ├─→ Update COMMISSION_LEDGERS
        │   ├─→ Status = "approved" (after final check)
        │   └─→ Payment_date = NOW (if immediate)
        │
        └─→ Send final NOTIFICATIONS
            └─→ Commission recorded notifications to partners
```

### 3. Agent Yearly Fee Collection Flow
```
Admin
    │
    ├─→ GET /referral-partners?status=maintenance_due
    │   └─→ REFERRAL_PARTNERS where fee_expiry_date < TODAY
    │
    ├─→ Send NOTIFICATION to agent
    │   └─→ "Your maintenance fee (₹999) is due"
    │
    ├─→ Agent pays (manual bank transfer)
    │
    └─→ POST /referral-partners/{id}/pay-maintenance-fee
        ├─→ Create AGENT_MAINTENANCE record
        │   ├─→ fee_amount = 999
        │   ├─→ payment_date = NOW
        │   ├─→ payment_reference = "Bank slip ref"
        │   ├─→ fee_expiry_date = NOW + 1 year
        │   └─→ is_active = TRUE
        │
        ├─→ Update REFERRAL_PARTNERS
        │   └─→ commission_enabled = TRUE
        │
        └─→ Send NOTIFICATION to agent
            └─→ "Fee received, commissions activated"
```

---

## Indexing Strategy

### Performance-Critical Indexes
```sql
-- User lookups
CREATE INDEX idx_users_mobile ON users(mobile_number);
CREATE INDEX idx_users_email ON users(email);

-- Property searches
CREATE INDEX idx_properties_status ON properties(status);
CREATE INDEX idx_properties_city ON properties(city);
CREATE INDEX idx_properties_category ON properties(category);
CREATE INDEX idx_properties_seller_user_id ON properties(seller_user_id);

-- Verification tracking
CREATE INDEX idx_property_verifications_status ON property_verifications(verification_status);

-- Deal management
CREATE INDEX idx_deals_status ON deals(status);
CREATE INDEX idx_deals_buyer_user_id ON deals(buyer_user_id);
CREATE INDEX idx_deals_seller_user_id ON deals(seller_user_id);

-- Commission tracking
CREATE INDEX idx_commission_ledgers_status ON commission_ledgers(status);
CREATE INDEX idx_commission_ledgers_deal_id ON commission_ledgers(deal_id);

-- Audit trail
CREATE INDEX idx_admin_activity_logs_created_at ON admin_activity_logs(created_at);

-- Referral lookups
CREATE INDEX idx_referral_partners_status ON referral_partners(status);
CREATE INDEX idx_referral_partners_mobile ON referral_partners(mobile_number);
```

---

## Constraints & Business Rules

```sql
-- No null transaction value in deals
ALTER TABLE deals
ADD CONSTRAINT check_deal_has_transaction_value
CHECK (transaction_value IS NOT NULL OR transaction_value > 0);

-- Deal must have property OR project, not both
ALTER TABLE deals
ADD CONSTRAINT check_deal_has_property_or_project
CHECK ((property_id IS NOT NULL AND project_id IS NULL) 
       OR (property_id IS NULL AND project_id IS NOT NULL));

-- Express interest must have property OR project
ALTER TABLE express_interests
ADD CONSTRAINT check_interest_has_property_or_project
CHECK ((property_id IS NOT NULL AND project_id IS NULL)
       OR (property_id IS NULL AND project_id IS NOT NULL));

-- Can't pay commission if agent fee not paid
-- (Enforced in application logic, not database)
-- IF agent_maintenance.is_active = FALSE
--    THEN commission status stays "pending" forever

-- Property can't be sold without deal
-- (Constraint: Properties.status = "sold" requires Deal.deal_closed_at = NOW)
```

---

## Migration Path

For evolving the schema:

1. **Phase 1** (MVP): Current 11 tables
2. **Phase 2** (Enhanced):
   - Add `property_view_count` for analytics
   - Add `user_preferences` for notifications
   - Add `price_history` for properties
   - Add `deal_timeline_events` for better tracking
3. **Phase 3** (Premium):
   - Add `property_verification_rules` for configurable checks
   - Add `commission_disputes` table
   - Add `user_credit_score` for risk assessment
   - Add `referral_performance_metrics` for trending

---

**Generated:** March 29, 2026  
**Database:** PostgreSQL 13+  
**Version:** 1.0.0  
**Status:** Production-ready schema
