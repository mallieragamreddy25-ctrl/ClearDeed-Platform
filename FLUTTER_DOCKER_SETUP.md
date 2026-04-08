# 🐳 Flutter Web Docker Setup - ClearDeed Platform

## ✅ COMPLETE DOCKER STACK

Now you can run **everything** with one command:

```bash
docker-compose up -d
```

This starts:
- ✅ **PostgreSQL Database** (port 5432)
- ✅ **NestJS Backend API** (port 3001)
- ✅ **Flutter Web UI** (port 5000)

---

## 🚀 QUICK START

### Start Everything

```bash
cd /c/Users/mallikharjunareddy_e/Workspace/ClearDeed-Platform

# Start all services
docker-compose up -d --build

# Watch logs
docker-compose logs -f
```

### Access Applications

| Service | URL | Details |
|---------|-----|---------|
| **Flutter Web UI** | http://localhost:5000 | Mobile app in browser |
| **Backend API** | http://localhost:3001 | API & Swagger docs |
| **Database** | localhost:5432 | PostgreSQL |

---

## 📱 FLUTTER WEB UI FEATURES

Once running at `http://localhost:5000`:

✅ **Authentication Flow**
- Phone number entry
- OTP verification
- Profile setup
- JWT token management

✅ **Buy Module**
- Browse properties (Land, Houses, Commercial, Agriculture)
- Filter by category, city, price
- Property details with gallery
- Express interest button

✅ **Sell Module**
- 6-step property submission form
- Image gallery upload
- Document upload
- Referral agent selection
- Status tracking

✅ **Investment Module**
- Browse investment projects
- View project details
- Express interest

✅ **Account & Notifications**
- User profile
- Account settings
- Notification center

---

## 🔧 COMMANDS

### View Logs

```bash
# All services
docker-compose logs -f

# Flutter only
docker-compose logs -f flutter

# Backend only
docker-compose logs -f backend

# Database only
docker-compose logs -f postgres
```

### Control Services

```bash
# Start all
docker-compose up -d

# Start with logs
docker-compose up

# Stop all
docker-compose stop

# Restart
docker-compose restart

# Full reset (deletes data)
docker-compose down -v

# Rebuild Flutter
docker-compose up -d --build flutter
```

### Service Status

```bash
# Check all containers
docker-compose ps

# Check Flutter container
docker-compose ps flutter

# Inspect logs for errors
docker-compose logs --tail=100 flutter
```

---

## 🔌 API CONFIGURATION

Flutter automatically connects to:

```
http://backend:3000
```

This is the Docker container name, which resolves internally within the network.

**From your browser:**
```
http://localhost:3001/v1
http://localhost:5000 (Flutter UI)
```

---

## 📦 BUILD PROCESS

When you run `docker-compose up -d --build flutter`:

1. Pulls official Flutter image
2. Copies pubspec.yaml & pubspec.lock
3. Runs `flutter pub get`
4. Copies source code
5. Enables web platform
6. Starts web dev server on port 5000

**Time:** ~2-3 minutes on first build (includes dependency download)

---

## 🔄 HOT RELOAD

Changes to Flutter code are **automatically hot-reloaded**:

```bash
# Edit a file in frontend-flutter/lib/
# Save it
# Browser automatically refreshes
```

Volumes are configured for:
- `frontend-flutter/lib` (source code)
- `frontend-flutter/web` (web assets)

---

## ⚠️ TROUBLESHOOTING

### Flutter Port Already in Use

```bash
# Change port in docker-compose.yml
# ports: ["5001:5000"]

docker-compose up -d flutter
```

### Flutter Container Won't Start

```bash
# Check logs
docker-compose logs flutter -f

# Rebuild from scratch
docker-compose down -v
docker-compose up -d --build flutter
```

### Cannot Connect to Backend

```bash
# Verify backend is healthy
docker-compose ps backend
# STATUS should show "healthy"

# Check backend logs
docker-compose logs backend -f

# Verify network connection
docker exec cleardeed-flutter ping backend
```

### Build Timeout

Flutter web build can take time. If Docker timeout:

```bash
# Increase build timeout
docker-compose build --no-cache flutter

# Or just wait longer and check logs
docker-compose logs -f flutter
```

---

## 📊 ARCHITECTURE

```
┌─────────────────────────────────────────────────────────┐
│                  Local Development                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Your Browser (localhost:5000)                         │
│      ↓                                                  │
│  ┌──────────────────────────────────────────┐         │
│  │  Flutter Web Container                   │         │
│  │  • Port: 5000                            │         │
│  │  • Hot reload enabled                    │         │
│  │  • Connects to backend:3000              │         │
│  └──────────────────────┬───────────────────┘         │
│                         ↓                              │
│  ┌──────────────────────────────────────────┐         │
│  │  NestJS Backend Container                │         │
│  │  • Port: 3000 (mapped to 3001)           │         │
│  │  • 50+ API endpoints                     │         │
│  │  • Connects to postgres:5432             │         │
│  └──────────────────────┬───────────────────┘         │
│                         ↓                              │
│  ┌──────────────────────────────────────────┐         │
│  │  PostgreSQL Container                   │         │
│  │  • Port: 5432                           │         │
│  │  • Database: cleardeed_db               │         │
│  └──────────────────────────────────────────┘         │
│                                                         │
│  Network: cleardeed-network (bridge)                  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 🎯 DEVELOPMENT WORKFLOW

### Terminal Setup (Recommended)

```bash
# Terminal 1: Start all services
cd /Workspace/ClearDeed-Platform
docker-compose up -d --build

# Terminal 2: Watch backend logs
docker-compose logs -f backend

# Terminal 3: Watch Flutter logs
docker-compose logs -f flutter

# Browser: Open http://localhost:5000
```

### Development Cycle

1. Edit Flutter code in `frontend-flutter/lib/`
2. Browser auto-refreshes (hot reload)
3. Test features against local API
4. Check logs in terminals
5. Repeat

---

## 📝 NEXT STEPS

1. ✅ Start services:
   ```bash
   docker-compose up -d --build
   ```

2. ✅ Open Flutter UI:
   ```
   http://localhost:5000
   ```

3. ✅ Test OTP flow:
   - Enter phone number
   - Check backend logs for OTP
   - Verify OTP
   - Create profile

4. ✅ Browse properties:
   - View property listings
   - See property details
   - Express interest

5. ✅ Test sell flow:
   - Start property creation
   - Upload images
   - Upload documents
   - Submit for verification

---

## 🚨 COMMON ISSUES

| Issue | Solution |
|-------|----------|
| Port 5000 in use | Change to 5001 in docker-compose.yml |
| Flutter won't build | `docker-compose build --no-cache flutter` |
| Cannot connect to API | Verify backend health: `docker-compose ps` |
| Network error | Check `docker network ls` and restart services |
| Slow build | Normal on first run, takes 2-3 min |

---

## 💾 DATABASE OPERATIONS

```bash
# Access database
docker exec -it cleardeed-postgres psql -U cleardeed -d cleardeed_db

# Run migrations
docker exec cleardeed-backend npm run migrate

# Seed data
docker exec cleardeed-backend npm run seed

# Backup database
docker exec cleardeed-postgres pg_dump -U cleardeed cleardeed_db > backup.sql
```

---

## 🔐 SECURITY NOTES

- ✅ OTP tokens expire after 10 minutes
- ✅ JWT tokens expire after 24 hours
- ✅ CORS enabled for development (*)
- ✅ Database password protected
- ⚠️ Change JWT_SECRET in production
- ⚠️ Change DB_PASSWORD in production

---

## 📚 USEFUL FILES

- `docker-compose.yml` - Orchestration config
- `frontend-flutter/Dockerfile` - Flutter building
- `backend/Dockerfile.dev` - Backend development
- `DOCKER_SETUP.md` - Full Docker guide
- `DOCKER_QUICK_REFERENCE.md` - Quick commands

---

## ✨ COMPLETE STACK RUNNING

Once you run:

```bash
docker-compose up -d --build
```

You have:

```
✅ PostgreSQL       → localhost:5432
✅ NestJS Backend   → localhost:3001/v1
✅ Flutter Web      → localhost:5000
✅ Swagger Docs     → localhost:3001/api/docs
✅ Everything Connected & Ready
```

---

**Let's build! 🚀**

Last Updated: April 8, 2026
