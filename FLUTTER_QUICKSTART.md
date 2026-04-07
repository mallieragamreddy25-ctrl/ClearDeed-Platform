# 🚀 **Flutter App - Quick Start (5 Minutes)**

## **Step 1: Check Prerequisites**

**In PowerShell:**
```powershell
# Verify Flutter is installed
flutter --version

# Check all setup
flutter doctor
```

**Should see:**
✅ Flutter (Channel stable)
✅ Android toolchain
✅ Android SDK (API 33+)

### **If Flutter is NOT installed:**
1. Download from: https://flutter.dev/docs/get-started/install
2. Extract and add to PATH
3. Run `flutter doctor`

---

## **Step 2: Start Android Emulator**

### **Method 1: Via Android Studio (Easy)**
1. Open **Android Studio**
2. **Device Manager** → Create or select device
3. Click ▶️ (Play) to start emulator
4. Wait for boot (2-3 minutes)

### **Method 2: Via Command Line**
```powershell
# See available emulators
flutter emulators

# Start one (replace with your device name)
flutter emulators --launch pixel_5_api_33

# Wait for boot...
```

### **Method 3: Physical Device**
1. Connect Android phone via USB
2. Enable USB Debugging in Settings
3. Allow access when prompted

---

## **Step 3: Launch Flutter App**

**In PowerShell:**
```powershell
# Go to project folder
cd C:\Users\mallikharjunareddy_e\ClearDeed-Platform\frontend-flutter

# Get dependencies
flutter pub get

# Run app
flutter run
```

**You'll see:**
```
Launching lib/main.dart on Android Emulator in debug mode...
✓ Built build/app/outputs/flutter-app.apk (XX.XMB)
✓ Installing and launching...
I/flutter ( 8293): ✅ App Started!
```

---

## **Step 4: Test the App**

### **Login Screen**
1. Enter phone: **+919876543210**
2. Tap **Send OTP**
3. Use any **6-digit OTP** (e.g., 123456)
4. Complete profile setup
5. Select mode: **Buyer** or **Seller**

### **Home Screen**
See:
- ✅ Welcome message
- ✅ Property categories
- ✅ Featured properties with real data
- ✅ Bottom navigation

### **Browse Properties**
1. Tap 🔍 icon
2. See 3 properties from backend:
   - Modern Villa (₹8Cr) ✅ Verified
   - Commercial Space (₹15Cr) ✅ Verified
   - Agricultural Land (₹2.5Cr)
3. Filter by category/city
4. Tap property to see details

### **Sell Property**
1. Tap ➕ **Sell** tab
2. Complete 6-step form:
   - Step 1: Property details
   - Step 2: Upload images
   - Step 3: Upload documents
   - Step 4: Referral info
   - Step 5: Review
   - Step 6: Submit
3. Property goes to **submitted** status
4. Admin verifies in dashboard

---

## **Step 5: During Development**

**Live Reload** (while app is running):
```
Press 'r' in terminal to hot reload
Press 'R' to restart
Press 'q' to quit
```

---

## **❌ Troubleshooting**

### **"No connected devices"**
```powershell
# Make sure emulator is running
flutter devices

# Should show:
# emulator-5554 • Android ... • android-arm64
```

### **"API connection failed"**
Check:
1. Backend running: http://localhost:3000/health
2. For physical device, update IP in: `lib/services/api_client.dart`
3. Firewall allows port 3000

### **"Class '_InvocationMirror' has no instance getter 'xxx'"**
```powershell
flutter clean
flutter pub get
flutter run
```

### **App won't build**
```powershell
# Clean and retry
flutter clean
flutter pub cache clean
flutter pub get
flutter run
```

---

## **🎯 What You'll See**

### **GIF Walkthrough:**

```
Login
  ↓
Home (Featured Properties)
  ↓
Browse (Filter & Search)
  ↓
Property Details (Photos, Specs)
  ↓
Sell Property (6-Step Form)
  ↓
Success! Submission Tracked
```

---

## **📊 Connected to Real Backend**

The app shows:
- **3 Sample Properties** from API
- **1 Completed Deal** with ₹8Cr transaction
- **Commission Tracking** (₹32L total)
- **Real API Data** from http://localhost:3000

---

## **🔗 API Endpoints Used by App**

```
✅ POST   /api/auth/send-otp
✅ POST   /api/auth/verify-otp
✅ POST   /api/users/profile
✅ GET    /api/users/profile
✅ GET    /api/properties
✅ GET    /api/properties/:id
✅ POST   /api/properties
✅ GET    /api/deals
✅ POST   /api/deals
✅ GET    /api/commissions/ledger
```

All working and tested! ✅

---

## **✨ That's it!**

Your ClearDeed mobile app should now be running with:
- ✅ OTP authentication
- ✅ Real API data
- ✅ Full property browsing
- ✅ Deal tracking
- ✅ Commission reporting

Enjoy testing! 🎉
