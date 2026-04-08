#!/usr/bin/env pwsh
<#
    ClearDeed Complete Stack - Docker Quick Start (PowerShell)
    Starts: PostgreSQL + NestJS Backend + Flutter Web UI
#>

Write-Host @"
╔════════════════════════════════════════════════════════╗
║   ClearDeed Platform - Complete Docker Stack          ║
║                                                        ║
║   Services: PostgreSQL + Backend + Flutter Web        ║
╚════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

# Check Docker
Write-Host "Checking Docker installation..." -ForegroundColor Yellow
try {
    $null = docker --version
    Write-Host "✅ Docker found" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker not found" -ForegroundColor Red
    Read-Host "Press ENTER to exit"
    exit 1
}

Write-Host "`nCleaning up existing containers..." -ForegroundColor Yellow
$null = docker-compose down -v 2>$null

Write-Host "Building and starting all services..." -ForegroundColor Cyan
docker-compose up -d --build

Write-Host "`nWaiting for services to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

Write-Host @"

╔════════════════════════════════════════════════════════╗
║          ✅ SERVICES STARTED                            ║
╚════════════════════════════════════════════════════════╝

🐘 PostgreSQL Database
   • Host: localhost:5432
   • User: cleardeed
   • Database: cleardeed_db

🚀 NestJS Backend API
   • URL: http://localhost:3001
   • Swagger: http://localhost:3001/api/docs
   • Health: http://localhost:3001/v1/health

📱 Flutter Web UI
   • URL: http://localhost:5000
   • Opens in your browser...

📋 COMMANDS

   View all logs:        docker-compose logs -f
   View Flutter logs:    docker-compose logs -f flutter
   View Backend logs:    docker-compose logs -f backend
   Stop services:        docker-compose down
   Restart services:     docker-compose restart

ℹ️  Opening Flutter UI in browser...

"@ -ForegroundColor Cyan

# Open Flutter UI
Start-Sleep -Seconds 2
Start-Process "http://localhost:5000"

Write-Host "Press ENTER to view live logs (Ctrl+C to exit)" -ForegroundColor Yellow
Read-Host

docker-compose logs -f
