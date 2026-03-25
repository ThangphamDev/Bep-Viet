# 🍲 Bếp Việt – Smart Vietnamese Cooking Assistant

> A monorepo for a smart Vietnamese cooking platform, including a **NestJS backend API** and a **Flutter mobile app** that help users discover recipes, plan meals, manage pantry items, and receive personalized cooking suggestions.

---

## 🚀 Overview

**Bếp Việt** is a mobile-first cooking platform built for Vietnamese users.  
The project focuses on solving practical daily cooking problems such as:

- What should I cook today?
- Which dishes match the ingredients I already have?
- Which meals fit my budget, region, and season?
- How can I plan meals for the whole week?
- How can I track pantry items and avoid waste?

This repository is organized as a **monorepo** and currently includes:

- **Backend API**: NestJS service for authentication, recipe management, meal planning, pantry, community, subscriptions, notifications, and smart suggestions
- **Mobile App**: Flutter application for end users
- **Infrastructure**: Docker Compose setup with MySQL, Redis, and Adminer

---

## ✨ Core Features

### Smart Cooking Experience
- Personalized dish suggestions based on:
  - available ingredients
  - region
  - season
  - budget
- Regional recipe variants
- Ingredient pricing by region

### Meal Planning & Pantry
- Weekly meal planning
- Auto-generated meal plans
- Pantry management
- Expiration reminders
- Suggestions based on pantry items

### Community & User Features
- Authentication with JWT
- User profile management
- Community recipes
- Ratings and comments
- Notifications
- Premium/subscription-related modules

### Platform & Infrastructure
- Swagger/OpenAPI documentation
- Redis caching support
- Cloudflare R2 image storage integration
- Docker-based local development environment

---

## 🛠 Tech Stack

### Backend
- **NestJS**
- **TypeScript**
- **MySQL 8**
- **JWT + Passport**
- **class-validator / class-transformer**
- **Swagger / OpenAPI**
- **Redis**
- **Socket.IO**
- **AWS SDK / Cloudflare R2 compatible storage**

### Mobile
- **Flutter**
- **Dart**
- **go_router**
- **flutter_bloc**
- **Dio**
- **Retrofit**
- **socket_io_client**
- **shared_preferences**
- **sqflite**
- **local_auth**
- **flutter_secure_storage**
- **google_maps_flutter**
- **flutter_local_notifications**

### DevOps / Local Environment
- **Docker Compose**
- **Adminer**
- **MySQL container**
- **Redis container**

---

## 🧱 Architecture

### Monorepo Structure
The repository is split into two main applications:

- `backend/` → NestJS REST API
- `mobile/` → Flutter app

### Backend Architecture
The backend follows a modular NestJS structure with separated layers for:

- common utilities
- configuration
- database
- business modules

### Mobile Architecture
The Flutter app is organized into:

- `core/`
- `data/`
- `presentation/`

This makes the mobile codebase easier to scale and maintain, especially with feature-based UI organization.

---

## 📁 Project Structure

```bash
Bep-Viet/
├── backend/
│   ├── scripts/                    # Database/data/admin utility scripts
│   ├── src/
│   │   ├── common/                 # Shared utilities, guards, interceptors, helpers
│   │   ├── config/                 # App configuration
│   │   ├── database/               # Migrations, seeds, DB setup
│   │   ├── modules/
│   │   │   ├── analytics/          # Analytics features
│   │   │   ├── auth/               # Authentication & authorization
│   │   │   ├── comments/           # Recipe/community comments
│   │   │   ├── community/          # Community features
│   │   │   ├── family/             # Family-related flows
│   │   │   ├── gemini/             # AI/Gemini-related integration
│   │   │   ├── ingredients/        # Ingredient management
│   │   │   ├── meal-plans/         # Meal planning
│   │   │   ├── moderation/         # Moderation features
│   │   │   ├── notifications/      # Notification system
│   │   │   ├── pantry/             # Pantry management
│   │   │   ├── payments/           # Payment-related features
│   │   │   ├── prices/             # Ingredient pricing
│   │   │   ├── ratings/            # Ratings/reviews
│   │   │   ├── recipes/            # Recipes and variants
│   │   │   ├── redis/              # Cache integration
│   │   │   ├── regions/            # Regions and subregions
│   │   │   ├── seasons/            # Seasonal logic
│   │   │   ├── shopping/           # Shopping list features
│   │   │   ├── storage/            # File/image storage
│   │   │   ├── subscriptions/      # Subscription features
│   │   │   ├── suggestions/        # Smart recipe suggestions
│   │   │   └── users/              # User management
│   │   ├── app.module.ts
│   │   └── main.ts
│   ├── test/                       # Test files
│   ├── Dockerfile
│   ├── README.md
│   └── REDIS_R2_SETUP.md
│
├── mobile/
│   ├── android/
│   ├── ios/
│   ├── web/
│   ├── windows/
│   ├── linux/
│   ├── macos/
│   ├── assets/
│   │   └── logo/
│   ├── lib/
│   │   ├── core/                   # Core configs, theme, constants
│   │   ├── data/                   # Data sources and repositories
│   │   ├── presentation/
│   │   │   ├── features/           # Feature-based screens/modules
│   │   │   ├── routes/             # App routing
│   │   │   └── widgets/            # Shared UI widgets
│   │   └── main.dart
│   ├── test/
│   ├── pubspec.yaml
│   └── README.md
│
├── docker-compose.yml              # MySQL + Backend + Redis + Adminer
├── docker.env
└── README.md
```

---

## 🔌 Backend Capabilities

The backend exposes REST APIs for major product domains, including:

- **Authentication**
  - register
  - login
  - refresh token
  - logout

- **Users**
  - get current profile
  - update profile

- **Regions & Seasons**
  - regions
  - subregions
  - current season

- **Ingredients**
  - search ingredients
  - ingredient detail
  - regional prices

- **Recipes**
  - recipe list
  - recipe detail
  - recipe ingredients
  - regional variants

- **Suggestions**
  - smart search suggestions
  - pantry-based suggestions

- **Meal Plans**
  - create weekly meal plans
  - auto-generate meal plans

- **Pantry**
  - add/update/delete pantry items
  - expiring items
  - pantry suggestions

Swagger documentation is available when the backend is running.

---

## 📱 Mobile App Highlights

The Flutter app is not just a basic UI shell.  
From the current codebase, it already initializes and coordinates:

- authentication flow
- premium-related state
- meal plan state
- shopping list state
- pantry state
- notifications state
- websocket connection
- push notifications
- app routing with `go_router`

This indicates the mobile app is being built with a more structured, scalable architecture rather than a prototype-only approach.

---

## 🐳 Run with Docker

At the root of the project:

```bash
docker compose up --build
```

Included services:
- **MySQL**
- **Backend API**
- **Adminer**
- **Redis**

### Default exposed ports
- Backend: `8080`
- Adminer: `8081`
- MySQL: `3306`
- Redis: `6379`

---

## ⚙️ Local Development

### 1. Run backend locally

```bash
cd backend
npm install
cp env.example .env
npm run migration:fresh
npm run start:dev
```

### Example backend environment variables

```env
NODE_ENV=development
PORT=8080
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASS=your_password
DB_NAME=bepviet
JWT_SECRET=your_jwt_secret
REFRESH_SECRET=your_refresh_secret
```

### 2. Run mobile app

```bash
cd mobile
flutter pub get
flutter run
```

---

## 🧪 Testing

### Backend
```bash
cd backend
npm run test
npm run test:e2e
npm run test:cov
```

---

## ☁️ Storage & Performance

The repository also includes additional setup for:

- **Redis caching**
- **Cloudflare R2 image storage**

This improves:
- API response speed
- image delivery efficiency
- database size and bandwidth usage

It also makes the project more production-oriented compared to a typical classroom CRUD app.

---

## 📌 Why This Project Stands Out

- Built as a **monorepo**
- Combines **mobile app + backend API + infrastructure**
- Solves a localized, practical problem for Vietnamese users
- Goes beyond CRUD with:
  - smart suggestions
  - pantry intelligence
  - meal planning
  - community modules
  - caching
  - storage integration
  - subscription/payment modules

---

## 🛣 Roadmap Suggestions

Potential next improvements for the project:

- Complete and polish all mobile user flows
- Add CI/CD pipeline
- Add production deployment guide
- Improve API test coverage
- Add architecture diagrams
- Add screenshots / demo GIFs
- Add release/versioning strategy
- Add observability and monitoring

---

## 👨‍💻 Author

**Thắng Phạm Xuân**  
GitHub: [ThangphamDev](https://github.com/ThangphamDev)

---

## 📄 License

Please update the license section according to your intended usage.  
The backend package is currently marked `UNLICENSED`, while some docs mention MIT, so this should be standardized before publishing publicly.
