@echo off
REM ========================================
REM  Flutter Automatic Installation Script
REM  Windows - PowerShell Version
REM ========================================

echo.
echo ========================================
echo  ClearDeed - Flutter Auto Installer
echo ========================================
echo.

REM Check if PowerShell is available
powershell -Command "Write-Host 'PowerShell found'" >nul 2>&1
if errorlevel 1 (
    echo ERROR: PowerShell not found
    pause
    exit /b 1
)

REM Run PowerShell installation script
echo Starting Flutter installation...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"$ProgressPreference = 'SilentlyContinue'; ^
Write-Host '📥 Step 1: Downloading Flutter...' -ForegroundColor Yellow; ^
if (-not (Test-Path 'C:\flutter')) { ^
    $url = 'https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.5-stable.zip'; ^
    $output = 'C:\flutter_temp.zip'; ^
    Write-Host 'Downloading from: $url' -ForegroundColor Gray; ^
    try { ^
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12; ^
        (New-Object System.Net.WebClient).DownloadFile('$url', '$output'); ^
        Write-Host '✓ Download complete' -ForegroundColor Green; ^
        Write-Host '📦 Step 2: Extracting to C:\flutter...' -ForegroundColor Yellow; ^
        if (Test-Path 'C:\flutter_temp.zip') { ^
            Add-Type -AssemblyName System.IO.Compression.FileSystem; ^
            [System.IO.Compression.ZipFile]::ExtractToDirectory('C:\flutter_temp.zip', 'C:\'); ^
            Remove-Item 'C:\flutter_temp.zip' -Force; ^
            Write-Host '✓ Extraction complete' -ForegroundColor Green; ^
        } ^
    } catch { ^
        Write-Host 'Error downloading: $_' -ForegroundColor Red; ^
        exit 1; ^
    } ^
} else { ^
    Write-Host '✓ Flutter already exists at C:\flutter' -ForegroundColor Green; ^
}; ^
Write-Host '🔧 Step 3: Adding Flutter to PATH...' -ForegroundColor Yellow; ^
$flutterPath = 'C:\flutter\bin'; ^
$currentPath = [System.Environment]::GetEnvironmentVariable('Path', 'User'); ^
if ($currentPath -notlike '*flutter*') { ^
    [System.Environment]::SetEnvironmentVariable('Path', \"$currentPath;$flutterPath\", 'User'); ^
    Write-Host '✓ Flutter added to PATH' -ForegroundColor Green; ^
} else { ^
    Write-Host '✓ Flutter already in PATH' -ForegroundColor Green; ^
}; ^
Write-Host '✓ Installation complete!' -ForegroundColor Green; ^
Write-Host '' -ForegroundColor White; ^
Write-Host 'NEXT STEPS:' -ForegroundColor Cyan; ^
Write-Host '1. Close all PowerShell/Command Prompt windows' -ForegroundColor White; ^
Write-Host '2. Restart your computer (or restart PowerShell)' -ForegroundColor White; ^
Write-Host '3. Run: flutter --version' -ForegroundColor White; ^
Write-Host '4. Run: flutter doctor' -ForegroundColor White; ^
Write-Host '' -ForegroundColor White; ^
Write-Host 'Then launch the app:' -ForegroundColor Cyan; ^
Write-Host 'cd C:\Users\mallikharjunareddy_e\ClearDeed-Platform\frontend-flutter' -ForegroundColor Gray; ^
Write-Host 'flutter pub get' -ForegroundColor Gray; ^
Write-Host 'flutter run' -ForegroundColor Gray; ^
"

pause
