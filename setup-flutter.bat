@echo off
REM ClearDeed Flutter App - Quick Setup Script for Windows

echo.
echo ========================================
echo  ClearDeed Flutter Mobile App - Setup
echo ========================================
echo.

REM Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Flutter not found!
    echo.
    echo Please install Flutter from: https://flutter.dev/docs/get-started/install
    echo.
    pause
    exit /b 1
)

echo ✅ Flutter is installed
echo.

REM Navigate to Flutter project
cd /d "C:\Users\mallikharjunareddy_e\ClearDeed-Platform\frontend-flutter"
if errorlevel 1 (
    echo ❌ Flutter project not found at expected location
    pause
    exit /b 1
)

echo ✅ In Flutter project directory
echo.

REM Check for flutter doctor
echo Running Flutter Doctor...
flutter doctor
echo.

REM Get dependencies
echo.
echo 📥 Fetching dependencies...
call flutter pub get

if errorlevel 1 (
    echo ❌ Failed to get dependencies
    pause
    exit /b 1
)

echo ✅ Dependencies installed successfully!
echo.

REM List available devices
echo.
echo 📱 Available devices:
flutter devices
echo.

REM Ask user if they want to run the app
echo.
echo ========================================
echo  Ready to launch app!
echo ========================================
echo.
echo Options:
echo   1. Run on emulator/device
echo   2. Just exit (will run manually)
echo.
set /p choice="Enter choice (1-2): "

if "%choice%"=="1" (
    echo.
    echo 🚀 Launching Flutter app...
    call flutter run
) else (
    echo.
    echo To run the app manually, use:
    echo   cd C:\Users\mallikharjunareddy_e\ClearDeed-Platform\frontend-flutter
    echo   flutter run
    echo.
)

pause
