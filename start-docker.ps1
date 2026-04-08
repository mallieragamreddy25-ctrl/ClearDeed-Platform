#!/usr/bin/env pwsh
<#
    ClearDeed Platform - Docker Quick Start (PowerShell)
    This script automates Docker setup for Windows PowerShell
#>

Write-Host @"
╔════════════════════════════════════════════════════════╗
║     ClearDeed Platform - Docker Quick Start            ║
║                                                         ║
║     Running: PostgreSQL + NestJS Backend               ║
╚════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

# Check if Docker is installed
Write-Host "Checking Docker installation..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker found: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not installed or not in PATH" -ForegroundColor Red
    Write-Host "   Download from: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    Read-Host "Press ENTER to exit"
    exit 1
}

# Check if Docker Desktop is running
Write-Host "Checking Docker Desktop status..." -ForegroundColor Yellow
try {
    $null = docker ps
    Write-Host "✅ Docker Desktop is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker Desktop is not running" -ForegroundColor Red
    Write-Host "   Please start Docker Desktop and try again" -ForegroundColor Yellow
    Read-Host "Press ENTER to exit"
    exit 1
}

# Check for port conflicts
Write-Host "`nChecking for port conflicts..." -ForegroundColor Yellow
$ports = @(3000, 5432)
$portConflicts = $false

foreach ($port in $ports) {
    $process = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue |
               Where-Object { $_.State -eq 'Listen' } |
               Get-Process -ErrorAction SilentlyContinue |
               Select-Object -First 1

    if ($process) {
        Write-Host "⚠️  Port $port is already in use by $($process.Name) (PID: $($process.Id))" -ForegroundColor Yellow
        $portConflicts = $true
    }
}

if ($portConflicts) {
    Write-Host "`nOptions:" -ForegroundColor Yellow
    Write-Host "   1. Kill conflicting process" -ForegroundColor Yellow
    Write-Host "   2. Edit docker-compose.yml to use different ports" -ForegroundColor Yellow
}

# Stop existing containers
Write-Host "`nCleaning up existing containers..." -ForegroundColor Yellow
$null = docker-compose down -q 2>$null

# Pull latest images
Write-Host "Pulling latest Docker images..." -ForegroundColor Yellow
$null = docker-compose pull -q

# Start PostgreSQL
Write-Host "`nStarting PostgreSQL database..." -ForegroundColor Cyan
$null = docker-compose up -d postgres

# Wait for database health
Write-Host "Waiting for database to be healthy..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0

while ($attempt -lt $maxAttempts) {
    try {
        $null = docker exec cleardeed-postgres pg_isready -U cleardeed 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ PostgreSQL is healthy" -ForegroundColor Green
            break
        }
    } catch {
        # Ignore errors, keep trying
    }

    $attempt++
    Write-Host "   Attempt $attempt/$maxAttempts..." -ForegroundColor Gray
    Start-Sleep -Seconds 1
}

# Start Backend
Write-Host "`nStarting NestJS Backend..." -ForegroundColor Cyan
$null = docker-compose up -d backend

Write-Host "`nWaiting for backend to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

Write-Host @"

╔════════════════════════════════════════════════════════╗
║            ✅ SERVICES STARTING                         ║
╚════════════════════════════════════════════════════════╝

🐳 PostgreSQL Database
   Container: cleardeed-postgres
   Host:      localhost:5432
   User:      cleardeed
   Password:  cleardeed123
   Database:  cleardeed_db

🚀 NestJS Backend API
   Container: cleardeed-backend
   URL:       http://localhost:3000
   Health:    http://localhost:3000/v1/health
   Swagger:   http://localhost:3000/api/docs

📋 USEFUL COMMANDS
   View logs:
   docker-compose logs -f backend

   Stop services:
   docker-compose down

   Database CLI:
   docker exec -it cleardeed-postgres psql -U cleardeed -d cleardeed_db

   Test OTP endpoint:
   `$body = @{mobile_number = '+919876543210'} | ConvertTo-Json
   Invoke-RestMethod -Uri http://localhost:3000/v1/auth/send-otp `
     -Method Post -ContentType application/json -Body `$body

ℹ️  Press ENTER to view live logs (Ctrl+C to exit)

"@ -ForegroundColor Cyan

Read-Host "Press ENTER"

# Show live logs
Write-Host "Streaming live logs from backend..." -ForegroundColor Yellow
docker-compose logs -f backend
