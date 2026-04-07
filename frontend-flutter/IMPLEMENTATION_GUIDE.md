# ClearDeed Flutter App - Phase 1 Implementation Guide

## Overview

This document provides a comprehensive guide to the Flutter mobile application for ClearDeed, a verified real estate & investment platform. Phase 1 includes authentication, user profiles, home screen, and property browsing features.

## 📁 Project Structure

```
frontend-flutter/lib/
├── main.dart                          # App entry point with ProviderScope
├── theme/
│   └── app_theme.dart                # Material Design 3 theme configuration
├── utils/
│   ├── constants.dart                # API endpoints, validation constants
│   ├── validators.dart               # Form validation utilities
│   └── app_logger.dart               # Comprehensive logging system
├── services/
│   ├── api_client.dart               # HTTP client with Dio (auth, interceptors)
│   ├── auth_service.dart             # Authentication (OTP, login, profile)
│   ├── property_service.dart         # Property queries & management
│   └── storage_service.dart          # Local persistence (SharedPreferences)
├── providers/
│   ├── auth_provider.dart            # Auth state & notifier
│   ├── user_provider.dart            # User profile state
│   └── property_provider.dart        # Property list & detail state
├── models/
│   ├── user.dart                     # User model
│   └── property.dart                 # Property models
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart        # Phone input & OTP flow
│   │   └── otp_screen.dart          # OTP verification with countdown
│   ├── profile/
│   │   └── profile_setup_screen.dart # User onboarding form
│   ├── home/
│   │   └── home_screen.dart         # Main hub with bottom navigation
│   ├── properties/
│   │   ├── properties_list_screen.dart    # Browse with filters & search
│   │   └── property_detail_screen.dart    # Full property information
│   ├── sell/
│   │   └── sell_screen.dart         # Property listing (stub)
│   └── account/
│       └── account_screen.dart      # User profile & settings
```

## 🔐 Authentication Flow

### 1. **Login Screen** (`login_screen.dart`)
- User enters 10-digit Indian phone number
- Validates phone format in real-time
- Sends OTP via `AuthService.sendOtp()`

```dart
// Validation is automatic via TextFormField validator
final phoneNumber = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
await authNotifier.sendOtp(phoneNumber);
```

### 2. **OTP Verification** (`otp_screen.dart`)
- 6-digit OTP input with auto-submit on completion
- Countdown timer for OTP resend (60 seconds)
- Automatic retry with `AuthService.resendOtp()`

```dart
// Auto-submit when 6 digits are entered
if (value.length == 6) {
  await authNotifier.verifyOtp(phoneNumber, otp);
}
```

### 3. **Profile Setup** (`profile_setup_screen.dart`)
- Collects: Full name, email, city, profile type (Buyer/Seller/Investor)
- Optional: Budget/Net worth, referral number
- Submits via `UserProvider.updateProfile()`

```dart
final success = await ref.read(userProvider.notifier).updateProfile(
  fullName: name,
  email: email,
  city: city,
  profileType: profileType,
  budget: budget,
  netWorth: netWorth,
  referralNumber: referral,
);
```

## 🏠 Home Screen Architecture

### Bottom Navigation (4 Tabs)
1. **Home** - User greeting + featured properties + quick actions
2. **Browse** - Property search with filters
3. **Sell** - Property listing (Phase 2)
4. **Account** - Profile & settings

### Quick Action Cards
```dart
_QuickActionCard(
  title: 'Buy',
  icon: Icons.shopping_cart,
  onTap: () => navigateToPropertiesBrowse(),
)
```

### Featured Properties
- Horizontal scrollable carousel
- Integrated with `featuredPropertiesProvider`
- Auto-loads on app startup

```dart
final featuredPropertiesAsync = ref.watch(featuredPropertiesProvider);
// Shows loading state then displays properties
```

## 🔍 Property Browsing

### List Screen (`properties_list_screen.dart`)
- **Search:** Real-time search via `PropertyService.searchProperties()`
- **Filters:** 
  - Category dropdown
  - Price range (bottom sheet modal)
- **View Toggle:** Grid ↔ List view
- **Pagination:** "Load More" button with automatic pagination

```dart
// Filter by category
await ref.read(propertyListProvider.notifier).setCategory('Land');

// Filter by price
await ref.read(propertyListProvider.notifier).setPriceRange(5000000, 50000000);

// Load next page
await ref.read(propertyListProvider.notifier).loadNextPage();
```

### Detail Screen (`property_detail_screen.dart`)
- Image carousel with counter
- Property specifications (area, category, status)
- Detailed description
- Documents section with download links
- Verified badge
- Favorite toggle
- Express interest button

```dart
// Toggle favorite
await ref.read(propertyDetailProvider(propertyId).notifier).toggleFavorite();

// Express interest
final success = await ref
  .read(propertyDetailProvider(propertyId).notifier)
  .expressInterest();
```

## 📱 Services Layer

### API Client (`api_client.dart`)
```dart
final apiClient = ApiClient(
  baseUrl: AppConstants.baseUrl,
  authToken: token,
);

// Methods: get(), post(), put(), patch(), delete()
// Features: auth header injection, request/response logging, interceptors
final response = await apiClient.get('/properties', 
  queryParameters: {'page': 1}
);
```

### Auth Service (`auth_service.dart`)
```dart
final authService = AuthService(apiClient: apiClient);

// OTP flow
await authService.sendOtp(phoneNumber: '+91-98765-43210');
final token = await authService.verifyOtp(
  phoneNumber: '+91-98765-43210',
  otp: '123456'
);

// Profile management
final user = await authService.updateUserProfile(
  fullName: 'John Doe',
  email: 'john@example.com',
  city: 'Mumbai',
  profileType: 'Buyer',
);

// Logout
await authService.logout();
```

### Property Service (`property_service.dart`)
```dart
final propertyService = PropertyService(apiClient: apiClient);

// List with filters
final properties = await propertyService.getProperties(
  page: 1,
  category: 'Land',
  city: 'Mumbai',
  minPrice: 5000000,
  maxPrice: 50000000,
);

// Get detail
final detail = await propertyService.getPropertyDetail(123);

// Express interest
await propertyService.expressInterest(propertyId: 123);

// Search
final results = await propertyService.searchProperties('Mumbai');
```

### Storage Service (`storage_service.dart`)
```dart
// Token management
await StorageService.saveToken(token);
final token = StorageService.getToken();
await StorageService.clearToken();

// User data
await StorageService.saveUser(user);
final user = StorageService.getUser();
await StorageService.clearUser();

// Favorites
await StorageService.addFavoriteProperty(propertyId);
await StorageService.removeFavoriteProperty(propertyId);
final isFavorited = StorageService.isFavorited(propertyId);

// Session
await StorageService.logout(); // Clears all session data
```

## 🔄 State Management (Riverpod)

### Auth Provider (`auth_provider.dart`)
```dart
// Watch auth state
final authState = ref.watch(authProvider);

// Query specific values
final isAuthenticated = ref.watch(isAuthenticatedProvider);
final token = ref.watch(authTokenProvider);
final isLoading = ref.watch(isAuthLoadingProvider);
final error = ref.watch(authErrorProvider);

// Perform actions
await ref.read(authProvider.notifier).sendOtp('+919876543210');
await ref.read(authProvider.notifier).verifyOtp('+919876543210', '123456');
await ref.read(authProvider.notifier).logout();
ref.read(authProvider.notifier).clearError();
```

### User Provider (`user_provider.dart`)
```dart
// Get user profile
final user = ref.watch(currentUserProvider);
final isComplete = ref.watch(isProfileCompleteProvider);
final isLoading = ref.watch(userLoadingProvider);

// Update profile
final success = await ref.read(userProvider.notifier).updateProfile(
  fullName: 'John Doe',
  // ... other fields
);

// Auto-fetch when authenticated
final _ = ref.watch(autoFetchUserProfileProvider);
```

### Property Provider (`property_provider.dart`)
```dart
// Property list with filters
final listState = ref.watch(propertyListProvider);

// Filter operations
await ref.read(propertyListProvider.notifier).setCategory('Land');
await ref.read(propertyListProvider.notifier).setPriceRange(min, max);
await ref.read(propertyListProvider.notifier).search('Mumbai');
await ref.read(propertyListProvider.notifier).loadNextPage();
await ref.read(propertyListProvider.notifier).clearFilters();

// Property detail
final detailState = ref.watch(propertyDetailProvider(propertyId));
await ref.read(propertyDetailProvider(propertyId).notifier)
  .loadPropertyDetail(propertyId);
await ref.read(propertyDetailProvider(propertyId).notifier)
  .toggleFavorite();
await ref.read(propertyDetailProvider(propertyId).notifier)
  .expressInterest();

// Featured properties
final featured = ref.watch(featuredPropertiesProvider);

// Search
final searchResults = ref.watch(searchPropertiesProvider('Mumbai'));

// Favorites
final favoriteIds = ref.watch(favoritePropertyIdsProvider);
```

## 🎨 Theme & Design

### Color Scheme
- **Primary:** Dark Blue (#003366)
- **Accent:** Grey (#555555)
- **Background:** Light Grey (#F5F5F5)
- **Success:** Green (#4CAF50)
- **Error:** Red (#F44336)
- **Warning:** Orange (#FFC107)
- **Info:** Blue (#2196F3)

### Material Design 3
All components follow MD3 guidelines:
- Rounded corners (8dp default)
- Elevation & shadows for depth
- Proper spacing & typography
- Bottom navigation with material styling

## ✅ Form Validation

### Validators (`validators.dart`)
```dart
// Phone number (10 digits, starts with 6-9)
Validators.validatePhoneNumber(value)

// OTP (exactly 6 digits)
Validators.validateOtp(value)

// Full name
Validators.validateFullName(value)

// Email (optional and required versions)
Validators.validateEmail(value)
Validators.validateEmailOptional(value)

// City
Validators.validateCity(value)

// Amounts
Validators.validateAmount(value)

// Profile type
Validators.validateProfileType(value)
```

Usage in forms:
```dart
TextFormField(
  validator: Validators.validatePhoneNumber,
  decoration: InputDecoration(labelText: 'Phone'),
)
```

## 🔧 Constants & Configuration

### API Endpoints (`constants.dart`)
```dart
static const String baseUrl = 'https://api.cleardeed.com/v1';
static const Duration apiTimeout = Duration(seconds: 30);

// Auth
static const String sendOtpEndpoint = '/auth/send-otp';
static const String verifyOtpEndpoint = '/auth/verify-otp';

// Properties
static const String propertiesEndpoint = '/properties';
static const String propertyDetailEndpoint = '/properties';
static const String expressInterestEndpoint = '/properties/express-interest';
```

### Configuration
```dart
// OTP Configuration
static const int otpResendDelaySeconds = 60;
static const int otpExpirySeconds = 600; // 10 minutes

// Pagination
static const int propertyPageSize = 20;

// Categories
static const List<String> propertyCategories = [
  'Land', 'Houses', 'Commercial', 'Agriculture'
];
static const List<String> profileTypes = ['Buyer', 'Seller', 'Investor'];
```

## 📊 Logging System

### App Logger (`app_logger.dart`)
```dart
// General logging
AppLogger.verbose('message');
AppLogger.debug('message');
AppLogger.info('message');
AppLogger.warning('message');
AppLogger.error('message');

// API logging
AppLogger.logApiRequest(
  method: 'POST',
  endpoint: '/auth/send-otp',
  body: requestData,
);
AppLogger.logApiResponse(
  method: 'POST',
  endpoint: '/auth/send-otp',
  statusCode: 200,
  body: responseData,
);

// Navigation tracking
AppLogger.logNavigation('HomeScreen', 'BrowseProperties');

// State changes
AppLogger.logStateChange('authProvider', oldState, newState);

// Auth events
AppLogger.logAuthEvent('User logged in');
```

## 🚀 Getting Started

### 1. Install Dependencies
```bash
cd frontend-flutter
flutter pub get
```

### 2. Update pubspec.yaml
Ensure all dependencies are installed:
```yaml
flutter_riverpod: ^2.4.0
dio: ^5.3.0
shared_preferences: ^2.2.0
carousel_slider: ^4.2.0
logger: ^2.0.0
```

### 3. Initialize Storage Service
In `main.dart`, initialize storage on app startup:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.initialize();
  runApp(const ProviderScope(child: ClearDeedApp()));
}
```

### 4. Run the App
```bash
flutter run
```

## 🔌 API Integration Stubs

Currently, all services use stub implementations that simulate API responses. To integrate with real API:

1. **Update BaseUrl in `constants.dart`**
   ```dart
   static const String baseUrl = 'https://your-api-domain.com/v1';
   ```

2. **The services will automatically:**
   - Construct proper endpoints
   - Handle authentication headers
   - Parse responses
   - Manage errors

3. **Example real API response:**
   ```json
   {
     "data": {
       "id": 1,
       "mobile_number": "98765-43210",
       "token": "eyJhbGc..."
     }
   }
   ```

## 🧪 Testing the App

### Test Scenario 1: Complete Authentication Flow
1. Launch app → See login screen
2. Enter phone: "98765 43210"
3. Click "Continue with OTP"
4. See OTP screen with phone masked
5. Auto-fill shows OTP countdown
6. Enter "123456"
7. Should auto-submit and navigate to profile setup

### Test Scenario 2: Browse Properties
1. Complete auth flow
2. Navigate to "Browse" tab
3. View properties list (grid/list toggle)
4. Filter by category or price
5. Search for location
6. Tap property → See full detail
7. Toggle favorite, express interest

### Test Scenario 3: Home Screen
1. Complete auth flow
2. View welcome greeting
3. See quick action cards
4. View featured properties carousel
5. Test navigation to other sections

## 📦 APK/Release Build

```bash
# Build debug APK
flutter build apk

# Build release APK
flutter build apk --release

# Build app bundle (for Play Store)
flutter build appbundle
```

## 🐛 Error Handling

All services implement comprehensive error handling:

```dart
try {
  await authService.verifyOtp(phoneNumber, otp);
} on AuthException catch (e) {
  print('Error: ${e.message}');
  print('Code: ${e.code}');
  // Show user-friendly error message
}
```

Common error codes:
- `SEND_OTP_FAILED`: Failed to send OTP
- `VERIFY_OTP_ERROR`: Network error during verification
- `NO_TOKEN`: Invalid server response
- `GET_PROFILE_FAILED`: Failed to fetch user profile
- `GET_PROPERTIES_ERROR`: Failed to load properties

## 📝 Notes for Phase 2

Items for future implementation:
1. Sell property listing flow
2. Investment projects browsing
3. User history & transactions
4. Payment integration
5. Advanced filters & saved searches
6. Push notifications
7. Chat with sellers/buyers
8. Document upload & verification
9. Map integration
10. Biometric authentication

## 🔗 Dependencies Overview

- **flutter_riverpod**: State management
- **dio**: HTTP client library
- **shared_preferences**: Local storage
- **carousel_slider**: Image carousels
- **google_fonts**: Typography
- **logger**: Structured logging
- **json_serializable**: JSON parsing

---

**Version:** 1.0.0  
**Target SDK:** Flutter 3.0+, Dart 3.0+  
**Min SDK:** Android 21, iOS 12
