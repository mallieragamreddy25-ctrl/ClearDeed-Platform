# 📱 **Flutter Installation Guide for Windows**

## **Step 1: Download Flutter SDK**

1. **Go to:** https://flutter.dev/docs/get-started/install/windows
2. **Click:** Download the latest stable version
3. **File:** `flutter_windows_3.x.x-stable.zip` (~600MB)
4. **Extract to:** `C:\flutter` (or your preferred location)

---

## **Step 2: Verify Extraction**

After extracting, you should see:
```
C:\flutter\
  ├── bin/
  ├── packages/
  ├── dev/
  └── ...
```

---

## **Step 3: Add Flutter to PATH**

### **Method 1: Using GUI (Easy)**

1. **Press:** `Win + X` → **Settings**
2. **Go to:** Settings → System → About → Advanced system settings
3. **Click:** Environment Variables
4. **Under "User variables" → Click "New"**
   - Variable name: `FLUTTER_PATH`
   - Variable value: `C:\flutter\bin`
5. **Click OK**

6. **Now edit "Path" variable:**
   - Select "Path" → Edit
   - Click "New"
   - Add: `C:\flutter\bin`
   - Click OK

7. **Restart PowerShell/Command Prompt**

### **Method 2: Using PowerShell (Advanced)**

```powershell
# Run as Administrator
$FlutterPath = "C:\flutter\bin"
$CurrentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")

if ($CurrentPath -notlike "*$FlutterPath*") {
    [System.Environment]::SetEnvironmentVariable(
        "Path",
        "$CurrentPath;$FlutterPath",
        "User"
    )
    Write-Host "✅ Flutter added to PATH"
}
```

---

## **Step 4: Verify Installation**

**Open PowerShell and run:**
```powershell
flutter --version
```

**Should show:**
```
Flutter 3.x.x • channel stable
```

---

## **Step 5: Run Flutter Doctor**

```powershell
flutter doctor
```

**You should see:**
```
✓ Flutter (Channel stable, X.X.X)
✓ Android toolchain (if Android SDK is installed)
? Others as needed
```

### **If you see issues:**

#### **Android SDK not found:**
```powershell
# Flutter can help
flutter doctor --android-licenses

# Or install Android Studio from:
# https://developer.android.com/studio
```

#### **Other fixes:**
```powershell
# Update Flutter
flutter upgrade

# Get latest packages
flutter pub global activate dartfmt
```

---

## **Step 6: Set Up Android Emulator (Optional but recommended)**

### **Option A: Android Studio (Easiest)**

1. **Download:** https://developer.android.com/studio
2. **Install** Android Studio
3. **Open** Android Studio
4. **Device Manager** → Create Device
   - Select: Pixel 5 or Pixel 6
   - API: 33 or higher
   - RAM: 4GB minimum
5. **Start the emulator**

### **Option B: Command Line**

```powershell
# List available emulators
flutter emulators

# Create if none exist
# Or start an existing one:
flutter emulators --launch pixel_5_api_33
```

---

## **Step 7: Verify Everything Works**

```powershell
# Check devices
flutter devices

# Should show something like:
# Android Emulator • emulator-5554 • android-arm64 • Android (...)
```

---

## **Complete Setup Summary**

| Step | What | Command |
|------|------|---------|
| 1 | Download Flutter | Visit flutter.dev |
| 2 | Extract | `C:\flutter` |
| 3 | Add to PATH | Environment Variables |
| 4 | Verify | `flutter --version` |
| 5 | Check setup | `flutter doctor` |
| 6 | Setup emulator | Android Studio or CLI |
| 7 | Test | `flutter devices` |

---

## **Now You're Ready!**

Once Flutter is installed and verified:

```powershell
cd C:\Users\mallikharjunareddy_e\ClearDeed-Platform\frontend-flutter

# Get dependencies
flutter pub get

# Run the app
flutter run
```

---

## **Troubleshooting Installation**

### **"flutter: command not found"**
- PATH not updated
- Restart PowerShell after changing PATH
- Check PATH actually has `C:\flutter\bin`

### **"Android SDK not found"**
- Install Android Studio
- Or set ANDROID_SDK_ROOT:
```powershell
$env:ANDROID_SDK_ROOT = "C:\Users\YourUsername\AppData\Local\Android\sdk"
```

### **"Java not found"**
- Install JDK 11+
- Or update Android Studio

### **Still having issues?**
```powershell
# Clean everything
flutter clean

# Get latest
flutter upgrade

# Check setup again
flutter doctor -v
```

---

## **Alternative: Use Precompiled Build**

If you don't want to install Flutter, you can build a standalone APK:

```powershell
# Go to project
cd C:\Users\mallikharjunareddy_e\ClearDeed-Platform\frontend-flutter

# Build APK (requires Flutter to be installed first)
flutter build apk --release

# Output: build/app/outputs/flutter-app.apk
# Install on device manually
```

---

## **✅ After Installation**

Once Flutter is installed:

1. ✅ Open PowerShell
2. ✅ Run: `flutter pub get`
3. ✅ Run: `flutter run`
4. ✅ App launches on emulator/device

---

**Questions?** Run `flutter doctor -v` to see detailed info about your setup.
