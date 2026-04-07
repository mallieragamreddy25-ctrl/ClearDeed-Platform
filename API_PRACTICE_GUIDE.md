# 🧪 **ClearDeed Platform - API Practice Guide**

## **Setup for Testing**

**Base URL:** `http://localhost:3000`
**Environment:** Demo/Development with mock data

---

## **1. AUTHENTICATION FLOW**

### **Step 1: Send OTP**

**Request:**
```bash
curl -X POST http://localhost:3000/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{
    "mobile": "+919876543210"
  }'
```

**Expected Response (200 OK):**
```json
{
  "message": "OTP sent to +919876543210",
  "expiresIn": 600,
  "demo_otp": "482916"
}
```

**What to do next:** Copy the `demo_otp` value from response (e.g., "482916")

---

### **Step 2: Verify OTP and Get JWT Token**

**Request:**
```bash
curl -X POST http://localhost:3000/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{
    "mobile": "+919876543210",
    "otp": "482916"
  }'
```

**Expected Response (200 OK):**
```json
{
  "message": "OTP verified successfully",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJtb2JpbGUiOiIrOTE5ODc2NTQzMjEwIiwiaWF0IjoxNzEyNTAxMjAwLCJleHAiOjE3MTI1ODc2MDB9.abcd1234...",
  "expiresIn": 86400
}
```

**Save the token** - you'll use it for authenticated requests (authorization header)

---

## **2. USER PROFILE MANAGEMENT**

### **Create/Update User Profile**

**Request:**
```bash
curl -X POST http://localhost:3000/api/users/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -d '{
    "name": "Rajesh Kumar",
    "city": "Bangalore",
    "profile_type": "buyer",
    "budget_range": "5000000-10000000",
    "referral_mobile": "+919876543200"
  }'
```

**Expected Response (200 OK):**
```json
{
  "message": "Profile created successfully",
  "data": {
    "id": "user_1712500234567",
    "mobile": "+919876543210",
    "name": "Rajesh Kumar",
    "city": "Bangalore",
    "profile_type": "buyer",
    "budget_range": "5000000-10000000",
    "referral_mobile_number": "+919876543200",
    "is_verified": true,
    "created_at": "2026-04-07T10:30:34.567Z"
  }
}
```

### **Get User Profile**

**Request:**
```bash
curl -X GET http://localhost:3000/api/users/profile \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Expected Response (200 OK):**
```json
{
  "data": {
    "id": "user_1712500234567",
    "mobile": "+919876543210",
    "name": "Rajesh Kumar",
    "city": "Bangalore",
    "profile_type": "buyer",
    "budget_range": "5000000-10000000",
    "referral_mobile_number": "+919876543200",
    "is_verified": true,
    "created_at": "2026-04-07T10:30:34.567Z"
  }
}
```

---

## **3. PROPERTY LISTING & BROWSING**

### **Get All Properties (with filtering)**

**Request - Get all properties:**
```bash
curl -X GET "http://localhost:3000/api/properties?page=1&limit=10"
```

**Request - Filter by city and category:**
```bash
curl -X GET "http://localhost:3000/api/properties?city=Bangalore&category=house&page=1&limit=10"
```

**Request - Get properties in a specific status:**
```bash
curl -X GET "http://localhost:3000/api/properties?status=live&page=1&limit=10"
```

**Expected Response (200 OK):**
```json
{
  "data": [
    {
      "id": "1",
      "title": "Modern Villa in Bangalore",
      "description": "Beautiful 3BHK villa with garden",
      "category": "house",
      "city": "Bangalore",
      "locality": "Whitefield",
      "area_sqft": 2500,
      "price": 80000000,
      "ownership_type": "freehold",
      "status": "live",
      "verified_badge": true,
      "verified_at": "2026-04-05T08:00:00.000Z",
      "seller_id": "2"
    },
    {
      "id": "2",
      "title": "Commercial Space Downtown",
      "description": "Prime location office space",
      "category": "commercial",
      "city": "Mumbai",
      "locality": "Bandra",
      "area_sqft": 5000,
      "price": 150000000,
      "ownership_type": "leasehold",
      "status": "live",
      "verified_badge": true,
      "verified_at": "2026-04-04T08:00:00.000Z",
      "seller_id": "3"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 3,
    "pages": 1
  }
}
```

### **Get Specific Property Details**

**Request:**
```bash
curl -X GET http://localhost:3000/api/properties/1
```

**Expected Response (200 OK):**
```json
{
  "data": {
    "id": "1",
    "title": "Modern Villa in Bangalore",
    "description": "Beautiful 3BHK villa with garden",
    "category": "house",
    "city": "Bangalore",
    "locality": "Whitefield",
    "area_sqft": 2500,
    "price": 80000000,
    "ownership_type": "freehold",
    "status": "live",
    "verified_badge": true,
    "verified_at": "2026-04-05T08:00:00.000Z",
    "seller_id": "2"
  }
}
```

---

## **4. CREATE PROPERTY LISTING (Seller)**

**Request:**
```bash
curl -X POST http://localhost:3000/api/properties \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -d '{
    "title": "Luxury Apartment in Delhi",
    "description": "4BHK premium apartment with modern amenities",
    "category": "house",
    "city": "Delhi",
    "locality": "Sector 44",
    "area_sqft": 3200,
    "price": 95000000,
    "ownership_type": "freehold"
  }'
```

**Expected Response (201 Created):**
```json
{
  "message": "Property submitted for verification",
  "data": {
    "id": "prop_1712500567890",
    "title": "Luxury Apartment in Delhi",
    "description": "4BHK premium apartment with modern amenities",
    "category": "house",
    "city": "Delhi",
    "locality": "Sector 44",
    "area_sqft": 3200,
    "price": 95000000,
    "ownership_type": "freehold",
    "status": "submitted",
    "verified_badge": false,
    "seller_id": "+919876543210",
    "created_at": "2026-04-07T11:15:67.890Z"
  }
}
```

---

## **5. DEALS MANAGEMENT**

### **Get All Deals**

**Request:**
```bash
curl -X GET "http://localhost:3000/api/deals?page=1&limit=20"
```

**Request - Filter by status:**
```bash
curl -X GET "http://localhost:3000/api/deals?status=closed&page=1&limit=20"
```

**Expected Response (200 OK):**
```json
{
  "data": [
    {
      "id": "1",
      "buyer_user_id": "1",
      "seller_user_id": "2",
      "property_id": "1",
      "status": "closed",
      "payment_status": "completed",
      "transaction_value": 80000000,
      "deal_closed_at": "2026-04-06T15:30:00.000Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 1
  }
}
```

### **Create New Deal (Admin)**

**Request:**
```bash
curl -X POST http://localhost:3000/api/deals \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -d '{
    "buyer_user_id": "5",
    "seller_user_id": "3",
    "property_id": "2",
    "transaction_value": 150000000
  }'
```

**Expected Response (201 Created):**
```json
{
  "message": "Deal created successfully",
  "data": {
    "id": "deal_1712500890123",
    "buyer_user_id": "5",
    "seller_user_id": "3",
    "property_id": "2",
    "status": "open",
    "payment_status": "pending",
    "transaction_value": 150000000,
    "created_at": "2026-04-07T12:00:00.000Z"
  }
}
```

### **Close Deal (Calculate Commissions)**

**Request:**
```bash
curl -X POST http://localhost:3000/api/deals/1/close \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Expected Response (200 OK):**
```json
{
  "message": "Deal closed successfully",
  "data": {
    "id": "1",
    "buyer_user_id": "1",
    "seller_user_id": "2",
    "property_id": "1",
    "status": "closed",
    "payment_status": "completed",
    "transaction_value": 80000000,
    "deal_closed_at": "2026-04-07T12:30:00.000Z"
  },
  "commissions": [
    {
      "id": "comm_1712500890123_buyer",
      "deal_id": "1",
      "commission_type": "buyer",
      "amount": 1600000,
      "percentage_applied": 2,
      "status": "pending"
    },
    {
      "id": "comm_1712500890124_seller",
      "deal_id": "1",
      "commission_type": "seller",
      "amount": 1600000,
      "percentage_applied": 2,
      "status": "pending"
    }
  ]
}
```

**Commission Breakdown:**
- Transaction: ₹80,000,000
- Buyer Commission (2%): ₹1,600,000
- Seller Commission (2%): ₹1,600,000
- **Total Commissions:** ₹3,200,000

---

## **6. COMMISSIONS & LEDGER**

### **Get Commission Ledger**

**Request:**
```bash
curl -X GET "http://localhost:3000/api/commissions/ledger?page=1&limit=50"
```

**Request - Filter by status:**
```bash
curl -X GET "http://localhost:3000/api/commissions/ledger?status=paid&type=buyer&page=1&limit=50"
```

**Expected Response (200 OK):**
```json
{
  "data": [
    {
      "id": "1",
      "deal_id": "1",
      "commission_type": "buyer",
      "amount": 1600000,
      "percentage_applied": 2,
      "status": "paid",
      "payment_date": "2026-04-07T10:00:00.000Z"
    },
    {
      "id": "2",
      "deal_id": "1",
      "commission_type": "seller",
      "amount": 1600000,
      "percentage_applied": 2,
      "status": "paid",
      "payment_date": "2026-04-07T10:00:00.000Z"
    }
  ],
  "summary": {
    "total_commissions": 3200000,
    "pending": 0,
    "paid": 3200000
  },
  "pagination": {
    "page": 1,
    "limit": 50,
    "total": 2
  }
}
```

---

## **7. ADMIN DASHBOARD**

### **Get Dashboard Stats & KPIs**

**Request:**
```bash
curl -X GET http://localhost:3000/api/admin/dashboard \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Expected Response (200 OK):**
```json
{
  "data": {
    "total_deals": 1,
    "total_commissions": 2,
    "pending_verifications": 1,
    "active_agents": 5,
    "total_commission_value": 3200000,
    "pending_commission_value": 0
  }
}
```

**Dashboard KPIs:**
- **Total Deals Closed:** 1
- **Commission Transactions:** 2
- **Properties Pending Verification:** 1
- **Active Agents/Partners:** 5
- **Total Commissions:** ₹32,00,000
- **Pending Payments:** ₹0 (all paid)

### **Verify Property (Admin)**

**Request - Approve property:**
```bash
curl -X POST http://localhost:3000/api/admin/properties/prop_1712500567890/verify \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -d '{
    "approved": true,
    "notes": "Property documents verified. Location confirmed."
  }'
```

**Expected Response (200 OK):**
```json
{
  "message": "Property verified",
  "data": {
    "id": "prop_1712500567890",
    "title": "Luxury Apartment in Delhi",
    "description": "4BHK premium apartment with modern amenities",
    "category": "house",
    "city": "Delhi",
    "locality": "Sector 44",
    "area_sqft": 3200,
    "price": 95000000,
    "ownership_type": "freehold",
    "status": "verified",
    "verified_badge": true,
    "verified_at": "2026-04-07T13:45:00.000Z",
    "seller_id": "+919876543210"
  }
}
```

**Request - Reject property:**
```bash
curl -X POST http://localhost:3000/api/admin/properties/prop_1712500567890/verify \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -d '{
    "approved": false,
    "notes": "Document mismatch. Please resubmit with correct ownership proof."
  }'
```

**Expected Response (200 OK):**
```json
{
  "message": "Property rejected",
  "data": {
    "id": "prop_1712500567890",
    "title": "Luxury Apartment in Delhi",
    "status": "rejected",
    "verified_badge": false
  }
}
```

---

## **8. HEALTH CHECK**

**Request:**
```bash
curl -X GET http://localhost:3000/health
```

**Expected Response (200 OK):**
```json
{
  "status": "ok",
  "service": "ClearDeed Backend API",
  "version": "1.0.0",
  "timestamp": "2026-04-07T14:00:00.000Z"
}
```

---

## **📝 Testing Checklist**

- [ ] Send OTP to phone number
- [ ] Verify OTP and get token
- [ ] Create user profile with all modes (buyer/seller/investor)
- [ ] Browse all properties
- [ ] Filter properties by city, category, status
- [ ] Get property details
- [ ] Create new property listing (as seller)
- [ ] View all deals
- [ ] Create new deal (as admin)
- [ ] Close deal and verify commission calculation
- [ ] Get commission ledger
- [ ] View admin dashboard KPIs
- [ ] Approve property verification
- [ ] Reject property and check status

---

## **🔑 Important Notes**

1. **OTP in Response:** In demo mode, the generated OTP is included in the response (`demo_otp` field). Use it immediately.

2. **Token Format:** Always include `Authorization: Bearer <token>` header for authenticated endpoints.

3. **Timestamps:** All dates are in ISO 8601 format (UTC).

4. **Pagination:** Default limit is 20. Use `?limit=50` for more results.

5. **Rate Limiting:** Demo allows unlimited requests. Production will have rate limits.

6. **Commission Calculation:**
   - Buyer: 2% of transaction value
   - Seller: 2% of transaction value
   - Referral Partner: 1% (when applicable)
   - Platform: 1% (when applicable)

---

## **🚀 Quick Test Script**

Save this as `test-api.sh` and run `bash test-api.sh`:

```bash
#!/bin/bash

BASE_URL="http://localhost:3000"
MOBILE="+919876543210"

echo "🧪 Testing ClearDeed API..."

# 1. Health Check
echo "\n✅ Health Check:"
curl -s $BASE_URL/health | jq '.'

# 2. Send OTP
echo "\n✅ Send OTP:"
OTP_RESPONSE=$(curl -s -X POST $BASE_URL/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d "{\"mobile\": \"$MOBILE\"}")
echo $OTP_RESPONSE | jq '.'
OTP=$(echo $OTP_RESPONSE | jq -r '.demo_otp')

# 3. Verify OTP
echo "\n✅ Verify OTP:"
TOKEN_RESPONSE=$(curl -s -X POST $BASE_URL/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d "{\"mobile\": \"$MOBILE\", \"otp\": \"$OTP\"}")
echo $TOKEN_RESPONSE | jq '.'
TOKEN=$(echo $TOKEN_RESPONSE | jq -r '.token')

# 4. Get Properties
echo "\n✅ Get Properties:"
curl -s "$BASE_URL/api/properties?page=1&limit=2" | jq '.'

# 5. Get Dashboard Stats
echo "\n✅ Admin Dashboard:"
curl -s -X GET $BASE_URL/api/admin/dashboard \
  -H "Authorization: Bearer $TOKEN" | jq '.'

echo "\n✨ Test complete!"
```

---

**Ready to practice? Start with OTP authentication flow!** 🚀
