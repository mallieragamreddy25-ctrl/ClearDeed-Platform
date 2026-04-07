/**
 * Notification Templates
 * 
 * Pre-defined templates for all notification types and channels
 * Supports variable substitution: {{variableName}}
 */

import { NotificationType, NotificationChannel, INotificationTemplate } from './notifications.interface';

/**
 * SMS Templates
 */
export const SMS_TEMPLATES: Record<NotificationType, INotificationTemplate> = {
  [NotificationType.PROPERTY_VERIFIED]: {
    type: NotificationType.PROPERTY_VERIFIED,
    channel: NotificationChannel.SMS,
    title: 'Property Verified',
    body: 'Hi {{userName}}, Your property "{{propertyTitle}}" has been verified on ClearDeed. It is now visible to buyers. Start receiving offers!',
    variables: ['userName', 'propertyTitle'],
  },
  [NotificationType.DEAL_CREATED]: {
    type: NotificationType.DEAL_CREATED,
    channel: NotificationChannel.SMS,
    title: 'New Deal Created',
    body: 'Hi {{userName}}, A new deal has been created for property "{{propertyTitle}}". Deal ID: {{dealId}}. Commission: {{commission}}',
    variables: ['userName', 'propertyTitle', 'dealId', 'commission'],
  },
  [NotificationType.DEAL_CLOSED]: {
    type: NotificationType.DEAL_CLOSED,
    channel: NotificationChannel.SMS,
    title: 'Deal Closed',
    body: 'Congratulations {{userName}}! Deal {{dealId}} is closed. Your commission of {{commission}} has been credited.',
    variables: ['userName', 'dealId', 'commission'],
  },
  [NotificationType.COMMISSION_CREDITED]: {
    type: NotificationType.COMMISSION_CREDITED,
    channel: NotificationChannel.SMS,
    title: 'Commission Credited',
    body: 'Your commission of ₹{{amount}} has been credited for deal {{dealId}}. Total balance: ₹{{totalBalance}}',
    variables: ['amount', 'dealId', 'totalBalance'],
  },
  [NotificationType.AGENT_ACCEPTED]: {
    type: NotificationType.AGENT_ACCEPTED,
    channel: NotificationChannel.SMS,
    title: 'Agent Accepted',
    body: 'Agent {{agentName}} has accepted to work on your deal. Deal ID: {{dealId}}. Contact: {{agentPhone}}',
    variables: ['agentName', 'dealId', 'agentPhone'],
  },
  [NotificationType.PROPERTY_REJECTED]: {
    type: NotificationType.PROPERTY_REJECTED,
    channel: NotificationChannel.SMS,
    title: 'Property Rejected',
    body: 'Hi {{userName}}, Your property "{{propertyTitle}}" was rejected. Reason: {{reason}}. Please resubmit with corrections.',
    variables: ['userName', 'propertyTitle', 'reason'],
  },
  [NotificationType.DEAL_UPDATED]: {
    type: NotificationType.DEAL_UPDATED,
    channel: NotificationChannel.SMS,
    title: 'Deal Updated',
    body: 'Deal {{dealId}} has been updated. Change: {{changeDescription}}. Review details on ClearDeed app.',
    variables: ['dealId', 'changeDescription'],
  },
};

/**
 * Email Templates
 */
export const EMAIL_TEMPLATES: Record<NotificationType, INotificationTemplate> = {
  [NotificationType.PROPERTY_VERIFIED]: {
    type: NotificationType.PROPERTY_VERIFIED,
    channel: NotificationChannel.EMAIL,
    subject: 'Property Verified on ClearDeed',
    title: 'Property Verified Successfully',
    body: `Dear {{userName}},

Your property "{{propertyTitle}}" has been verified and is now live on ClearDeed.

Property Details:
- Address: {{propertyAddress}}
- Category: {{propertyCategory}}
- Price: ₹{{propertyPrice}}

Your property is now visible to thousands of potential buyers. Start receiving offers and inquiries.

You can manage your property here: {{propertyLink}}

Best regards,
ClearDeed Team`,
    variables: ['userName', 'propertyTitle', 'propertyAddress', 'propertyCategory', 'propertyPrice', 'propertyLink'],
  },
  [NotificationType.DEAL_CREATED]: {
    type: NotificationType.DEAL_CREATED,
    channel: NotificationChannel.EMAIL,
    subject: 'New Deal Created - {{propertyTitle}}',
    title: 'A New Deal Has Been Created',
    body: `Dear {{userName}},

A new deal has been created involving your property "{{propertyTitle}}".

Deal Information:
- Deal ID: {{dealId}}
- Buyer: {{buyerName}}
- Seller: {{sellerName}}
- Property: {{propertyTitle}}
- Proposed Commission: {{commission}}
- Status: {{dealStatus}}

Review and manage this deal: {{dealLink}}

Best regards,
ClearDeed Team`,
    variables: ['userName', 'dealId', 'buyerName', 'sellerName', 'propertyTitle', 'commission', 'dealStatus', 'dealLink'],
  },
  [NotificationType.DEAL_CLOSED]: {
    type: NotificationType.DEAL_CLOSED,
    channel: NotificationChannel.EMAIL,
    subject: 'Congratulations! Deal {{dealId}} Closed',
    title: 'Deal Closed Successfully',
    body: `Dear {{userName}},

Congratulations! Deal {{dealId}} has been closed successfully.

Transaction Details:
- Property: {{propertyTitle}}
- Deal Amount: ₹{{dealAmount}}
- Your Commission: ₹{{commission}}
- Closed Date: {{closedDate}}

Your commission has been credited to your account. 

View transaction details: {{transactionLink}}

Thank you for using ClearDeed!

Best regards,
ClearDeed Team`,
    variables: ['userName', 'dealId', 'propertyTitle', 'dealAmount', 'commission', 'closedDate', 'transactionLink'],
  },
  [NotificationType.COMMISSION_CREDITED]: {
    type: NotificationType.COMMISSION_CREDITED,
    channel: NotificationChannel.EMAIL,
    subject: 'Commission Credited - ₹{{amount}}',
    title: 'Commission Has Been Credited',
    body: `Dear {{userName}},

A commission of ₹{{amount}} has been credited to your account for deal {{dealId}}.

Commission Breakdown:
- Deal: {{dealId}}
- Property: {{propertyTitle}}
- Amount: ₹{{amount}}
- Date: {{creditedDate}}
- New Balance: ₹{{totalBalance}}

View your commission ledger: {{ledgerLink}}

Best regards,
ClearDeed Team`,
    variables: ['userName', 'amount', 'dealId', 'propertyTitle', 'creditedDate', 'totalBalance', 'ledgerLink'],
  },
  [NotificationType.AGENT_ACCEPTED]: {
    type: NotificationType.AGENT_ACCEPTED,
    channel: NotificationChannel.EMAIL,
    subject: 'Agent {{agentName}} Accepted Your Deal',
    title: 'Agent Accepted Your Deal',
    body: `Dear {{userName}},

Great news! Agent {{agentName}} has accepted to work on your deal.

Agent Details:
- Name: {{agentName}}
- License: {{agentLicense}}
- Phone: {{agentPhone}}
- Email: {{agentEmail}}
- Rating: {{agentRating}}

Deal: {{dealId}}

You can contact the agent directly or communicate through ClearDeed. 

View deal details: {{dealLink}}

Best regards,
ClearDeed Team`,
    variables: ['userName', 'agentName', 'agentLicense', 'agentPhone', 'agentEmail', 'agentRating', 'dealId', 'dealLink'],
  },
  [NotificationType.PROPERTY_REJECTED]: {
    type: NotificationType.PROPERTY_REJECTED,
    channel: NotificationChannel.EMAIL,
    subject: 'Property Requires Resubmission',
    title: 'Property Could Not Be Verified',
    body: `Dear {{userName}},

Unfortunately, your property "{{propertyTitle}}" could not be verified at this time.

Reason: {{reason}}

Required Corrections:
{{requiredCorrections}}

We recommend addressing these issues and resubmitting your property:
{{resubmitLink}}

Our support team is here to help. Contact: support@cleardeed.com

Best regards,
ClearDeed Team`,
    variables: ['userName', 'propertyTitle', 'reason', 'requiredCorrections', 'resubmitLink'],
  },
  [NotificationType.DEAL_UPDATED]: {
    type: NotificationType.DEAL_UPDATED,
    channel: NotificationChannel.EMAIL,
    subject: 'Deal {{dealId}} - Status Update',
    title: 'Deal Has Been Updated',
    body: `Dear {{userName}},

Deal {{dealId}} has been updated.

What Changed:
{{changeDescription}}

Updated Deal Details:
- Property: {{propertyTitle}}
- Current Status: {{dealStatus}}
- Last Updated: {{updatedDate}}

Review the updated deal: {{dealLink}}

Best regards,
ClearDeed Team`,
    variables: ['userName', 'dealId', 'propertyTitle', 'changeDescription', 'dealStatus', 'updatedDate', 'dealLink'],
  },
};

/**
 * WhatsApp Templates
 */
export const WHATSAPP_TEMPLATES: Record<NotificationType, INotificationTemplate> = {
  [NotificationType.PROPERTY_VERIFIED]: {
    type: NotificationType.PROPERTY_VERIFIED,
    channel: NotificationChannel.WHATSAPP,
    title: 'Property Verified',
    body: `🎉 Property Verified!

Hi {{userName}}, your property "{{propertyTitle}}" is now live on ClearDeed! 

Start receiving buyer inquiries and offers.

View: https://app.cleardeed.com/property/{{propertyId}}`,
    variables: ['userName', 'propertyTitle', 'propertyId'],
  },
  [NotificationType.DEAL_CREATED]: {
    type: NotificationType.DEAL_CREATED,
    channel: NotificationChannel.WHATSAPP,
    title: 'New Deal Created',
    body: `📌 New Deal Alert!

A deal has been created for "{{propertyTitle}}"
Deal ID: {{dealId}}
Commission: ₹{{commission}}

View: https://app.cleardeed.com/deal/{{dealId}}`,
    variables: ['propertyTitle', 'dealId', 'commission'],
  },
  [NotificationType.DEAL_CLOSED]: {
    type: NotificationType.DEAL_CLOSED,
    channel: NotificationChannel.WHATSAPP,
    title: 'Deal Closed',
    body: `✅ Deal Closed!

Congratulations {{userName}}! 🎊
Deal {{dealId}} is closed.
Commission: ₹{{commission}} credited to your account.

View: https://app.cleardeed.com/commission/{{dealId}}`,
    variables: ['userName', 'dealId', 'commission'],
  },
  [NotificationType.COMMISSION_CREDITED]: {
    type: NotificationType.COMMISSION_CREDITED,
    channel: NotificationChannel.WHATSAPP,
    title: 'Commission Credited',
    body: `💰 Commission Credited!

₹{{amount}} has been added to your account.
Deal: {{dealId}}
Balance: ₹{{totalBalance}}

View: https://app.cleardeed.com/commission/ledger`,
    variables: ['amount', 'dealId', 'totalBalance'],
  },
  [NotificationType.AGENT_ACCEPTED]: {
    type: NotificationType.AGENT_ACCEPTED,
    channel: NotificationChannel.WHATSAPP,
    title: 'Agent Accepted',
    body: `👤 Agent Accepted!

{{agentName}} has accepted your deal.
Contact: {{agentPhone}}

Deal: https://app.cleardeed.com/deal/{{dealId}}`,
    variables: ['agentName', 'agentPhone', 'dealId'],
  },
  [NotificationType.PROPERTY_REJECTED]: {
    type: NotificationType.PROPERTY_REJECTED,
    channel: NotificationChannel.WHATSAPP,
    title: 'Property Rejected',
    body: `⚠️ Property Requires Resubmission

"{{propertyTitle}}" needs corrections:
{{reason}}

Resubmit: https://app.cleardeed.com/property/{{propertyId}}/resubmit`,
    variables: ['propertyTitle', 'reason', 'propertyId'],
  },
  [NotificationType.DEAL_UPDATED]: {
    type: NotificationType.DEAL_UPDATED,
    channel: NotificationChannel.WHATSAPP,
    title: 'Deal Updated',
    body: `🔄 Deal Updated!

Deal {{dealId}} status changed.
Change: {{changeDescription}}

View: https://app.cleardeed.com/deal/{{dealId}}`,
    variables: ['dealId', 'changeDescription'],
  },
};

/**
 * In-App Notification Templates (Minimal)
 */
export const IN_APP_TEMPLATES: Record<NotificationType, INotificationTemplate> = {
  [NotificationType.PROPERTY_VERIFIED]: {
    type: NotificationType.PROPERTY_VERIFIED,
    channel: NotificationChannel.IN_APP,
    title: 'Property Verified',
    body: 'Your property "{{propertyTitle}}" has been verified and is now live!',
    variables: ['propertyTitle'],
  },
  [NotificationType.DEAL_CREATED]: {
    type: NotificationType.DEAL_CREATED,
    channel: NotificationChannel.IN_APP,
    title: 'New Deal',
    body: 'A new deal has been created for "{{propertyTitle}}" (Deal ID: {{dealId}})',
    variables: ['propertyTitle', 'dealId'],
  },
  [NotificationType.DEAL_CLOSED]: {
    type: NotificationType.DEAL_CLOSED,
    channel: NotificationChannel.IN_APP,
    title: 'Deal Closed',
    body: 'Deal {{dealId}} is closed. Commission: ₹{{commission}}',
    variables: ['dealId', 'commission'],
  },
  [NotificationType.COMMISSION_CREDITED]: {
    type: NotificationType.COMMISSION_CREDITED,
    channel: NotificationChannel.IN_APP,
    title: 'Commission Credited',
    body: '₹{{amount}} has been credited for deal {{dealId}}',
    variables: ['amount', 'dealId'],
  },
  [NotificationType.AGENT_ACCEPTED]: {
    type: NotificationType.AGENT_ACCEPTED,
    channel: NotificationChannel.IN_APP,
    title: 'Agent Accepted',
    body: '{{agentName}} has accepted your deal (Deal ID: {{dealId}})',
    variables: ['agentName', 'dealId'],
  },
  [NotificationType.PROPERTY_REJECTED]: {
    type: NotificationType.PROPERTY_REJECTED,
    channel: NotificationChannel.IN_APP,
    title: 'Property Needs Resubmission',
    body: '"{{propertyTitle}}" was rejected. Reason: {{reason}}',
    variables: ['propertyTitle', 'reason'],
  },
  [NotificationType.DEAL_UPDATED]: {
    type: NotificationType.DEAL_UPDATED,
    channel: NotificationChannel.IN_APP,
    title: 'Deal Updated',
    body: 'Deal {{dealId}} has been updated: {{changeDescription}}',
    variables: ['dealId', 'changeDescription'],
  },
};

/**
 * Get template by type and channel
 */
export function getTemplate(
  type: NotificationType,
  channel: NotificationChannel,
): INotificationTemplate | null {
  switch (channel) {
    case NotificationChannel.SMS:
      return SMS_TEMPLATES[type] || null;
    case NotificationChannel.EMAIL:
      return EMAIL_TEMPLATES[type] || null;
    case NotificationChannel.WHATSAPP:
      return WHATSAPP_TEMPLATES[type] || null;
    case NotificationChannel.IN_APP:
      return IN_APP_TEMPLATES[type] || null;
    default:
      return null;
  }
}

/**
 * Replace variables in template
 * 
 * Example:
 * const template = "Hi {{name}}, your commission ₹{{amount}} has been credited"
 * const result = replaceVariables(template, { name: 'John', amount: '5000' })
 * // Result: "Hi John, your commission ₹5000 has been credited"
 */
export function replaceVariables(
  template: string,
  variables: Record<string, any>,
): string {
  let result = template;
  Object.keys(variables).forEach((key) => {
    const regex = new RegExp(`{{${key}}}`, 'g');
    result = result.replace(regex, String(variables[key] ?? ''));
  });
  return result;
}
