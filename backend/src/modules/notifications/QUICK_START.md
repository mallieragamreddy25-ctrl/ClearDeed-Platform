# Notifications Module - Quick Start Guide

Get the notifications module up and running in 5 minutes.

## 1. Installation

The module is already integrated into the ClearDeed backend.

### Install Twilio (Optional, for actual SMS/WhatsApp)

```bash
npm install twilio
```

For development/testing without Twilio:
```bash
# Leave Twilio as optional - notifications will use mock mode
npm install --save-optional twilio
```

## 2. Configuration

### Set Environment Variables (.env)

```env
# Twilio (Optional - development uses mock)
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your_auth_token_here
TWILIO_PHONE=+1234567890
TWILIO_WHATSAPP=whatsapp:+1234567890

# Node environment affects mock mode
NODE_ENV=development  # Uses mock mode (logs to console)
# or
NODE_ENV=production   # Uses actual Twilio service
```

## 3. Start the Server

```bash
cd backend
npm install
npm run dev
```

The notifications module is automatically loaded by the app.module.ts.

## 4. Test the API

### Using cURL

**Get notifications:**
```bash
curl http://localhost:3000/v1/notifications?page=1&limit=10 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Send a test notification (Admin):**
```bash
curl -X POST http://localhost:3000/v1/notifications/send \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "userId": "user-123",
    "type": "property_verified",
    "channels": ["sms", "in_app"],
    "templateData": {
      "userName": "John Doe",
      "propertyTitle": "Luxury Villa",
      "propertyAddress": "123 Main St",
      "propertyPrice": "5000000"
    }
  }'
```

**Update preferences:**
```bash
curl -X POST http://localhost:3000/v1/notifications/preferences \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "emailNotifications": false,
    "smsNotifications": true,
    "quietHoursStart": "22:00",
    "quietHoursEnd": "08:00"
  }'
```

### Using Swagger UI

Navigate to: `http://localhost:3000/api/docs`

All notification endpoints are documented with examples.

## 5. Using the Service in Your Code

### Import the Service

```typescript
import { NotificationsService, NotificationType, NotificationChannel, NotificationPriority } from './modules/notifications';

export class PropertyService {
  constructor(private notificationsService: NotificationsService) {}

  async verifyProperty(propertyId: string) {
    // ... verification logic
    
    // Send notification
    await this.notificationsService.sendNotification({
      userId: property.sellerId,
      type: NotificationType.PROPERTY_VERIFIED,
      channels: [NotificationChannel.SMS, NotificationChannel.IN_APP],
      templateData: {
        userName: seller.name,
        propertyTitle: property.title,
        propertyAddress: property.address,
        propertyPrice: property.price.toString()
      }
    });
  }
}
```

### Queue for Async Processing

```typescript
// For non-urgent notifications
await this.notificationsService.queueNotification({
  userId: agentId,
  type: NotificationType.DEAL_CREATED,
  channels: [NotificationChannel.SMS],
  templateData: { ... },
  priority: NotificationPriority.LOW
});
```

## 6. Check Logs (Development)

In development with mock mode, all SMS/WhatsApp sends appear in console:

```
[Nest] 3/31/2026 10:30:45 AM LOG [NestFactory] Nest application successfully started +2456ms
[Nest] 3/31/2026 10:30:45 AM LOG [TwilioService] Twilio service running in mock mode
[MOCK] SMS to +919876543210: Hi John, your property "Luxury Villa" has been verified...
[MOCK] WhatsApp to +919876543210: 🎉 Property Verified! Your property is now live on ClearDeed!
```

## 7. View Swagger Documentation

1. Start the server: `npm run dev`
2. Open browser: `http://localhost:3000/api/docs`
3. Find "Notifications" section
4. Click "Try it out" on any endpoint

## Common Tasks

### Send Notification from Another Module

```typescript
import { NotificationsService, NotificationType, NotificationChannel } from '@/modules/notifications';

@Injectable()
export class DealService {
  constructor(private notificationsService: NotificationsService) {}

  async createDeal(createDealDto: CreateDealDto) {
    const deal = this.dealsRepository.create(createDealDto);
    await this.dealsRepository.save(deal);

    // Notify agent
    await this.notificationsService.sendNotification({
      userId: deal.agentId,
      type: NotificationType.DEAL_CREATED,
      channels: [NotificationChannel.SMS, NotificationChannel.WHATSAPP],
      templateData: {
        userName: deal.agentName,
        propertyTitle: deal.propertyTitle,
        dealId: deal.id,
        commission: deal.commission.toString()
      },
      priority: NotificationPriority.HIGH
    });

    return deal;
  }
}
```

### Check User Preferences

```typescript
const preferences = await this.notificationsService.getOrCreatePreferences(userId);

if (preferences.smsNotifications) {
  // User has SMS enabled
}

if (preferences.dealCreatedEnabled) {
  // User wants deal creation notifications
}
```

### Get Unread Notifications with Pagination

```typescript
const result = await this.notificationsService.getNotifications(userId, {
  page: 1,
  limit: 20,
  unreadOnly: true,
  sortBy: 'DESC'
});

console.log(`Found ${result.total} unread notifications`);
result.data.forEach(n => console.log(n.title, n.message));
```

### Mark Multiple Notifications as Read

```typescript
const notificationIds = ['id1', 'id2', 'id3'];
const affected = await this.notificationsService.markAsRead(userId, notificationIds);
console.log(`Marked ${affected} notifications as read`);
```

### Get Notification Statistics

```typescript
const summary = await this.notificationsService.getNotificationSummary(userId);
console.log(`Total unread: ${summary.totalUnread}`);
console.log(`By type:`, summary.byType);    // { property_verified: 2, deal_created: 1 }
console.log(`By channel:`, summary.byChannel); // { sms: 2, email: 1, in_app: 0 }
```

## Testing Without Twilio

In development, the module automatically uses mock mode:

1. No need to provide real Twilio credentials
2. All SMS/WhatsApp sends are logged to console
3. Notifications are still saved to database
4. Perfect for development and testing

Example .env for dev:
```env
NODE_ENV=development
DB_HOST=localhost
DB_USERNAME=postgres
DB_PASSWORD=password
DB_NAME=cleardeed_db
```

## Troubleshooting

### Problem: "Twilio client not initialized"
**Solution**: In production, ensure `TWILIO_ACCOUNT_SID` and `TWILIO_AUTH_TOKEN` are set. In development, this is fine - it will use mock mode.

### Problem: Notifications not appearing
**Solution**: Check user preferences - notifications might be disabled for that type or channel.

### Problem: SMS not sending
**Solution**: 
1. Check console logs (development shows `[MOCK]` prefix)
2. Verify phone number format
3. Check `deliveryAttempts` in database

### Problem: Can't access Swagger docs
**Solution**: Ensure server is running and navigate to `http://localhost:3000/api/docs` (not `/swagger-ui`)

## Database

The module automatically creates these tables on first run (if synchronize is enabled):

- `notifications` - Main notification records
- `notification_preferences` - User preferences
- `notification_audit_logs` - Audit trail
- `notification_queue_jobs` - Async queue

For production, create migrations:
```bash
npm run typeorm migration:generate -- -n AddNotificationsModule
```

## Next Steps

1. ✅ Module is installed and working
2. Integrate with your business logic (Properties, Deals, etc.)
3. Add real Twilio credentials for production
4. Set up SendGrid/AWS SES for email
5. Configure monitoring and alerts
6. Test with production data

## Support

**Check these first:**
1. Console logs for mock mode messages/errors
2. Database records in `notifications` table
3. Audit logs in `notification_audit_logs` table
4. Swagger docs at http://localhost:3000/api/docs

---

**Quick Links**
- [Full Documentation](./README.md)
- [API Examples](./README.md#api-endpoints)
- [Configuration](./README.md#configuration)
- [Integration Examples](./README.md#integration-with-other-modules)
