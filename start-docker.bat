@echo off
REM ClearDeed Platform - Docker Quick Start (Windows)
REM This script automates Docker setup for Windows PowerShell

setlocal enabledelayedexpansion

echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║     ClearDeed Platform - Docker Quick Start            ║
echo ║                                                         ║
echo ║     Running: PostgreSQL + NestJS Backend               ║
echo ╚════════════════════════════════════════════════════════╝
echo.

REM Check if Docker is installed
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker is not installed or not in PATH
    echo    Download from: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

REM Check if Docker Desktop is running
docker ps >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker Desktop is not running
    echo    Please start Docker Desktop and try again
    pause
    exit /b 1
)

echo ✅ Docker is installed and running
echo.

REM Check for port conflicts
echo Checking for port conflicts...

for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3000') do (
    echo ⚠️  Port 3000 is already in use (PID: %%a)
    echo    Stopping that process or using different port required
    echo    Options:
    echo    1. Kill process: taskkill /PID %%a /F
    echo    2. Use different port: Edit docker-compose.yml
)

for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5432') do (
    echo ⚠️  Port 5432 is already in use (PID: %%a)
    echo    Stopping that process or using different port required
)

echo.

REM Start Docker Compose
echo Starting services with Docker Compose...
echo.

docker-compose down >nul 2>&1
echo Pulling latest images...
docker-compose pull

echo.
echo Starting PostgreSQL database...
docker-compose up -d postgres

REM Wait for database to be ready
echo Waiting for database to be healthy...
setlocal enabledelayedexpansion
for /l %%i in (1,1,30) do (
    docker exec cleardeed-postgres pg_isready -U cleardeed >nul 2>&1
    if !errorlevel! equ 0 (
        echo ✅ PostgreSQL is healthy
        goto :db_ready
    )
    echo    Attempt %%i/30...
    timeout /t 1 /nobreak >nul
)

:db_ready
echo.
echo Starting NestJS Backend...
docker-compose up -d backend

echo.
echo Waiting for backend to start...
timeout /t 3 /nobreak >nul

echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║            ✅ SERVICES STARTING                         ║
echo ╚════════════════════════════════════════════════════════╝
echo.
echo 🐳 PostgreSQL Database
echo    Container: cleardeed-postgres
echo    Host:      localhost:5432
echo    User:      cleardeed
echo    Password:  cleardeed123
echo    Database:  cleardeed_db
echo.
echo 🚀 NestJS Backend API
echo    Container: cleardeed-backend
echo    URL:       http://localhost:3000
echo    Health:    http://localhost:3000/v1/health
echo    Swagger:   http://localhost:3000/api/docs
echo.
echo 📋 USEFUL COMMANDS
echo    View logs:
echo    docker-compose logs -f backend
echo.
echo    Stop services:
echo    docker-compose down
echo.
echo    Database CLI:
echo    docker exec -it cleardeed-postgres psql -U cleardeed -d cleardeed_db
echo.
echo    Test OTP endpoint:
echo    curl -X POST http://localhost:3000/v1/auth/send-otp ^
echo      -H "Content-Type: application/json" ^
echo      -d "{\"mobile_number\": \"+919876543210\"}"
echo.
echo ℹ️  Press ENTER to view live logs, or close this window to continue
echo.
pause

REM Show live logs
docker-compose logs -f backend
