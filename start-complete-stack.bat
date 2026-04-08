@echo off
REM ClearDeed Complete Stack - Docker Quick Start (Windows)
REM Starts: PostgreSQL + NestJS Backend + Flutter Web UI

setlocal enabledelayedexpansion

echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║   ClearDeed Platform - Complete Docker Stack          ║
echo ║                                                        ║
echo ║   Services: PostgreSQL + Backend + Flutter Web        ║
echo ╚════════════════════════════════════════════════════════╝
echo.

REM Check Docker
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker is not installed
    pause
    exit /b 1
)

echo ✅ Docker found
echo.

REM Stop existing containers
echo Cleaning up existing containers...
docker-compose down -v >nul 2>&1

echo.
echo Building and starting services...
docker-compose up -d --build

echo.
echo Waiting for services to be ready...
timeout /t 10 /nobreak >nul

echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║          ✅ SERVICES STARTED                            ║
echo ╚════════════════════════════════════════════════════════╝
echo.
echo 🐘 PostgreSQL Database
echo    • Host: localhost:5432
echo    • User: cleardeed
echo    • Database: cleardeed_db
echo.
echo 🚀 NestJS Backend API
echo    • URL: http://localhost:3001
echo    • Swagger: http://localhost:3001/api/docs
echo    • Health: http://localhost:3001/v1/health
echo.
echo 📱 Flutter Web UI
echo    • URL: http://localhost:5000
echo    • Opens in your browser...
echo.

REM Open Flutter UI in browser
timeout /t 2 /nobreak >nul
start http://localhost:5000

echo.
echo 📋 COMMANDS
echo    View all logs:        docker-compose logs -f
echo    View Flutter logs:    docker-compose logs -f flutter
echo    View Backend logs:    docker-compose logs -f backend
echo    Stop services:        docker-compose down
echo    Restart services:     docker-compose restart
echo.
echo ℹ️  Press any key to view live logs, or close this window to continue...
pause >nul

docker-compose logs -f
