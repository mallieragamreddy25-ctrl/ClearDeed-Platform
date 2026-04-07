# 📱 **Flutter Mobile App Setup & Deployment Guide**

## **📋 Prerequisites**

Before deploying the ClearDeed Flutter app, ensure you have:

### **1. Flutter Installed**
```powershell
# Check if Flutter is installed
flutter --version

# If not installed, download from: https://flutter.dev/docs/get-started/install
```

### **2. Android Emulator OR Device**

**Option A: Android Emulator (Recommended for testing)**
```powershell
# Download Android Studio from https://developer.android.com/studio

# Open Android Studio → Device Manager → Create Virtual Device
# - Select Pixel 5 or Pixel 6
# - Android API 33+ recommended
# - At least 4GB RAM
```

**Option B: Physical Device**
```powershell
# 1. Enable Developer Mode
#    Go to Settings → About Phone → Tap "Build Number" 7 times
# 
# 2. Enable USB Debugging
#    Settings → Developer Options → USB Debugging (ON)
#
# 3. Connect via USB and allow debugging
```

### **3. Verify Setup**
```powershell
# Check all dependencies
flutter doctor

# You should see:
# ✓ Flutter (Channel stable)
# ✓ Android toolchain
# ✓ Android SDK
# (Xcode not required for Android)
```

---

## **🚀 Quick Start (5 Minutes)**

### **Step 1: Navigate to Flutter Project**
```powershell
cd C:\Users\mallikharjunareddy_e\ClearDeed-Platform\frontend-flutter
```

### **Step 2: Get Dependencies**
```powershell
flutter pub get
```

**Expected Output:**
```
Running "flutter pub get" in frontend-flutter...
Resolving dependencies...
Got dependencies!
```

### **Step 3: Start Android Emulator**
```powershell
# List available emulators
flutter emulators

# Start an emulator (replace with your device name)
flutter emulators --launch pixel_5_api_33

# Or open Android Studio Device Manager
```

### **Step 4: Run the App**
```powershell
flutter run

# OR specify device
flutter run -d <device_id>
```

**Expected Output:**
```
Launching lib/main.dart on Android Emulator in debug mode...
✓ Build successful!
✓ App installed successfully
✓ App launched

I/flutter ( 8293): ClearDeed App Started! 🚀
```

---

## **📱 What to Expect When App Launches**

### **1. OTP Login Screen**
```
┌─────────────────────────────┐
│   🏠 ClearDeed              │
│                             │
│   Enter Phone Number        │
│   +91 [______________]      │
│                             │
│   [Send OTP]                │
│   [Skip for Demo]           │
└─────────────────────────────┘
```

**For Testing:**
- **Enter:** +919876543210
- **Tap:** Send OTP
- **Use Demo OTP:** Any 6-digit number (e.g., 123456)

### **2. Home Screen**
After OTP verification, you'll see:
```
┌─────────────────────────────┐
│ ☰ ClearDeed      🔔 👤      │
├─────────────────────────────┤
│  👋 Welcome, Rajesh!        │
│                             │
│  📍 Where are you looking?  │
│  [Land] [House] [Commercial]│
│                             │
│  🔥 Featured Properties     │
│  ┌────────────────────────┐ │
│  │ Modern Villa Bangalore │ │
│  │ ₹8.0 Cr | 2500 sq ft │ │
│  └────────────────────────┘ │
│  [⬁ Express Interest]       │
└─────────────────────────────┘
```

### **3. Navigation (Bottom Tab Bar)**
- 🏠 **Home** - Dashboard & featured properties
- 🔍 **Browse** - Search & filter properties
- ➕ **Sell** - 6-step property upload form
- 💼 **Projects** - Investment opportunities
- 👤 **Profile** - User settings & history

---

## **🎯 Full Workflow to Test**

### **1. Login & Profile Setup**
```
1. Tap "Send OTP"
2. Enter demo OTP (any 6 digits)
3. Set up profile:
   - Name: Your Name
   - City: Bangalore
   - Mode: Buyer/Seller/Investor
   - Budget: ₹50L - ₹1Cr
```

### **2. Browse Properties**
```
1. Tap "Browse" tab
2. See 3 sample properties:
   - Modern Villa: ₹8Cr (Verified ✅)
   - Commercial: ₹15Cr (Verified ✅)
   - Agriculture: ₹2.5Cr (Pending)
3. Filter by:
   - Category (Land, House, Commercial)
   - City (Bangalore, Mumbai, Pune)
   - Price range
```

### **3. View Property Details**
```
1. Tap on any property
2. See full details:
   - Title, description, specs
   - Ownership type
   - Verification status
   - Photo gallery
   - Express interest button
3. Tap "Express Interest" to save
```

### **4. Sell Property (6-Step Form)**
```
Step 1: Property Details
  - Title, description
  - Category, city, locality
  - Area in sq ft
  - Price
  - Ownership type

Step 2: Upload Images
  - Select from gallery
  - Take with camera
  - Crop & reorder
  - Min 3, Max 10 images

Step 3: Upload Documents
  - Property deed
  - Tax documents
  - NOC if needed
  - Upload PDF/JPG

Step 4: Referral Details
  - Select referral partner (optional)
  - Referral code

Step 5: Review
  - Verify all details
  - Edit if needed

Step 6: Submit
  - Confirm submission
  - View submission status
  - Track verification
```

### **5. View Notifications**
```
1. Tap 🔔 icon (top right)
2. See notifications:
   - Property verification status
   - Deal updates
   - New offers
   - Admin messages
```

### **6. User Profile**
```
1. Tap "Profile" tab
2. Options:
   - View/Edit Profile
   - Change Mode (Buyer/Seller)
   - View submission history
   - Commission tracking
   - Logout
```

---

## **🔌 API Configuration**

The app is pre-configured to connect to your local backend:

**File:** `lib/services/api_client.dart`

```dart
const String BASE_URL = 'http://localhost:3000';
```

**If running on physical device:**
```dart
// Get your computer's IP address
// Windows: ipconfig | findstr "IPv4"
// Replace localhost with your IP
const String BASE_URL = 'http://192.168.x.x:3000';
```

---

## **⚙️ Advanced Options**

### **Release Build (for distribution)**
```powershell
# Android APK
flutter build apk --release
# Output: build/app/outputs/flutter-app.apk

# Android App Bundle (Google Play)
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab

# iOS (requires Mac)
flutter build ios --release
```

### **Debugging**
```powershell
# See device logs
flutter logs

# Run with debug prints
flutter run -v

# Test mode
flutter run --profile
```

### **Hot Reload (During Development)**
```
Press 'r' in terminal to hot reload
Press 'R' to restart
Press 'q' to quit
```

---

## **📊 Emulator Selection Guide**

| Device | RAM | API | Recommended |
|--------|-----|-----|-------------|
| Pixel 5 | 2GB | 31+ | ✅ Best |
| Pixel 6 | 2GB | 32+ | ✅ Best |
| Pixel 4a | 2GB | 30+ | ✅ Good |
| Nexus 5X | 2GB | 29+ | ⚠️ Slow |

---

## **🐛 Troubleshooting**

### **"flutter: command not found"**
```powershell
# Add Flutter to PATH
# 1. Find Flutter SDK location
# 2. Add C:\flutter\bin to Environment Variables
# 3. Restart PowerShell
```

### **"No connected devices"**
```powershell
# Check connected devices
flutter devices

# Start emulator manually
# Or connect Android device with USB debugging enabled
```

### **"Dependencies not found"**
```powershell
# Clean and get again
flutter clean
flutter pub get
```

### **"API connection failed"**
```
1. Check backend is running: http://localhost:3000/health
2. For physical device, use your IP instead of localhost:
   192.168.x.x:3000
3. Check firewall allows port 3000
```

### **"App crashes on launch"**
```powershell
# Check logs
flutter logs

# Rebuild
flutter clean
flutter pub get
flutter run
```

---

## **✅ Testing Checklist**

- [ ] Flutter installed & updated
- [ ] Android Emulator or device configured
- [ ] Backend API running on localhost:3000
- [ ] `flutter pub get` completed
- [ ] App launched successfully
- [ ] OTP login working
- [ ] Can browse properties
- [ ] Can submit property (seller flow)
- [ ] Navigation tabs working
- [ ] Real data from API displayed

---

## **📚 Project Structure**

```
lib/
├── main.dart                 (App entry point)
├── models/                   (Data models)
│   ├── user.dart
│   ├── property.dart
│   ├── deal.dart
│   └── ...
├── providers/                (State management - Riverpod)
│   ├── auth_provider.dart
│   ├── property_provider.dart
│   └── ...
├── screens/                  (UI screens)
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── otp_screen.dart
│   │   └── profile_setup_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── profile_screen.dart
│   ├── properties/
│   │   ├── list_screen.dart
│   │   ├── detail_screen.dart
│   │   └── filter_screen.dart
│   ├── sell/
│   │   ├── form_screen.dart
│   │   ├── upload_screen.dart
│   │   └── review_screen.dart
│   └── ...
├── services/                 (API & business logic)
│   ├── api_client.dart
│   ├── auth_service.dart
│   └── ...
├── theme/                    (Colors, styles, typography)
│   └── app_theme.dart
└── utils/                    (Helpers & constants)
```

---

## **🔗 Connected to Backend**

The Flutter app automatically connects to:
- **API:** http://localhost:3000
- **Authentication:** OTP via SMS (mocked in demo)
- **Data:** Real-time from backend API
- **Storage:** Local caching with Hive

---

## **🎉 Ready to Launch!**

```bash
cd C:\Users\mallikharjunareddy_e\ClearDeed-Platform\frontend-flutter
flutter pub get
flutter run
```

**Your ClearDeed mobile app will be live in 60 seconds!** 🚀

---

## **📞 Need Help?**

Refer to:
- `README.md` - Full documentation
- `FLUTTER_IMPLEMENTATION.md` - Technical details
- `API_PRACTICE_GUIDE.md` - API testing examples
- Backend health: http://localhost:3000/health

---

**Happy testing!** 🎊
