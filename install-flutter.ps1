$ProgressPreference = 'SilentlyContinue'
Write-Host "========================================"
Write-Host "  ClearDeed - Flutter Installer"
Write-Host "========================================"
Write-Host ""

Write-Host "Step 1: Downloading Flutter SDK..."
$url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.5-stable.zip"
$output = "C:\flutter_temp.zip"

[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

try {
    Write-Host "Downloading... (2-5 minutes)"
    (New-Object System.Net.WebClient).DownloadFile($url, $output)
    Write-Host "[OK] Download complete"
} catch {
    Write-Host "[ERROR] Download failed: $_"
    exit 1
}

Write-Host ""
Write-Host "Step 2: Extracting to C:\flutter..."
if (Test-Path "C:\flutter") {
    Remove-Item "C:\flutter" -Recurse -Force
}

try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($output, "C:\")
    Remove-Item $output -Force
    Write-Host "[OK] Extraction complete"
} catch {
    Write-Host "[ERROR] Extraction failed: $_"
    exit 1
}

Write-Host ""
Write-Host "Step 3: Adding to PATH..."
$flutterPath = "C:\flutter\bin"
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")

if ($currentPath -notlike "*flutter*") {
    $newPath = "$currentPath;$flutterPath"
    [System.Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "[OK] Flutter added to PATH"
} else {
    Write-Host "[OK] Flutter already in PATH"
}

Write-Host ""
Write-Host "========================================"
Write-Host "  INSTALLATION COMPLETE!"
Write-Host "========================================"
Write-Host ""
Write-Host "NEXT STEPS:"
Write-Host "1. Close ALL PowerShell windows"
Write-Host "2. Open NEW PowerShell window"
Write-Host "3. Run: flutter --version"
Write-Host ""
Write-Host "Then launch app:"
Write-Host "cd C:\Users\mallikharjunareddy_e\ClearDeed-Platform\frontend-flutter"
Write-Host "flutter pub get"
Write-Host "flutter run"
