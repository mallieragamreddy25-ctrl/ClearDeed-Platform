/**
 * Notification Configuration
 * Configuration for SMS, Email, and other notification channels
 */

/**
 * Twilio SMS Configuration
 */
export const twilioConfig = {
  accountSid: process.env.TWILIO_ACCOUNT_SID || '',
  authToken: process.env.TWILIO_AUTH_TOKEN || '',
  phoneNumber: process.env.TWILIO_PHONE_NUMBER || '',
  
  // SMS settings
  maxRetries: 3,
  retryDelay: 1000,
  timeout: 30000,
  
  // Enable/disable
  enabled: process.env.TWILIO_ENABLED !== 'false',
  
  // Fallback to console in development
  mockMode: process.env.NODE_ENV !== 'production' && process.env.NOTIFICATION_MOCK !== 'false',
};

/**
 * Email Configuration (SMTP)
 */
export const emailConfig = {
  host: process.env.SMTP_HOST || 'smtp.gmail.com',
  port: parseInt(process.env.SMTP_PORT || '587'),
  secure: process.env.SMTP_SECURE === 'true', // true for 465, false for other ports
  auth: {
    user: process.env.SMTP_USER || '',
    pass: process.env.SMTP_PASS || '',
  },
  from: process.env.SMTP_FROM || 'noreply@cleardeed.com',
  fromName: 'ClearDeed',
  
  // Email settings
  maxRetries: 3,
  retryDelay: 2000,
  timeout: 30000,
  
  // Enable/disable
  enabled: process.env.EMAIL_ENABLED === 'true',
  
  // Templates
  templatesDir: process.env.EMAIL_TEMPLATES_DIR || 'src/templates/emails',
};

/**
 * WhatsApp Configuration
 */
export const whatsappConfig = {
  accountSid: process.env.TWILIO_ACCOUNT_SID || '',
  authToken: process.env.TWILIO_AUTH_TOKEN || '',
  phoneNumber: process.env.TWILIO_WHATSAPP_NUMBER || 'whatsapp:+14155552671',
  
  // WhatsApp settings
  maxRetries: 2,
  retryDelay: 1000,
  timeout: 30000,
  
  // Enable/disable
  enabled: process.env.WHATSAPP_ENABLED === 'true',
  
  // Fallback to SMS if failed
  fallbackToSms: true,
};

/**
 * Push Notification Configuration
 */
export const pushNotificationConfig = {
  // Firebase Cloud Messaging
  fcm: {
    serverKey: process.env.FCM_SERVER_KEY || '',
    senderId: process.env.FCM_SENDER_ID || '',
    enabled: process.env.FCM_ENABLED === 'true',
  },
  
  // Settings
  maxRetries: 2,
  retryDelay: 1000,
  timeout: 15000,
};

/**
 * Notification Channels Priority
 * Order of channels to try if previous fails
 */
export const notificationChannelsPriority = {
  otp: ['sms', 'whatsapp'], // SMS primary, WhatsApp fallback
  deal_created: ['sms', 'email', 'push'],
  deal_closed: ['email', 'sms', 'push'],
  commission_recorded: ['email', 'sms'],
  referral_approved: ['email', 'sms', 'push'],
  verification_complete: ['email', 'push'],
  general: ['sms', 'email', 'push'],
};

/**
 * Notification Template Configuration
 */
export const notificationTemplates = {
  otp: {
    sms: 'OTP Verification',
    subject: 'Your ClearDeed OTP Code',
  },
  deal_created: {
    sms: 'New Deal Created',
    subject: 'New Deal Created - Action Required',
  },
  deal_closed: {
    sms: 'Deal Closed Successfully',
    subject: 'Congratulations! Your Deal is Closed',
  },
  commission_recorded: {
    sms: 'Commission Recorded',
    subject: 'Commission Added to Your Account',
  },
  referral_approved: {
    sms: 'Referral Partner Approved',
    subject: 'Welcome to ClearDeed Referral Partners',
  },
  verification_complete: {
    sms: 'Verification Complete',
    subject: 'Your Profile is Verified',
  },
};

/**
 * Notification Queue Configuration
 */
export const notificationQueueConfig = {
  // Queue system (can be 'memory', 'bull', 'bullmq')
  system: (process.env.NOTIFICATION_QUEUE_SYSTEM || 'memory') as 'memory' | 'bull' | 'bullmq',
  
  // Queue settings
  maxAttempts: 5,
  backoffDelay: 60000, // 1 minute
  timeout: 300000, // 5 minutes
  
  // Redis config (for bull/bullmq)
  redis: {
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT || '6379'),
    db: parseInt(process.env.REDIS_DB || '0'),
    password: process.env.REDIS_PASSWORD,
  },
};

/**
 * Notification Logging Configuration
 */
export const notificationLogging = {
  logSentMessages: process.env.NODE_ENV !== 'production' || process.env.NOTIFICATION_LOG_ALL === 'true',
  logFailedMessages: true,
  logAttempts: true,
  retentionDays: 30,
};

/**
 * Notification Batch Configuration
 */
export const notificationBatchConfig = {
  // Batch size for sending notifications
  batchSize: parseInt(process.env.NOTIFICATION_BATCH_SIZE || '100'),
  
  // Batch interval in milliseconds
  batchInterval: parseInt(process.env.NOTIFICATION_BATCH_INTERVAL || '5000'),
  
  // Max concurrent sends
  maxConcurrent: parseInt(process.env.NOTIFICATION_MAX_CONCURRENT || '10'),
};
