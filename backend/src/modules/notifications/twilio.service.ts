/**
 * Twilio Service
 * 
 * Handles SMS and WhatsApp message delivery via Twilio
 */

import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ITwilioResponse } from './notifications.interface';

// Check if Twilio is available, otherwise use a stub
let twilio: any;
try {
  twilio = require('twilio');
} catch (e) {
  Logger.warn('Twilio package not installed. SMS/WhatsApp delivery will be mocked.');
}

/**
 * Twilio Service
 * 
 * Integrates with Twilio for:
 * - SMS delivery
 * - WhatsApp messaging
 */
@Injectable()
export class TwilioService {
  private readonly logger = new Logger(TwilioService.name);
  private twilioClient: any;
  private accountSid: string;
  private authToken: string;
  private fromPhone: string;
  private fromWhatsApp: string;
  private mockMode: boolean = false;

  constructor(private configService: ConfigService) {
    this.accountSid = this.configService.get<string>('TWILIO_ACCOUNT_SID', 'AC1234567890');
    this.authToken = this.configService.get<string>('TWILIO_AUTH_TOKEN', 'auth_token');
    this.fromPhone = this.configService.get<string>('TWILIO_PHONE', '+1234567890');
    this.fromWhatsApp = this.configService.get<string>('TWILIO_WHATSAPP', 'whatsapp:+1234567890');
    this.mockMode = this.configService.get<string>('NODE_ENV') !== 'production';

    // Initialize Twilio client in production
    if (twilio && this.accountSid && this.authToken) {
      try {
        this.twilioClient = twilio(this.accountSid, this.authToken);
        this.logger.log('Twilio client initialized');
      } catch (error) {
        this.logger.error('Failed to initialize Twilio client', error);
        this.mockMode = true;
      }
    } else {
      this.logger.warn('Twilio not configured or package not installed. Using mock mode.');
      this.mockMode = true;
    }
  }

  /**
   * Send SMS via Twilio
   * 
   * @param toPhone - Recipient phone number
   * @param message - Message content
   * @returns Twilio response with SID
   */
  async sendSms(toPhone: string, message: string): Promise<ITwilioResponse> {
    try {
      // Normalize phone number
      const normalizedPhone = this.normalizePhoneNumber(toPhone);

      if (this.mockMode) {
        this.logger.log(`[MOCK] SMS to ${normalizedPhone}: ${message}`);
        return {
          success: true,
          sid: `SM_MOCK_${Date.now()}`,
          status: 'queued',
        };
      }

      if (!this.twilioClient) {
        throw new Error('Twilio client not initialized');
      }

      const messageResponse = await this.twilioClient.messages.create({
        body: message,
        from: this.fromPhone,
        to: normalizedPhone,
      });

      this.logger.log(`SMS sent successfully. SID: ${messageResponse.sid}`);

      return {
        success: true,
        sid: messageResponse.sid,
        status: messageResponse.status,
      };
    } catch (error) {
      this.logger.error(`Failed to send SMS: ${error.message}`, error);
      return {
        success: false,
        status: 'failed',
        error: error.message,
      };
    }
  }

  /**
   * Send WhatsApp message via Twilio
   * 
   * @param toPhone - Recipient WhatsApp number
   * @param message - Message content
   * @param mediaUrl - Optional media URL
   * @returns Twilio response with SID
   */
  async sendWhatsApp(
    toPhone: string,
    message: string,
    mediaUrl?: string,
  ): Promise<ITwilioResponse> {
    try {
      const normalizedPhone = `whatsapp:${this.normalizePhoneNumber(toPhone)}`;

      if (this.mockMode) {
        this.logger.log(
          `[MOCK] WhatsApp to ${normalizedPhone}: ${message}${mediaUrl ? ` (Media: ${mediaUrl})` : ''}`,
        );
        return {
          success: true,
          sid: `WA_MOCK_${Date.now()}`,
          status: 'queued',
        };
      }

      if (!this.twilioClient) {
        throw new Error('Twilio client not initialized');
      }

      const messagePayload: any = {
        body: message,
        from: this.fromWhatsApp,
        to: normalizedPhone,
      };

      if (mediaUrl) {
        messagePayload.mediaUrl = [mediaUrl];
      }

      const messageResponse = await this.twilioClient.messages.create(messagePayload);

      this.logger.log(`WhatsApp message sent successfully. SID: ${messageResponse.sid}`);

      return {
        success: true,
        sid: messageResponse.sid,
        status: messageResponse.status,
      };
    } catch (error) {
      this.logger.error(`Failed to send WhatsApp: ${error.message}`, error);
      return {
        success: false,
        status: 'failed',
        error: error.message,
      };
    }
  }

  /**
   * Get message status from Twilio
   * 
   * @param messageSid - Twilio Message SID
   * @returns Message status
   */
  async getMessageStatus(messageSid: string): Promise<string> {
    try {
      if (this.mockMode) {
        return 'delivered';
      }

      if (!this.twilioClient) {
        throw new Error('Twilio client not initialized');
      }

      const message = await this.twilioClient.messages(messageSid).fetch();
      return message.status;
    } catch (error) {
      this.logger.error(`Failed to fetch message status: ${error.message}`, error);
      return 'unknown';
    }
  }

  /**
   * Normalize phone number to E.164 format
   * Handles: +91XXXXXXXXXX, 91XXXXXXXXXX, 0XXXXXXXXXX, XXXXXXXXXX
   * 
   * @param phone - Phone number to normalize
   * @returns Normalized phone number in E.164 format
   */
  private normalizePhoneNumber(phone: string): string {
    // Remove all non-digit characters
    const digitsOnly = phone.replace(/\D/g, '');

    // If already has country code (91 for India)
    if (digitsOnly.startsWith('91') && digitsOnly.length === 12) {
      return `+${digitsOnly}`;
    }

    // If starts with 0, remove it and add country code
    if (digitsOnly.startsWith('0') && digitsOnly.length === 10) {
      return `+91${digitsOnly.substring(1)}`;
    }

    // If it's just 10 digits
    if (digitsOnly.length === 10) {
      return `+91${digitsOnly}`;
    }

    // Return as-is with + prefix if not already present
    return phone.startsWith('+') ? phone : `+${digitsOnly}`;
  }

  /**
   * Validate phone number
   * 
   * @param phone - Phone number to validate
   * @returns True if valid, false otherwise
   */
  validatePhoneNumber(phone: string): boolean {
    const normalized = this.normalizePhoneNumber(phone);
    // Valid E.164 format: +[1-9]{1}[0-9]{1,14}
    return /^\+\d{1,15}$/.test(normalized);
  }

  /**
   * Check Twilio account balance (production only)
   * 
   * @returns Account balance in USD
   */
  async getAccountBalance(): Promise<number | null> {
    try {
      if (this.mockMode || !this.twilioClient) {
        return null;
      }

      const balance = await this.twilioClient.balance.fetch();
      return parseFloat(balance.balance);
    } catch (error) {
      this.logger.error(`Failed to fetch account balance: ${error.message}`, error);
      return null;
    }
  }

  /**
   * Health check for Twilio configuration
   */
  async healthCheck(): Promise<boolean> {
    try {
      if (this.mockMode) {
        this.logger.log('Twilio service running in mock mode');
        return true;
      }

      if (!this.twilioClient) {
        return false;
      }

      // Try to fetch account info
      const account = await this.twilioClient.api.accounts(this.accountSid).fetch();
      return account ? true : false;
    } catch (error) {
      this.logger.error(`Twilio health check failed: ${error.message}`);
      return false;
    }
  }
}
