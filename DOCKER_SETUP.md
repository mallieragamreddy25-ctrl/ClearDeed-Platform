# 🐳 Docker Setup Guide - ClearDeed Platform

## ✅ Prerequisites

1. **Docker Desktop** installed and running
   - Windows/Mac: Download from [docker.com](https://www.docker.com/downloads)
   - Linux: `sudo apt install docker.io docker-compose`

2. **Verify Docker Installation**
```bash
docker --version
docker-compose --version
```

---

## 🚀 Quick Start (One Command)

From project root (`/Workspace/ClearDeed-Platform`):

```bash
# Start both PostgreSQL + Backend in Docker
docker-compose up -d

# Watch logs
docker-compose logs -f backend
```

**That's it!** The system will:
- ✅ Create PostgreSQL container + database
- ✅ Build NestJS backend image
- ✅ Start backend with hot-reload (develop mode)
- ✅ Expose API on http://localhost:3000

---

## 📋 Available Commands

### Start Services

```bash
# Start in background (detached mode)
docker-compose up -d

# Start with live logs
docker-compose up

# Start specific service
docker-compose up -d postgres          # Just database
docker-compose up -d backend           # Just backend (after DB is ready)
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f postgres

# Last N lines
docker-compose logs -f --tail=50 backend
```

### Stop Services

```bash
# Stop all (keep data)
docker-compose stop

# Stop & remove containers (keep volumes)
docker-compose down

# Stop & remove everything (⚠️ DELETE ALL DATA)
docker-compose down -v
```

### Database Operations

```bash
# Access PostgreSQL CLI inside container
docker exec -it cleardeed-postgres psql -U cleardeed -d cleardeed_db

# Run database migrations
docker exec cleardeed-backend npm run migrate

# Seed database
docker exec cleardeed-backend npm run seed

# View database inside container
docker exec -it cleardeed-postgres psql -U cleardeed -d cleardeed_db -c "\dt"
```

### Backend Operations

```bash
# npm commands inside container
docker exec cleardeed-backend npm run build
docker exec cleardeed-backend npm run lint
docker exec cleardeed-backend npm test

# Shell access to backend
docker exec -it cleardeed-backend sh

# View backend logs
docker logs -f cleardeed-backend

# Rebuild backend image
docker-compose build backend

# Rebuild after code changes
docker-compose up -d --build backend
```

---

## 🔍 API Access

Once running, access:

| Endpoint | URL |
|----------|-----|
| **API Health** | http://localhost:3000/v1/health |
| **API Info** | http://localhost:3000/v1 |
| **Swagger Docs** | http://localhost:3000/api/docs |
| **Database** | localhost:5432 (from local machine) |

### Test API with cURL

```bash
# Send OTP
curl -X POST http://localhost:3000/v1/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"mobile_number": "+919876543210"}'

# Check console/logs for OTP value
docker logs cleardeed-backend | grep -i otp

# Verify OTP
curl -X POST http://localhost:3000/v1/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"mobile_number": "+919876543210", "otp": "123456"}'

# Get profile (use JWT from verify response)
curl -X GET http://localhost:3000/v1/profile \
  -H "Authorization: Bearer <jwt_token>"
```

---

## 📦 Service Details

### PostgreSQL Container
- **Name**: `cleardeed-postgres`
- **Image**: `postgres:16-alpine`
- **Port**: `5432:5432`
- **Username**: `cleardeed`
- **Password**: `cleardeed123`
- **Database**: `cleardeed_db`
- **Data Volume**: `postgres_data` (persists between restarts)
- **Health Check**: Automatic (5s interval, 5 retries)

### Backend Container
- **Name**: `cleardeed-backend`
- **Image**: Built from `backend/Dockerfile.dev`
- **Port**: `3000:3000`
- **Node Version**: `node:20-alpine`
- **Watch Mode**: ✅ Hot reload enabled (via nodemon)
- **Source Mount**: Live code updates reflected instantly
- **Health Check**: Automatic HTTP health check

### Network
- **Name**: `cleardeed-network` (bridge network)
- **Purpose**: Enables backend → postgres communication

---

## 🛠️ Troubleshooting

### Port Already in Use

If port 3000 or 5432 is already in use:

```bash
# Option 1: Stop conflicting service
docker stop <container_name>

# Option 2: Use different ports
# Edit docker-compose.yml:
# postgres: ports: ["5433:5432"]
# backend: ports: ["3001:3000"]

docker-compose up -d
```

### Database Connection Fails

```bash
# Check if postgres is healthy
docker ps
# STATUS should show "healthy" for postgres container

# Manually test connection
docker exec -it cleardeed-postgres psql -U cleardeed -d cleardeed_db

# Check postgres logs
docker logs cleardeed-postgres

# Reset database
docker-compose down -v
docker-compose up -d
```

### Backend Won't Start

```bash
# Check logs
docker logs cleardeed-backend

# Common issues:
# 1. Database not ready - wait 10 seconds & retry
# 2. Node modules issue - rebuild
docker-compose build --no-cache backend
docker-compose up -d backend

# 3. TypeScript error - check console
docker logs cleardeed-backend -f
```

### Code Changes Not Reflecting

```bash
# Ensure volume is mounted correctly
docker inspect cleardeed-backend | grep -A 5 Mounts

# Restart with dependency check
docker-compose down
docker-compose up -d --build

# Watch logs for changes
docker logs -f cleardeed-backend
```

---

## 📊 Monitoring

### View Resource Usage

```bash
# CPU, Memory, Network stats
docker stats

# Just backend
docker stats cleardeed-backend
```

### Health Status

```bash
# Check service health
docker-compose ps

# Manual health check
curl http://localhost:3000/v1/health

# Inside container
docker exec cleardeed-backend curl http://localhost:3000/v1/health
```

---

## 🔄 Development Workflow

### Normal Development

```bash
1. Start services:
   docker-compose up -d

2. Edit code in src/ folder
   Changes auto-reload in backend container

3. View logs in real-time:
   docker logs -f cleardeed-backend

4. Run npm commands:
   docker exec cleardeed-backend npm run lint
   docker exec cleardeed-backend npm test

5. Stop when done:
   docker-compose down
```

### Database Changes

```bash
# Create new migration
docker exec cleardeed-backend npx typeorm migration:create src/database/migrations/create_table_name

# Run migrations
docker exec cleardeed-backend npm run migrate

# Check database
docker exec -it cleardeed-postgres psql -U cleardeed -d cleardeed_db

# View tables
\dt

# Exit psql
\q
```

---

## 📁 File Structure

```
ClearDeed-Platform/
├── docker-compose.yml       ← Main orchestration file
├── backend/
│   ├── Dockerfile          ← Production image
│   ├── Dockerfile.dev      ← Development image
│   ├── package.json
│   ├── src/
│   ├── .env.development    ← Development config
│   └── ...
└── ...
```

---

## ⚙️ Environment Variables

### Default Development Config

Located in `backend/.env.development`:

```env
NODE_ENV=development
PORT=3000
CORS_ORIGIN=*

# Database
DB_HOST=postgres              # Container name
DB_PORT=5432
DB_USERNAME=cleardeed
DB_PASSWORD=cleardeed123
DB_NAME=cleardeed_db

# JWT
JWT_SECRET=dev_jwt_secret_key_change_in_production
JWT_EXPIRES_IN=24h

# Admin
ADMIN_MOBILE_NUMBER=+919999999999
```

### Customize for Local Development

Edit `backend/.env.development` if needed, then:

```bash
docker-compose down
docker-compose up -d
```

---

## 🚀 Production Deployment

When deploying to production:

1. Use `backend/Dockerfile` (production build, smaller image)
2. Update `.env.production` with real values
3. Use `docker-compose up -d` with updated env
4. Add volume backups for `postgres_data`

---

## 🧹 Cleanup & Reset

```bash
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune

# Remove unused volumes
docker volume prune

# Nuclear option: Reset everything
docker system prune -a --volumes
```

---

## 📖 Next Steps

After services are running:

1. ✅ Access Swagger API Docs: http://localhost:3000/api/docs
2. ✅ Test OTP authentication flow
3. ✅ Run migrations: `docker exec cleardeed-backend npm run migrate`
4. ✅ Seed database: `docker exec cleardeed-backend npm run seed`
5. ✅ Build Flutter app against http://localhost:3000

---

## 🆘 Support

**Common Issues Checklist:**

- [ ] Docker Desktop running?
- [ ] Ports 3000 & 5432 available?
- [ ] `docker-compose` version >= 3.8?
- [ ] File permissions correct?
- [ ] `.env.development` exists?

**Check Status:**
```bash
docker-compose ps
docker-compose logs -f
curl http://localhost:3000/api/docs
```

---

**Ready to run locally!** 🎉

Last Updated: April 8, 2026
