/**
 * ClearDeed Backend - Mock API Server
 * Demonstrates the full API specification with mock data
 * Production code will use NestJS with proper database integration
 */

const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');

const app = express();
app.use(cors());
app.use(express.json());

// Configuration
const PORT = 3000;
const JWT_SECRET = 'your-secret-key-change-in-production';
const OTP_STORE = new Map(); // Store OTPs in memory (demo only)
const USERS_STORE = new Map(); // Store users in memory (demo only)

// Mock data
const PROPERTIES = [
  {
    id: '1',
    title: 'Modern Villa in Bangalore',
    description: 'Beautiful 3BHK villa with garden',
    category: 'house',
    city: 'Bangalore',
    locality: 'Whitefield',
    area_sqft: 2500,
    price: 80000000,
    ownership_type: 'freehold',
    status: 'live',
    verified_badge: true,
    verified_at: new Date(),
    seller_id: '2',
  },
  {
    id: '2',
    title: 'Commercial Space Downtown',
    description: 'Prime location office space',
    category: 'commercial',
    city: 'Mumbai',
    locality: 'Bandra',
    area_sqft: 5000,
    price: 150000000,
    ownership_type: 'leasehold',
    status: 'live',
    verified_badge: true,
    verified_at: new Date(),
    seller_id: '3',
  },
  {
    id: '3',
    title: 'Agricultural Land Investment',
    description: 'High-yield agricultural land',
    category: 'agriculture',
    city: 'Pune',
    locality: 'Rural Area',
    area_sqft: 50000,
    price: 25000000,
    ownership_type: 'freehold',
    status: 'submitted',
    verified_badge: false,
    seller_id: '4',
  },
];

const DEALS = [
  {
    id: '1',
    buyer_user_id: '1',
    seller_user_id: '2',
    property_id: '1',
    status: 'closed',
    payment_status: 'completed',
    transaction_value: 80000000,
    deal_closed_at: new Date(),
  },
];

const COMMISSIONS = [
  {
    id: '1',
    deal_id: '1',
    commission_type: 'buyer',
    amount: 1600000,
    percentage_applied: 2,
    status: 'paid',
    payment_date: new Date(),
  },
  {
    id: '2',
    deal_id: '1',
    commission_type: 'seller',
    amount: 1600000,
    percentage_applied: 2,
    status: 'paid',
    payment_date: new Date(),
  },
];

// ============ AUTH ENDPOINTS ============

// Send OTP
app.post('/api/auth/send-otp', (req, res) => {
  const { mobile } = req.body;

  if (!mobile) {
    return res.status(400).json({ message: 'Mobile number required' });
  }

  // Generate 6-digit OTP
  const otp = Math.floor(100000 + Math.random() * 900000).toString();
  OTP_STORE.set(mobile, {
    code: otp,
    attempts: 0,
    expiresAt: Date.now() + 10 * 60 * 1000, // 10 minutes
  });

  res.json({
    message: `OTP sent to ${mobile}`,
    expiresIn: 600, // seconds
    // In production, Twilio would send SMS here
    // For demo, log the OTP
    demo_otp: otp,
  });
});

// Verify OTP
app.post('/api/auth/verify-otp', (req, res) => {
  const { mobile, otp } = req.body;

  if (!mobile || !otp) {
    return res.status(400).json({ message: 'Mobile and OTP required' });
  }

  const storedOtp = OTP_STORE.get(mobile);

  if (!storedOtp) {
    return res.status(400).json({ message: 'OTP not found or expired' });
  }

  if (storedOtp.code !== otp) {
    storedOtp.attempts++;
    if (storedOtp.attempts >= 5) {
      OTP_STORE.delete(mobile);
      return res.status(429).json({ message: 'Too many attempts. Request new OTP' });
    }
    return res.status(400).json({ message: 'Invalid OTP' });
  }

  // OTP verified - create JWT token
  const token = jwt.sign({ mobile }, JWT_SECRET, { expiresIn: '24h' });
  OTP_STORE.delete(mobile);

  res.json({
    message: 'OTP verified successfully',
    token,
    expiresIn: 86400,
  });
});

// ============ USERS ENDPOINTS ============

// Create/Update Profile
app.post('/api/users/profile', authenticateToken, (req, res) => {
  const { name, city, profile_type, budget_range, referral_mobile } = req.body;
  const mobile = req.user.mobile;

  const user = {
    id: `user_${Date.now()}`,
    mobile,
    name,
    city,
    profile_type, // buyer, seller, investor, admin
    budget_range,
    referral_mobile_number: referral_mobile,
    is_verified: true,
    created_at: new Date(),
  };

  USERS_STORE.set(mobile, user);

  res.json({
    message: 'Profile created successfully',
    data: user,
  });
});

// Get Profile
app.get('/api/users/profile', authenticateToken, (req, res) => {
  const user = USERS_STORE.get(req.user.mobile);

  if (!user) {
    return res.status(404).json({ message: 'User not found' });
  }

  res.json({ data: user });
});

// ============ PROPERTIES ENDPOINTS ============

// List Properties
app.get('/api/properties', (req, res) => {
  const { category, city, status, page = 1, limit = 20 } = req.query;

  let filtered = PROPERTIES;

  if (category) filtered = filtered.filter(p => p.category === category);
  if (city) filtered = filtered.filter(p => p.city === city);
  if (status) filtered = filtered.filter(p => p.status === status);

  const start = (page - 1) * limit;
  const paginated = filtered.slice(start, start + limit);

  res.json({
    data: paginated,
    pagination: {
      page: parseInt(page),
      limit: parseInt(limit),
      total: filtered.length,
      pages: Math.ceil(filtered.length / limit),
    },
  });
});

// Get Property Details
app.get('/api/properties/:id', (req, res) => {
  const property = PROPERTIES.find(p => p.id === req.params.id);

  if (!property) {
    return res.status(404).json({ message: 'Property not found' });
  }

  res.json({ data: property });
});

// Create Property (Seller)
app.post('/api/properties', authenticateToken, (req, res) => {
  const {
    title,
    description,
    category,
    city,
    locality,
    area_sqft,
    price,
    ownership_type,
  } = req.body;

  const property = {
    id: `prop_${Date.now()}`,
    title,
    description,
    category,
    city,
    locality,
    area_sqft,
    price,
    ownership_type,
    status: 'submitted',
    verified_badge: false,
    seller_id: req.user.mobile,
    created_at: new Date(),
  };

  PROPERTIES.push(property);

  res.status(201).json({
    message: 'Property submitted for verification',
    data: property,
  });
});

// ============ DEALS ENDPOINTS ============

// List Deals
app.get('/api/deals', (req, res) => {
  const { status, page = 1, limit = 20 } = req.query;

  let filtered = DEALS;
  if (status) filtered = filtered.filter(d => d.status === status);

  const paginated = filtered.slice((page - 1) * limit, page * limit);

  res.json({
    data: paginated,
    pagination: {
      page: parseInt(page),
      limit: parseInt(limit),
      total: filtered.length,
    },
  });
});

// Create Deal (Admin)
app.post('/api/deals', authenticateToken, (req, res) => {
  const { buyer_user_id, seller_user_id, property_id, transaction_value } = req.body;

  const deal = {
    id: `deal_${Date.now()}`,
    buyer_user_id,
    seller_user_id,
    property_id,
    status: 'open',
    payment_status: 'pending',
    transaction_value,
    created_at: new Date(),
  };

  DEALS.push(deal);

  res.status(201).json({
    message: 'Deal created successfully',
    data: deal,
  });
});

// Close Deal
app.post('/api/deals/:id/close', authenticateToken, (req, res) => {
  const deal = DEALS.find(d => d.id === req.params.id);

  if (!deal) {
    return res.status(404).json({ message: 'Deal not found' });
  }

  deal.status = 'closed';
  deal.payment_status = 'completed';
  deal.deal_closed_at = new Date();

  // Calculate commissions
  const buyerCommission = {
    id: `comm_${Date.now()}_buyer`,
    deal_id: deal.id,
    commission_type: 'buyer',
    amount: deal.transaction_value * 0.02, // 2%
    percentage_applied: 2,
    status: 'pending',
  };

  const sellerCommission = {
    id: `comm_${Date.now()}_seller`,
    deal_id: deal.id,
    commission_type: 'seller',
    amount: deal.transaction_value * 0.02, // 2%
    percentage_applied: 2,
    status: 'pending',
  };

  COMMISSIONS.push(buyerCommission, sellerCommission);

  res.json({
    message: 'Deal closed successfully',
    data: deal,
    commissions: [buyerCommission, sellerCommission],
  });
});

// ============ COMMISSIONS ENDPOINTS ============

// List Commission Ledger
app.get('/api/commissions/ledger', (req, res) => {
  const { status, type, page = 1, limit = 50 } = req.query;

  let filtered = COMMISSIONS;

  if (status) filtered = filtered.filter(c => c.status === status);
  if (type) filtered = filtered.filter(c => c.commission_type === type);

  const paginated = filtered.slice((page - 1) * limit, page * limit);

  res.json({
    data: paginated,
    summary: {
      total_commissions: COMMISSIONS.reduce((sum, c) => sum + c.amount, 0),
      pending: COMMISSIONS.filter(c => c.status === 'pending').reduce((sum, c) => sum + c.amount, 0),
      paid: COMMISSIONS.filter(c => c.status === 'paid').reduce((sum, c) => sum + c.amount, 0),
    },
    pagination: {
      page: parseInt(page),
      limit: parseInt(limit),
      total: filtered.length,
    },
  });
});

// ============ ADMIN ENDPOINTS ============

// Get Dashboard Stats
app.get('/api/admin/dashboard', authenticateToken, (req, res) => {
  res.json({
    data: {
      total_deals: DEALS.length,
      total_commissions: COMMISSIONS.length,
      pending_verifications: PROPERTIES.filter(p => p.status === 'submitted').length,
      active_agents: 5,
      total_commission_value: COMMISSIONS.reduce((sum, c) => sum + c.amount, 0),
      pending_commission_value: COMMISSIONS.filter(c => c.status === 'pending').reduce(
        (sum, c) => sum + c.amount,
        0,
      ),
    },
  });
});

// Verify Property
app.post('/api/admin/properties/:id/verify', authenticateToken, (req, res) => {
  const { approved, notes } = req.body;
  const property = PROPERTIES.find(p => p.id === req.params.id);

  if (!property) {
    return res.status(404).json({ message: 'Property not found' });
  }

  if (approved) {
    property.status = 'verified';
    property.verified_badge = true;
    property.verified_at = new Date();
  } else {
    property.status = 'rejected';
  }

  res.json({
    message: approved ? 'Property verified' : 'Property rejected',
    data: property,
  });
});

// ============ MIDDLEWARE ============

function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer token

  if (!token) {
    return res.status(401).json({ message: 'No token provided' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      console.error('Token verification error:', err.message);
      return res.status(403).json({ message: 'Invalid token' });
    }
    req.user = user;
    next();
  });
}

// ============ HEALTH CHECK ============

app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'ClearDeed Backend API',
    version: '1.0.0',
    timestamp: new Date(),
  });
});

// ============ ERROR HANDLING ============

app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    message: 'Internal server error',
    error: process.env.NODE_ENV === 'production' ? undefined : err.message,
  });
});

// ============ START SERVER ============

app.listen(PORT, () => {
  console.log(`
🚀 ClearDeed Backend API - Mock Server
📍 Listening on http://localhost:${PORT}
🔗 Health check: GET http://localhost:${PORT}/health

📚 API Endpoints:
   Auth:
     - POST   /api/auth/send-otp
     - POST   /api/auth/verify-otp

   Users:
     - POST   /api/users/profile
     - GET    /api/users/profile

   Properties:
     - GET    /api/properties
     - GET    /api/properties/:id
     - POST   /api/properties

   Deals:
     - GET    /api/deals
     - POST   /api/deals
     - POST   /api/deals/:id/close

   Commissions:
     - GET    /api/commissions/ledger

   Admin:
     - GET    /api/admin/dashboard
     - POST   /api/admin/properties/:id/verify

✅ Ready for demo!
  `);
});

module.exports = app;
