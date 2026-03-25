# 🍲 Bếp Việt – Smart Cooking Platform (NestJS + Flutter)

> A scalable cooking platform that provides personalized meal suggestions, pantry management, and real-time user interaction, built with NestJS and Flutter.

---

## 🚀 Project Overview

**Bếp Việt** is a mobile-first cooking platform designed to help users make smarter cooking decisions based on:

- Available ingredients (pantry)
- Budget
- Region & season
- Personal preferences

The system goes beyond a simple recipe app by integrating:
- smart suggestions
- meal planning
- pantry intelligence
- real-time features
- scalable backend architecture

---

## 🛠 Tech Stack

### Backend
- NestJS (Modular Monolith Architecture)
- TypeScript
- MySQL
- Redis (caching)
- JWT + RBAC
- Swagger (API documentation)
- Cloudflare R2 (image storage)
- Socket.IO

### Mobile
- Flutter
- Bloc state management
- Dio + Retrofit
- go_router
- socket_io_client

---

## 🧠 My Contributions

- Designed **modular NestJS architecture** for scalable backend development
- Built RESTful APIs for:
  - recipes
  - pantry
  - meal plans
  - suggestions
- Integrated **Redis caching** to reduce query latency (>50%)
- Implemented **Cloudflare R2** for image storage (reduce DB load ~70%)
- Developed **AI-powered suggestion system** using Gemini API
- Designed relational database with optimized queries and indexing
- Implemented authentication with JWT and role-based access control
- Structured system for future scalability (modular domain-based design)

---

## ✨ Key Features

### Smart Suggestions
- Suggest meals based on pantry items
- AI-assisted recommendations
- Region and season-based filtering

### Pantry Management
- Track ingredients
- Detect expiring items
- Suggest recipes based on available food

### Meal Planning
- Weekly meal planning
- Auto-generate plans
- Optimize based on budget

### Community & Interaction
- Ratings & comments
- Notifications
- Real-time updates (Socket.IO)

---

## 🧱 Architecture

The backend follows a **modular monolith architecture**:

- Domain-based modules (recipes, pantry, suggestions, etc.)
- Clear separation of concerns
- Scalable and maintainable system design

---

## 📁 Project Structure

```bash
Bep-Viet/
├── backend/
│   ├── src/
│   │   ├── common/
│   │   ├── config/
│   │   ├── database/
│   │   ├── modules/
│   │   │   ├── auth/
│   │   │   ├── recipes/
│   │   │   ├── pantry/
│   │   │   ├── meal-plans/
│   │   │   ├── suggestions/
│   │   │   ├── users/
│   │   │   ├── notifications/
│   │   │   ├── subscriptions/
│   │   │   └── payments/
│   │   └── main.ts
│
├── mobile/
│   ├── lib/
│   │   ├── core/
│   │   ├── data/
│   │   └── presentation/
│   └── main.dart
│
└── docker-compose.yml
```

---

## ⚡ Performance Optimization

- Reduced API response time using Redis caching
- Optimized database queries with indexing
- Offloaded media storage to Cloudflare R2
- Improved system scalability with modular architecture

---

## 📌 Highlights

- Real-world scalable backend system
- AI integration (Gemini API)
- Advanced domain design (pantry + meal planning)
- Performance optimization with Redis & CDN
- Clean architecture with NestJS

---

## 👨‍💻 Author

**Thắng Phạm Xuân**  
GitHub: https://github.com/ThangphamDev
