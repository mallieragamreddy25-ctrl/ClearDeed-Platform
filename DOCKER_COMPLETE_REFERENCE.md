# 🐳 ClearDeed Docker - Complete Stack Quick Reference

## 🚀 START EVERYTHING (ONE COMMAND)

```bash
docker-compose up -d --build
```

Or use the automation script:
```bash
# Windows CMD
start-complete-stack.bat

# PowerShell
.\start-complete-stack.ps1
```

---

## 🌐 ACCESS APPLICATIONS

| Service | URL | Purpose |
|---------|-----|---------|
| **Flutter Web UI** | http://localhost:5000 | Mobile app in browser |
| **Backend API** | http://localhost:3001 | REST API |
| **Swagger Docs** | http://localhost:3001/api/docs | API documentation |
| **Health Check** | http://localhost:3001/v1/health | System health |
| **Database** | localhost:5432 | PostgreSQL |

---

## 📊 STATUS & LOGS

```bash
# Check all containers
docker-compose ps

# View all logs (live)
docker-compose logs -f

# View specific service logs
docker-compose logs -f flutter
docker-compose logs -f backend
docker-compose logs -f postgres

# Last 50 lines
docker-compose logs --tail=50 flutter
```

---

## 🎮 CONTROL SERVICES

### Start/Stop
```bash
# Start all
docker-compose up -d --build

# Start with logs visible
docker-compose up --build

# Stop all (keep data)
docker-compose stop

# Restart all
docker-compose restart

# Stop and remove everything
docker-compose down -v
```

### Individual Services
```bash
# Start just Flutter
docker-compose up -d flutter

# Restart backend
docker-compose restart backend

# Rebuild Flutter only
docker-compose up -d --build flutter

# Stop just database
docker-compose stop postgres
```

---

## 🔌 API TESTING

```bash
# Health check
curl http://localhost:3001/v1/health

# API info
curl http://localhost:3001/v1

# Send OTP
curl -X POST http://localhost:3001/v1/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"mobile_number": "+919876543210"}'

# Check OTP in logs
docker-compose logs backend | grep -i otp

# Verify OTP
curl -X POST http://localhost:3001/v1/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"mobile_number": "+919876543210", "otp": "123456"}'
```

---

## 💾 DATABASE OPERATIONS

```bash
# Access database CLI
docker exec -it cleardeed-postgres psql -U cleardeed -d cleardeed_db

# In PostgreSQL CLI:
\dt                          # List tables
SELECT COUNT(*) FROM users;  # Count users
\q                           # Exit

# Run migrations
docker exec cleardeed-backend npm run migrate

# Seed database
docker exec cleardeed-backend npm run seed

# Backup
docker exec cleardeed-postgres pg_dump -U cleardeed cleardeed_db > backup.sql

# Restore
docker exec -i cleardeed-postgres psql -U cleardeed cleardeed_db < backup.sql
```

---

## 🛠️ BACKEND COMMANDS

```bash
# npm commands
docker exec cleardeed-backend npm run build
docker exec cleardeed-backend npm run lint
docker exec cleardeed-backend npm test

# Shell access
docker exec -it cleardeed-backend sh

# Install package
docker exec cleardeed-backend npm install package-name
```

---

## 🔄 HOT RELOAD

### Flutter (Automatic)
```bash
# Edit file in frontend-flutter/lib/
# Browser auto-refreshes ~2 seconds
```

### Backend (Automatic)
```bash
# Edit file in backend/src/
# App auto-restarts via nodemon
```

### Database Schema (Manual)
```bash
# Edit migration file
docker exec cleardeed-backend npm run migrate
```

---

## 🐛 TROUBLESHOOTING

```bash
# Port conflicts
netstat -ano | grep 3001    # Check port 3001
netstat -ano | grep 5000    # Check port 5000
netstat -ano | grep 5432    # Check port 5432

# Check service health
docker-compose ps
# STATUS column shows health

# Full container inspect
docker inspect cleardeed-flutter
docker inspect cleardeed-backend
docker inspect cleardeed-postgres

# Network check
docker network ls
docker network inspect cleardeed-platform_cleardeed-network

# View detailed errors
docker-compose logs --tail=200 flutter
docker-compose logs --tail=200 backend
docker-compose logs --tail=200 postgres

# Rebuild everything
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

---

## 📦 RESOURCE USAGE

```bash
# CPU/Memory stats
docker stats

# Watch specific container
docker stats cleardeed-flutter

# View disk usage
docker system df

# Cleanup unused resources
docker system prune -a
docker volume prune
```

---

## 🔐 ENVIRONMENT CONFIG

Edit `docker-compose.yml` to change:

```yaml
# Backend database
DB_HOST: postgres
DB_PASSWORD: cleardeed123
DB_NAME: cleardeed_db

# JWT
JWT_SECRET: dev_jwt_secret_key_change_in_production
JWT_EXPIRES_IN: 24h

# Flutter API
API_URL: http://backend:3000
```

Then restart:
```bash
docker-compose restart
```

---

## 📋 SERVICE DETAILS

| Service | Image | Port | Network |
|---------|-------|------|---------|
| postgres | postgres:16-alpine | 5432 | cleardeed-network |
| backend | custom build | 3001→3000 | cleardeed-network |
| flutter | custom build | 5000 | cleardeed-network |

---

## 🎯 COMMON WORKFLOWS

### Full Development Setup
```bash
# Terminal 1
docker-compose up -d --build

# Terminal 2
docker-compose logs -f backend

# Terminal 3
docker-compose logs -f flutter

# Browser
open http://localhost:5000
```

### Test API Only
```bash
docker-compose up -d postgres backend
curl http://localhost:3001/v1/health
```

### Reset Everything
```bash
docker-compose down -v
docker image prune -a
docker-compose up -d --build
```

### Deploy Specific Service
```bash
# Rebuild Flutter after code changes
docker-compose up -d --build flutter

# Restart backend after API changes
docker-compose restart backend
```

---

## 🚨 ERROR FIXES

| Error | Fix |
|-------|-----|
| Port in use | Change port in docker-compose.yml |
| Network error | `docker network prune` then restart |
| Build timeout | `docker-compose build --no-cache` |
| Container won't start | Check `docker-compose logs service-name` |
| Slow build | Normal first run, ~2-3 min |

---

## 💡 PRO TIPS

1. **Save bandwidth:** Don't use `--no-cache` unless needed
2. **Fast restart:** Use `docker-compose restart` instead of `down` + `up`
3. **Check logs first:** Always check logs before restarting
4. **Watch mode:** Keep `docker-compose logs -f` running
5. **Network:** Services communicate via container names (e.g., `backend:3000`)

---

**Ready to develop! 🚀**

See `FLUTTER_DOCKER_SETUP.md` for comprehensive guide.
