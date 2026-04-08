# 🐳 ClearDeed Docker - Quick Reference Card

## 🚀 START/STOP

```bash
# Start everything
docker-compose up -d

# Start with logs
docker-compose up

# Stop everything (keep data)
docker-compose stop

# Stop and remove (keep data volumes)
docker-compose down

# Full reset (DELETE ALL DATA ⚠️)
docker-compose down -v
```

## 📊 STATUS & LOGS

```bash
# View all containers
docker-compose ps

# View all logs
docker-compose logs -f

# View backend logs only
docker-compose logs -f backend

# View postgres logs only
docker-compose logs -f postgres

# Last 50 lines
docker-compose logs --tail=50
```

## 🔌 API TESTING

```bash
# Check health
curl http://localhost:3000/v1/health

# Swagger UI
open http://localhost:3000/api/docs

# Send OTP
curl -X POST http://localhost:3000/v1/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"mobile_number": "+919876543210"}'

# Check backend logs for OTP (dev mode only)
docker logs cleardeed-backend | grep -i otp
```

## 💾 DATABASE OPERATIONS

```bash
# Access PostgreSQL
docker exec -it cleardeed-postgres psql -U cleardeed -d cleardeed_db

# In PostgreSQL CLI:
\dt                      # List tables
\d table_name            # Describe table
SELECT COUNT(*) FROM users;  # Count users
\q                       # Exit

# Run migrations
docker exec cleardeed-backend npm run migrate

# Seed database
docker exec cleardeed-backend npm run seed

# Backup database
docker exec cleardeed-postgres pg_dump -U cleardeed cleardeed_db > backup.sql

# Restore database
docker exec -i cleardeed-postgres psql -U cleardeed cleardeed_db < backup.sql
```

## 🛠️ BACKEND MAINTENANCE

```bash
# npm commands
docker exec cleardeed-backend npm run build
docker exec cleardeed-backend npm run lint
docker exec cleardeed-backend npm test

# Access shell
docker exec -it cleardeed-backend sh

# View installed packages
docker exec cleardeed-backend npm list

# Rebuild backend image
docker-compose build backend

# Rebuild and restart
docker-compose up -d --build backend
```

## 🐳 DOCKER CLEANUP

```bash
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune

# Remove unused volumes
docker volume prune

# View volumes
docker volume ls
```

## ⚡ PERFORMANCE

```bash
# CPU/Memory stats
docker stats

# Watch specific container
docker stats cleardeed-backend

# View container info
docker inspect cleardeed-backend

# View network
docker network ls
docker network inspect cleardeed-network
```

## 🔍 TROUBLESHOOTING

```bash
# Check service health
docker-compose ps
# STATUS should show (healthy)

# Verify network
docker network inspect cleardeed-network

# Test database connection from backend
docker exec cleardeed-backend sh -c "nc -zv postgres 5432"

# Rebuild everything
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d

# Check Docker resources
docker system df
```

## 📝 COMMON ISSUES & FIXES

| Issue | Fix |
|-------|-----|
| Port 3000 in use | `docker-compose down`, then check `netstat -ano \| findstr :3000` |
| Port 5432 in use | `docker-compose down`, then check `netstat -ano \| findstr :5432` |
| Database connection error | Wait 10s, check `docker logs cleardeed-postgres` |
| Code changes not reflecting | `docker-compose restart backend` |
| Out of disk space | `docker system prune -a --volumes` |
| ModuleNotFoundError | `docker-compose up -d --build backend` |

## 🆕 ADD NEW DEPENDENCY

```bash
# Add to backend
docker exec cleardeed-backend npm install <package-name>

# Or rebuild
docker-compose up -d --build backend
```

## 🔐 ENVIRONMENT VARIABLES

Edit `backend/.env.development`, then:

```bash
docker-compose restart backend
# OR
docker-compose down
docker-compose up -d --build
```

---

**More help:** See `DOCKER_SETUP.md` for comprehensive guide
