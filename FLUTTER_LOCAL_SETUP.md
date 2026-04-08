# 🚀 ClearDeed - Mixed Local + Docker Setup

Since Flutter web can be resource-intensive in Docker, here's the **recommended setup**:

## 📋 ARCHITECTURE

```
Your Machine:
├── Flutter App (Local) ← You run this
│   └── Connects to: http://localhost:3001
│
Docker Containers:
├── NestJS Backend API
│   └── Connected to: PostgreSQL
└── PostgreSQL Database
```

---

## ✅ SETUP OPTIONS

### Option A: Docker Backend + Local Flutter (RECOMMENDED)

**Step 1: Start Docker containers (Backend + Database)**
```bash
cd /c/Users/mallikharjunareddy_e/Workspace/ClearDeed-Platform

# Start backend and database only
docker-compose up -d postgres backend
```

**Step 2: Install Flutter locally (if not already installed)**
```bash
flutter doctor
```

If missing, download from: https://flutter.dev/docs/get-started/install

**Step 3: Run Flutter web app locally**
```bash
cd frontend-flutter

# Get dependencies
flutter pub get

# Run on web
flutter run -d chrome
```

**Result:**
```
✅ Backend API: http://localhost:3001
✅ Flutter App: http://localhost:XXXX (shown in console)
✅ Database: Connected via Docker
✅ Hot reload: Works perfectly
```

---

### Option B: Full Docker Setup (For CI/CD)

If you want everything in Docker:

```bash
docker-compose up -d --build
```

**Note:** First build takes 3-5 minutes. Subsequent builds faster.

---

## 🎯 RECOMMENDED WORKFLOW

**Terminal 1: Start Docker containers**
```bash
docker-compose up -d postgres backend

# Watch backend logs
docker-compose logs -f backend
```

**Terminal 2: Start Flutter web**
```bash
cd frontend-flutter
flutter run -d chrome
```

**Terminal 3: (Optional) Watch database**
```bash
docker-compose logs -f postgres
```

**Browser:** Flutter app opens automatically at `http://localhost:XXXXX`

---

## 🔧 QUICK START (Mixed Setup)

```bash
# 1. Start Docker backend
docker-compose up -d postgres backend

# 2. In another terminal, start Flutter
cd frontend-flutter
flutter run -d chrome

# 3. That's it! App opens automatically
```

---

## ✨ ADVANTAGES OF MIXED SETUP

✅ **Faster**: No Docker build time for Flutter
✅ **Better DX**: Native hot reload experience
✅ **Easier**: Matches typical Flutter dev environment
✅ **Flexible**: Can switch between web/Android/iOS
✅ **Cleaner**: Database + API isolated in Docker

---

## 📊 SETUP COMPARISON

| Aspect | Docker Only | Docker Backend + Local Flutter |
|--------|-------------|-------------------------------|
| Setup Time | 3-5 min | 1-2 min |
| Hot Reload | ~5 sec | ~2 sec |
| Resources | Higher | Lower |
| Complexity | More | Simpler |
| **Recommended** | CI/CD | Development |

---

## 🌐 ACCESS POINTS

Once running:

| Service | URL | Command |
|---------|-----|---------|
| Flutter App | http://localhost:XXXXX | `flutter run -d chrome` |
| Backend API | http://localhost:3001 | Docker running |
| Swagger Docs | http://localhost:3001/api/docs | Auto open |
| Database | localhost:5432 | Docker running |

---

## 📝 FLUTTER WEB COMMANDS

```bash
cd /c/Users/mallikharjunareddy_e/Workspace/ClearDeed-Platform/frontend-flutter

# Run on web
flutter run -d chrome

# Run on Firefox
flutter run -d firefox

# Build production web app
flutter build web

# Run with debug info
flutter run -d chrome -v
```

---

## 🔌 API CONFIGURATION

Default backend URL is:
```
http://localhost:3001
```

This is already configured in the Flutter app. If you need to change it:

**File:** `lib/services/api_client.dart`

```dart
final String baseUrl = 'http://localhost:3001';  // Change this
```

---

## ✅ COMPLETE WORKFLOW

```bash
# Terminal 1
cd /c/Users/mallikharjunareddy_e/Workspace/ClearDeed-Platform
docker-compose up -d postgres backend

# Wait 10 seconds for backend to start...

# Terminal 2
cd frontend-flutter
flutter run -d chrome
```

**Result:**
- Backend running in Docker ✅
- Flutter web app opens in Chrome ✅
- Hot reload enabled ✅
- Database connected ✅
- Ready to develop! 🚀

---

## 🎓 WHY THIS APPROACH?

1. **Development Speed**: Local Flutter builds faster than Docker
2. **Hot Reload**: Works better with local Flutter CLI
3. **Multiple Targets**: Can test on Android/iOS/Web from same code
4. **Less Resource**: Docker only runs essential backend services
5. **Team Friendly**: Matches standard Flutter dev setup

---

## 🐳 WHEN TO USE FULL DOCKER?

- Building Docker images for production
- CI/CD pipeline testing
- Running in containerized cloud environment
- Reproducing exact production setup locally

---

## 📚 NEXT STEPS

1. ✅ Start Docker backend:
   ```bash
   docker-compose up -d postgres backend
   ```

2. ✅ Check backend is running:
   ```bash
   curl http://localhost:3001/v1/health
   ```

3. ✅ Run Flutter web:
   ```bash
   cd frontend-flutter
   flutter run -d chrome
   ```

4. ✅ Test the app:
   - Enter phone number
   - Get OTP from logs
   - Login and explore

---

## 🆘 ISSUES?

### Flutter won't start
```bash
# Install/update Flutter
flutter upgrade

# Check setup
flutter doctor

# Clean build
flutter clean
rm -rf build/
flutter run -d chrome
```

### Cannot connect to API
```bash
# Check backend is running
docker-compose ps backend
# Should show: Up (healthy)

# Check health
curl http://localhost:3001/v1/health

# View backend logs
docker-compose logs backend -f
```

### Port conflict
```bash
# Find what's using port
netstat -ano | grep 3001

# Kill process or restart Docker
docker-compose restart
```

---

**RECOMMENDED: Use Mixed Setup (Docker Backend + Local Flutter)**

This gives you the **best development experience**! 🎉

Last Updated: April 8, 2026
