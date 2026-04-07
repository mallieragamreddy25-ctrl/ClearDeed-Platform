# Admin Module - Complete Documentation

## Overview

The Admin Module provides comprehensive admin user management and activity audit logging for the ClearDeed platform. It includes role-based access control, account suspension features, and detailed audit trails for compliance and security.

## Features

### 1. Admin User Management
- **Create Admin Accounts**: Only super_admin users can create new admin accounts with specific roles
- **List Admins**: View all active admin users with their details
- **Get Admin Details**: Retrieve complete information for a specific admin
- **Update Admin**: Modify admin profile information or role assignments
- **Suspend/Unsuspend**: Temporarily disable or reactivate admin accounts
- **Role-Based Access Control**: 5 different roles with varying permissions

### 2. Activity Audit Logging
- **Automatic Logging**: All admin actions automatically recorded
- **Comprehensive Tracking**: Captures action type, timestamp, IP address, and related entity
- **Flexible Filtering**: Query logs by action type, admin ID, entity type, and date range
- **Pagination**: Efficient retrieval of large log datasets
- **Summary Reports**: Daily and weekly activity aggregation for dashboards

### 3. Security Features
- **IP Address Tracking**: All activities logged with IP addresses
- **Suspension Tracking**: Records who suspended an admin and when
- **Audit Trail**: Full history of admin account changes
- **Role Validation**: Ensures only authorized admins perform specific actions

## Admin Roles

```
1. super_admin
   - Full system administrative access
   - Can create, update, suspend/unsuspend other admins
   - Can change admin roles
   - Can access all activity logs and reports

2. property_verifier
   - Can verify properties
   - Can view activity logs
   - Cannot manage other admins

3. deal_manager
   - Can create and manage deals
   - Can close deals
   - Can view deal-related activity logs

4. commission_manager
   - Can manage and approve commissions
   - Can view commission-related activity logs
   - Can generate commission reports

5. support_agent
   - Limited access to support functions
   - Can view basic activity logs
   - Cannot perform administrative actions
```

## API Endpoints

### Admin User Management

#### List All Admin Users
```
GET /v1/admin/users
Authorization: Bearer {jwt_token}
Response: Array of admin users
```

Example Response:
```json
[
  {
    "id": 1,
    "mobile_number": "9876543210",
    "full_name": "John Admin",
    "email": "admin@cleardeed.com",
    "admin_role": "super_admin",
    "is_active": true,
    "is_suspended": false,
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z",
    "created_by_user_id": 1
  }
]
```

#### Create New Admin User
```
POST /v1/admin/users
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "mobile_number": "9876543210",
  "full_name": "Jane Doe",
  "email": "jane@cleardeed.com",
  "admin_role": "property_verifier"
}

Response: Created admin user details
Status: 201 Created
```

**Requirements:**
- Only super_admin can create new admins
- Mobile number must be unique
- Email must be globally unique
- All fields are required

#### Get Admin Details
```
GET /v1/admin/users/{id}
Authorization: Bearer {jwt_token}
Response: Admin user object
Status: 200 OK
```

#### Update Admin Details
```
PUT /v1/admin/users/{id}
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "full_name": "Jane Smith",
  "email": "jane.smith@cleardeed.com",
  "admin_role": "deal_manager"
}

Response: Updated admin user details
Status: 200 OK
```

**Notes:**
- All fields are optional for partial updates
- Only super_admin can change admin roles
- Email uniqueness is validated

#### Suspend Admin Account
```
POST /v1/admin/users/{id}/suspend
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "reason": "Unauthorized access detected"
}

Response: Suspended admin user details
Status: 200 OK
```

**Requirements:**
- Only super_admin can suspend admins
- Cannot suspend yourself
- Reason is required
- Sets suspension timestamp and tracking

#### Unsuspend Admin Account
```
POST /v1/admin/users/{id}/unsuspend
Authorization: Bearer {jwt_token}
Response: Reactivated admin user details
Status: 200 OK
```

**Requirements:**
- Only super_admin can unsuspend admins
- Clears suspension tracking information
- Reactivates the admin account

### Activity Logging & Auditing

#### Get Activity Logs
```
GET /v1/admin/activity-logs?action_type=admin_created&page=1&limit=20
Authorization: Bearer {jwt_token}
Response: Paginated activity logs
Status: 200 OK
```

**Query Parameters:**
- `action_type` (optional): Filter by action type (e.g., "admin_created", "property_verified")
- `admin_id` (optional): Filter by admin user ID who performed the action
- `related_entity_type` (optional): Filter by entity type (property, deal, commission, user, etc.)
- `start_date` (optional): Start date (ISO 8601 format)
- `end_date` (optional): End date (ISO 8601 format)
- `page` (optional): Page number (default 1)
- `limit` (optional): Records per page (default 20, max 100)

Example Response:
```json
{
  "data": [
    {
      "id": 1,
      "admin_user_id": 1,
      "action_type": "admin_created",
      "related_entity_type": "admin_user",
      "related_entity_id": 2,
      "action_details": {
        "admin_role": "property_verifier",
        "email": "jane@cleardeed.com"
      },
      "ip_address": "192.168.1.100",
      "created_at": "2024-01-15T10:35:00Z"
    }
  ],
  "total": 150,
  "page": 1,
  "limit": 20,
  "totalPages": 8
}
```

#### Get Activity Summary
```
GET /v1/admin/activity-logs/summary?period=daily&start_date=2024-01-01T00:00:00Z&end_date=2024-01-31T23:59:59Z
Authorization: Bearer {jwt_token}
Response: Aggregated activity summary
Status: 200 OK
```

**Query Parameters:**
- `period` (optional): "daily" or "weekly" (default "daily")
- `start_date` (optional): Start date (ISO 8601)
- `end_date` (optional): End date (ISO 8601)

Example Response:
```json
{
  "period": "daily",
  "start_date": "2024-01-01T00:00:00Z",
  "end_date": "2024-01-31T23:59:59Z",
  "summary": [
    {
      "date": "2024-01-15",
      "action_type": "property_verified",
      "count": 5
    },
    {
      "date": "2024-01-15",
      "action_type": "admin_created",
      "count": 1
    }
  ],
  "total_actions": 150
}
```

## Activity Types

Common activity types logged in the system:

```
Admin Management:
- admin_created: New admin account created
- admin_updated: Admin details updated
- admin_suspended: Admin account suspended
- admin_unsuspended: Admin account reactivated
- admin_creation_unauthorized_attempt: Unauthorized admin creation attempt

Property Operations:
- property_verified: Property was verified by admin
- property_rejection: Property verification rejected

Deal Operations:
- deal_created: New deal created
- deal_closed: Deal closed
- deal_updated: Deal details updated

Commission Operations:
- commission_approved: Commission approved
- commission_generated: Commission generated
- commission_paid: Commission payment processed

User Operations:
- user_created: User account created (by admin)
- user_suspended: User account suspended
```

## Integration with Other Modules

### Using AdminService in Other Modules

The AdminService can be imported and used by other modules for activity logging:

```typescript
import { AdminModule } from './modules/admin/admin.module';

@Module({
  imports: [AdminModule, /* other imports */],
  // ...
})
export class PropertiesModule {}

// In a service:
@Injectable()
export class PropertiesService {
  constructor(
    private adminService: AdminService,
    // ... other dependencies
  ) {}

  async verifyProperty(propertyId: number, adminUserId: number, ipAddress: string) {
    // ... verification logic

    // Log the activity
    await this.adminService.logActivity(
      adminUserId,
      'property_verified',
      'property',
      propertyId,
      {
        verification_type: 'ownership',
        documents_verified: 3,
      },
      ipAddress
    );

    return result;
  }
}
```

## Database Schema

### admin_users Table
```sql
CREATE TABLE admin_users (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  admin_role VARCHAR(50) NOT NULL,
  is_active BOOLEAN DEFAULT true,
  is_suspended BOOLEAN DEFAULT false,
  suspended_reason VARCHAR(500),
  suspended_at TIMESTAMP,
  suspended_by_user_id INT,
  created_by_user_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_admin_users_user_id ON admin_users(user_id);
CREATE INDEX idx_admin_users_admin_role ON admin_users(admin_role);
CREATE INDEX idx_admin_users_is_suspended ON admin_users(is_suspended);
CREATE INDEX idx_admin_users_created_by_user_id ON admin_users(created_by_user_id);
```

### admin_activity_logs Table
```sql
CREATE TABLE admin_activity_logs (
  id SERIAL PRIMARY KEY,
  admin_user_id INT REFERENCES users(id) ON DELETE SET NULL,
  action_type VARCHAR(100) NOT NULL,
  related_entity_type VARCHAR(100) NOT NULL,
  related_entity_id INT,
  action_details JSONB,
  ip_address VARCHAR(45),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_admin_activity_logs_admin_user_id ON admin_activity_logs(admin_user_id);
CREATE INDEX idx_admin_activity_logs_created_at ON admin_activity_logs(created_at);
```

## Error Handling

### Common HTTP Status Codes

| Status | Meaning | Example |
|--------|---------|---------|
| 200 | Success | Admin retrieved, updated, activity logs retrieved |
| 201 | Created | New admin account created |
| 400 | Bad Request | Validation error, duplicate email, invalid role |
| 401 | Unauthorized | Missing or invalid JWT token |
| 403 | Forbidden | User lacks required permissions (not super_admin) |
| 404 | Not Found | Admin account not found |

## Security Considerations

1. **JWT Authentication**: All endpoints require valid JWT token
2. **Admin Guard**: Most endpoints require authenticated admin user
3. **Role-Based Authorization**: Sensitive operations require super_admin role
4. **IP Tracking**: All activities logged with requester IP address
5. **Audit Trail**: Full history maintained for compliance
6. **Suspension Prevention**: Suspended admins cannot authenticate or act

## Best Practices

### 1. Admin Creation
```typescript
// Only create admins through the API
// Always verify the creating admin is super_admin
// Ensure unique email and mobile number
```

### 2. Activity Logging
```typescript
// Log activities at the point of action
// Include relevant action_details for context
// Capture IP address from request
// Use consistent action_type names
```

### 3. Filtering Activity Logs
```typescript
// Use specific filters to reduce query results
// Combine multiple filters for precise results
// Use pagination for large datasets
// Cache summary data for dashboards
```

### 4. Suspension Workflow
```typescript
// Always provide clear reason for suspension
// Log the suspension with investigation details
// Notify the suspended admin
// Document unsuspension reasons
```

## Testing

### Unit Tests
```typescript
describe('AdminService', () => {
  let service: AdminService;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [AdminService],
    }).compile();

    service = module.get<AdminService>(AdminService);
  });

  it('should create new admin', async () => {
    const dto = {
      mobile_number: '9876543210',
      full_name: 'Test Admin',
      email: 'test@cleardeed.com',
      admin_role: 'property_verifier',
    };

    const result = await service.createAdmin(dto, 1, '192.168.1.1');
    expect(result).toBeDefined();
    expect(result.admin_role).toBe('property_verifier');
  });
});
```

### Integration Tests
```typescript
describe('Admin Module (e2e)', () => {
  it('should create admin and log activity', async () => {
    // Create admin
    const response = await request(app.getHttpServer())
      .post('/v1/admin/users')
      .set('Authorization', `Bearer ${token}`)
      .send({
        mobile_number: '9876543210',
        full_name: 'Test Admin',
        email: 'test@cleardeed.com',
        admin_role: 'property_verifier',
      })
      .expect(201);

    // Verify in activity logs
    const logsResponse = await request(app.getHttpServer())
      .get('/v1/admin/activity-logs?action_type=admin_created')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(logsResponse.body.total).toBeGreaterThan(0);
  });
});
```

## Future Enhancements

1. **Admin Permissions Matrix**: Fine-grained permission control per role
2. **Activity Log Retention Policy**: Automatic archival of old logs
3. **Real-time Notifications**: Alert on suspicious admin activities
4. **Dashboard Integration**: Visual activity summaries
5. **Bulk Operations**: Create multiple admins, bulk suspension/unsuspension
6. **Activity Statistics**: Performance metrics and activity trends
7. **Admin Session Management**: Track active admin sessions
8. **Two-Factor Authentication**: Additional security layer for super_admin accounts

## Support

For questions or issues regarding the Admin Module:
1. Check the module documentation
2. Review API endpoint examples
3. Check activity logs for error details
4. Contact system administrator
