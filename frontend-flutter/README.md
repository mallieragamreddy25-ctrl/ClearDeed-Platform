# ClearDeed Flutter Frontend

## Structure

```
lib/
├── main.dart                 # App entry point
├── theme/
│   └── app_theme.dart       # Theme configuration
├── models/                  # Data models
│   ├── user.dart
│   └── property.dart
├── screens/
│   ├── auth/
│   │   └── login_screen.dart
│   ├── profile/
│   │   ├── profile_screen.dart
│   │   └── mode_select_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── properties/
│   │   ├── properties_list_screen.dart
│   │   └── property_detail_screen.dart
│   ├── sell/
│   │   ├── sell_upload_screen.dart
│   │   ├── document_upload_screen.dart
│   │   └── status_screen.dart
│   └── projects/
│       ├── projects_list_screen.dart
│       └── project_detail_screen.dart
├── services/
│   ├── api_service.dart     # API client
│   ├── auth_service.dart
│   └── storage_service.dart
└── providers/               # Riverpod providers
    ├── auth_provider.dart
    └── property_provider.dart
```

## Setup Instructions

1. **Install Flutter**: https://flutter.dev/docs/get-started/install
2. **Get dependencies**: `flutter pub get`
3. **Generate models**: `flutter pub run build_runner build`
4. **Run app**: `flutter run`

## Key Features

- **Authentication**: Mobile OTP login
- **Property Browsing**: Category-based filtering, search, details view
- **Property Selling**: Step-by-step upload flow with document management
- **Investment Projects**: Browse and express interest
- **Notifications**: Real-time updates on verification and deals
- **Referral Tracking**: Secure link for deal status

## Dependencies Overview

- **state_management**: Riverpod (reactive, testable)
- **networking**: Dio + Retrofit (type-safe APIs)
- **storage**: Hive (local persistence)
- **ui**: Material Design 3
- **navigation**: GoRouter (modern navigation)
