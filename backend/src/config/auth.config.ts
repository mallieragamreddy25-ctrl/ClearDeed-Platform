/**
 * Authentication Configuration
 * Centralized configuration for JWT, OTP, and security settings
 */

/**
 * JWT Configuration
 */
export const jwtConfig = {
  secret: process.env.JWT_SECRET || 'your-secret-key-change-in-production',
  expiresIn: process.env.JWT_EXPIRES_IN || '24h',
  refreshSecret: process.env.JWT_REFRESH_SECRET || 'refresh-secret-key',
  refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
  issuer: 'cleardeed-api',
  audience: 'cleardeed-client',
};

/**
 * OTP Configuration
 */
export const otpConfig = {
  // OTP validity in minutes
  validity: parseInt(process.env.OTP_VALIDITY || '5'),
  
  // Maximum attempts before account lockout
  maxAttempts: parseInt(process.env.OTP_MAX_ATTEMPTS || '5'),
  
  // Lockout duration in minutes
  lockoutDuration: parseInt(process.env.OTP_LOCKOUT_DURATION || '15'),
  
  // OTP length
  length: parseInt(process.env.OTP_LENGTH || '6'),
  
  // OTP type: 'numeric', 'alphanumeric'
  type: (process.env.OTP_TYPE || 'numeric') as 'numeric' | 'alphanumeric',
  
  // Allow resend after (seconds)
  resendDelay: parseInt(process.env.OTP_RESEND_DELAY || '30'),
  
  // Maximum resend attempts per hour
  maxResendAttempts: parseInt(process.env.OTP_MAX_RESEND_ATTEMPTS || '5'),
};

/**
 * Password Configuration
 */
export const passwordConfig = {
  // Bcrypt salt rounds
  saltRounds: parseInt(process.env.BCRYPT_SALT_ROUNDS || '10'),
  
  // Password requirements
  minLength: 8,
  requireUppercase: true,
  requireLowercase: true,
  requireNumbers: true,
  requireSpecialChars: true,
};

/**
 * Rate Limiting Configuration
 */
export const rateLimitConfig = {
  // Global rate limit
  windowMs: 15 * 60 * 1000, // 15 minutes
  maxRequests: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'),
  
  // OTP endpoint limits
  otpWindowMs: 1 * 60 * 1000, // 1 minute
  otpMaxRequests: parseInt(process.env.OTP_RATE_LIMIT || '5'),
  
  // Login endpoint limits
  loginWindowMs: 15 * 60 * 1000, // 15 minutes
  loginMaxRequests: parseInt(process.env.LOGIN_RATE_LIMIT || '10'),
  
  // API endpoint limits
  apiWindowMs: 1 * 60 * 1000, // 1 minute
  apiMaxRequests: parseInt(process.env.API_RATE_LIMIT || '300'),
};

/**
 * CORS Configuration
 */
export const corsConfig = {
  origin: (process.env.CORS_ORIGIN || 'http://localhost:3000,http://localhost:3001').split(','),
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  exposedHeaders: ['X-Total-Count', 'X-Page-Count'],
  maxAge: 86400, // 24 hours
};

/**
 * Session Configuration
 */
export const sessionConfig = {
  timeout: 24 * 60 * 60 * 1000, // 24 hours
  refreshThreshold: 1 * 60 * 60 * 1000, // Refresh if expires in 1 hour
  secure: process.env.NODE_ENV === 'production',
  httpOnly: true,
  sameSite: 'strict' as const,
};

/**
 * Token Validation Helpers
 */
export const tokenValidation = {
  algorithm: 'HS256',
  tokenType: 'Bearer',
};

/**
 * Security Headers Configuration
 */
export const securityHeadersConfig = {
  'X-Content-Type-Options': 'nosniff',
  'X-Frame-Options': 'DENY',
  'X-XSS-Protection': '1; mode=block',
  'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
  'Content-Security-Policy': "default-src 'self'",
};
