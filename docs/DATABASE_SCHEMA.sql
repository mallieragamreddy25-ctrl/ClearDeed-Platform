-- ClearDeed Database Schema (PostgreSQL)
-- Created for MVP Phase 1

-- ======================= ENUMS =======================

CREATE TYPE user_role AS ENUM ('buyer', 'seller', 'investor');
CREATE TYPE property_category AS ENUM ('land', 'individual_house', 'commercial', 'agriculture');
CREATE TYPE property_status AS ENUM ('submitted', 'under_verification', 'verified', 'live', 'sold', 'rejected');
CREATE TYPE deal_status AS ENUM ('created', 'pending_verification', 'verified', 'active', 'closed');
CREATE TYPE referral_partner_type AS ENUM ('agent', 'verified_user');
CREATE TYPE commission_type AS ENUM ('buyer_fee', 'seller_fee', 'platform_fee', 'referral_fee');
CREATE TYPE verification_status AS ENUM ('pending', 'under_review', 'approved', 'rejected');

-- ======================= USERS =======================

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    mobile_number VARCHAR(20) UNIQUE NOT NULL,
    otp_hash VARCHAR(255),
    otp_created_at TIMESTAMP,
    otp_attempts INT DEFAULT 0,
    otp_locked_until TIMESTAMP,
    
    -- Profile info
    full_name VARCHAR(255),
    email VARCHAR(255) UNIQUE,
    city VARCHAR(100),
    profile_type user_role,
    budget_range VARCHAR(50), -- e.g., "50-100L", "1Cr-2Cr"
    net_worth_range VARCHAR(50),
    
    -- Referral
    referral_mobile_number VARCHAR(20),
    referral_validated BOOLEAN DEFAULT FALSE,
    referred_by_mobile VARCHAR(20), -- who referred this user
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Auth tokens
    last_login TIMESTAMP,
    session_token VARCHAR(255),
    token_expires_at TIMESTAMP
);

CREATE INDEX idx_users_mobile ON users(mobile_number);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_referral_mobile ON users(referral_mobile_number);

-- ======================= REFERRAL PARTNERS =======================

CREATE TABLE referral_partners (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE SET NULL,
    mobile_number VARCHAR(20) UNIQUE NOT NULL,
    
    partner_type referral_partner_type NOT NULL,
    full_name VARCHAR(255),
    email VARCHAR(255),
    city VARCHAR(100),
    
    -- Agent specific
    agent_license_number VARCHAR(100),
    agency_name VARCHAR(255),
    
    -- Status
    status VERIFICATION_STATUS DEFAULT 'pending',
    is_active BOOLEAN DEFAULT TRUE,
    yearly_maintenance_fee_status VARCHAR(50) DEFAULT 'unpaid', -- 'paid', 'unpaid', 'expired'
    maintenance_fee_renewal_date DATE,
    
    commission_enabled BOOLEAN DEFAULT FALSE,
    total_commission_earned DECIMAL(12, 2) DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_referral_partners_mobile ON referral_partners(mobile_number);
CREATE INDEX idx_referral_partners_user_id ON referral_partners(user_id);
CREATE INDEX idx_referral_partners_status ON referral_partners(status);

-- ======================= PROPERTIES =======================

CREATE TABLE properties (
    id SERIAL PRIMARY KEY,
    seller_user_id INT REFERENCES users(id) ON DELETE CASCADE,
    
    -- Details
    category property_category NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    location VARCHAR(255) NOT NULL,
    city VARCHAR(100),
    pincode VARCHAR(10),
    
    -- Pricing & Size
    price DECIMAL(15, 2),
    area DECIMAL(10, 2), -- in sq ft or sq m
    area_unit VARCHAR(10) DEFAULT 'sqft', -- 'sqft', 'sqm'
    
    -- Ownership
    ownership_status VARCHAR(100), -- 'owned', 'mortgaged', 'disputed'
    
    -- Status
    status property_status DEFAULT 'submitted',
    is_verified BOOLEAN DEFAULT FALSE,
    verified_badge BOOLEAN DEFAULT FALSE,
    
    -- Images & Documents
    primary_image_url TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    verified_at TIMESTAMP
);

CREATE INDEX idx_properties_seller_user_id ON properties(seller_user_id);
CREATE INDEX idx_properties_status ON properties(status);
CREATE INDEX idx_properties_city ON properties(city);
CREATE INDEX idx_properties_category ON properties(category);

-- ======================= PROPERTY VERIFICATION =======================

CREATE TABLE property_verifications (
    id SERIAL PRIMARY KEY,
    property_id INT REFERENCES properties(id) ON DELETE CASCADE,
    verified_by_admin_id INT REFERENCES users(id) ON DELETE SET NULL,
    
    verification_status verification_status DEFAULT 'pending',
    verified_documents TEXT[], -- array of document names
    verification_notes TEXT,
    rejection_reason TEXT,
    
    verified_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_property_verifications_property_id ON property_verifications(property_id);
CREATE INDEX idx_property_verifications_status ON property_verifications(verification_status);

-- ======================= PROPERTY DOCUMENTS =======================

CREATE TABLE property_documents (
    id SERIAL PRIMARY KEY,
    property_id INT REFERENCES properties(id) ON DELETE CASCADE,
    
    document_type VARCHAR(100), -- 'title_deed', 'survey', 'tax_proof', 'approval_letter'
    document_name VARCHAR(255),
    document_url TEXT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_property_documents_property_id ON property_documents(property_id);

-- ======================= PROPERTY GALLERY =======================

CREATE TABLE property_gallery (
    id SERIAL PRIMARY KEY,
    property_id INT REFERENCES properties(id) ON DELETE CASCADE,
    
    image_url TEXT NOT NULL,
    image_title VARCHAR(255),
    display_order INT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_property_gallery_property_id ON property_gallery(property_id);

-- ======================= PROJECTS (INVESTMENT) =======================

CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    admin_user_id INT REFERENCES users(id) ON DELETE SET NULL,
    
    title VARCHAR(255) NOT NULL,
    description TEXT,
    location VARCHAR(255),
    city VARCHAR(100),
    
    -- Financial
    capital_required DECIMAL(15, 2),
    minimum_investment DECIMAL(12, 2),
    roi_estimate DECIMAL(5, 2), -- percentage
    timeline_months INT,
    
    -- Status
    status property_status DEFAULT 'submitted',
    is_verified BOOLEAN DEFAULT FALSE,
    verified_badge BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    verified_at TIMESTAMP
);

CREATE INDEX idx_projects_admin_user_id ON projects(admin_user_id);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_projects_city ON projects(city);

-- ======================= EXPRESS INTEREST =======================

CREATE TABLE express_interests (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    
    -- Can be property or project
    property_id INT REFERENCES properties(id) ON DELETE CASCADE,
    project_id INT REFERENCES projects(id) ON DELETE CASCADE,
    
    user_role user_role, -- 'buyer', 'investor'
    
    interest_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE INDEX idx_express_interests_user_id ON express_interests(user_id);
CREATE INDEX idx_express_interests_property_id ON express_interests(property_id);
CREATE INDEX idx_express_interests_project_id ON express_interests(project_id);

-- ======================= DEALS =======================

CREATE TABLE deals (
    id SERIAL PRIMARY KEY,
    created_by_admin_id INT REFERENCES users(id) ON DELETE SET NULL,
    
    -- Parties
    buyer_user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    seller_user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Property/Project
    property_id INT REFERENCES properties(id) ON DELETE SET NULL,
    project_id INT REFERENCES projects(id) ON DELETE SET NULL,
    
    -- Status
    status deal_status DEFAULT 'created',
    deal_closed_at TIMESTAMP,
    
    -- Metadata
    transaction_value DECIMAL(15, 2),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_deals_buyer_user_id ON deals(buyer_user_id);
CREATE INDEX idx_deals_seller_user_id ON deals(seller_user_id);
CREATE INDEX idx_deals_property_id ON deals(property_id);
CREATE INDEX idx_deals_status ON deals(status);

-- ======================= REFERRAL MAPPING (DEAL REFERRALS) =======================

CREATE TABLE deal_referral_mappings (
    id SERIAL PRIMARY KEY,
    deal_id INT REFERENCES deals(id) ON DELETE CASCADE,
    referral_partner_id INT REFERENCES referral_partners(id) ON DELETE CASCADE,
    
    side VARCHAR(10), -- 'buyer', 'seller'
    commission_percentage DECIMAL(5, 2),
    commission_locked_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_deal_referral_mappings_deal_id ON deal_referral_mappings(deal_id);
CREATE INDEX idx_deal_referral_mappings_referral_partner_id ON deal_referral_mappings(referral_partner_id);

-- ======================= COMMISSION LEDGER =======================

CREATE TABLE commission_ledgers (
    id SERIAL PRIMARY KEY,
    deal_id INT REFERENCES deals(id) ON DELETE CASCADE,
    referral_partner_id INT REFERENCES referral_partners(id) ON DELETE SET NULL,
    
    commission_type commission_type NOT NULL,
    amount DECIMAL(12, 2),
    percentage_applied DECIMAL(5, 2),
    
    status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'approved', 'paid'
    payment_date TIMESTAMP,
    payment_reference VARCHAR(255),
    
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_commission_ledgers_deal_id ON commission_ledgers(deal_id);
CREATE INDEX idx_commission_ledgers_referral_partner_id ON commission_ledgers(referral_partner_id);
CREATE INDEX idx_commission_ledgers_status ON commission_ledgers(status);

-- ======================= AGENT MAINTENANCE =======================

CREATE TABLE agent_maintenance (
    id SERIAL PRIMARY KEY,
    referral_partner_id INT REFERENCES referral_partners(id) ON DELETE CASCADE,
    
    fee_amount DECIMAL(10, 2) DEFAULT 999,
    payment_date TIMESTAMP,
    payment_reference VARCHAR(255),
    fee_expiry_date DATE,
    
    is_active BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_agent_maintenance_referral_partner_id ON agent_maintenance(referral_partner_id);
CREATE INDEX idx_agent_maintenance_is_active ON agent_maintenance(is_active);

-- ======================= NOTIFICATIONS =======================

CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    
    notification_type VARCHAR(100), -- 'verification_complete', 'deal_started', 'deal_closed', 'commission_recorded'
    title VARCHAR(255),
    body TEXT,
    
    channel VARCHAR(50) DEFAULT 'sms', -- 'sms', 'whatsapp', 'push'
    recipient_mobile VARCHAR(20),
    recipient_email VARCHAR(255),
    
    sent_at TIMESTAMP,
    delivery_status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'sent', 'failed'
    delivery_attempts INT DEFAULT 0,
    last_attempt_at TIMESTAMP,
    
    related_deal_id INT REFERENCES deals(id) ON DELETE SET NULL,
    related_property_id INT REFERENCES properties(id) ON DELETE SET NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_delivery_status ON notifications(delivery_status);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);

-- ======================= ADMIN ACTIVITY LOG =======================

CREATE TABLE admin_activity_logs (
    id SERIAL PRIMARY KEY,
    admin_user_id INT REFERENCES users(id) ON DELETE SET NULL,
    
    action_type VARCHAR(100), -- 'verify_property', 'create_deal', 'close_deal', 'approve_referral'
    related_entity_type VARCHAR(100), -- 'property', 'deal', 'referral_partner'
    related_entity_id INT,
    
    action_details JSONB,
    ip_address VARCHAR(45),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_admin_activity_logs_admin_user_id ON admin_activity_logs(admin_user_id);
CREATE INDEX idx_admin_activity_logs_created_at ON admin_activity_logs(created_at);

-- ======================= CONSTRAINTS & TRIGGERS =======================

-- Ensure deal has either property or project
ALTER TABLE deals 
ADD CONSTRAINT check_deal_has_property_or_project 
CHECK ((property_id IS NOT NULL AND project_id IS NULL) OR (property_id IS NULL AND project_id IS NOT NULL));

-- Ensure express interest has either property or project
ALTER TABLE express_interests 
ADD CONSTRAINT check_interest_has_property_or_project 
CHECK ((property_id IS NOT NULL AND project_id IS NULL) OR (property_id IS NULL AND project_id IS NOT NULL));

-- Update timestamp trigger
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to all tables with updated_at
CREATE TRIGGER trigger_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER trigger_referral_partners_updated_at BEFORE UPDATE ON referral_partners FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER trigger_properties_updated_at BEFORE UPDATE ON properties FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER trigger_deals_updated_at BEFORE UPDATE ON deals FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER trigger_commission_ledgers_updated_at BEFORE UPDATE ON commission_ledgers FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- ======================= INITIAL DATA =======================

-- Add admin user (manually manage initially)
-- INSERT INTO users (mobile_number, full_name, email, is_active, is_verified) 
-- VALUES ('+919999999999', 'Admin User', 'admin@cleardeed.com', TRUE, TRUE);
