# Bếp Việt - Smart Vietnamese Cooking App

Ứng dụng giải quyết "Hôm nay ăn gì?" với gợi ý theo vùng miền, mùa vụ, ngân sách.

## 🚀 Tech Stack

- **Backend**: Node.js + Express + TypeScript
- **Database**: MySQL 8.0
- **Mobile**: Flutter + Dart
- **Infrastructure**: Docker + Docker Compose + Ngrok

## 📁 Project Structure

```
bep-viet/
├── backend/           # Node.js API server
├── mobile/           # Flutter mobile app
├── docs/             # Documentation
├── infra/            # Infrastructure configs
└── docker-compose.yml
```

## 🛠️ Development Setup

### Prerequisites
- Docker & Docker Compose
- Node.js 18+ (for local development)
- MySQL 8.0+ (if running locally)

### Quick Start

1. **Clone repository**
```bash
git clone <repo-url>
cd bep-viet
```

2. **Start services with Docker**
```bash
docker-compose up -d
```

3. **Access services**
- Backend API: http://localhost:8080
- Mobile App: Run `flutter run` in mobile/ directory
- Database Admin: http://localhost:8081
- Database: localhost:3306
- Ngrok Dashboard: http://localhost:4040

### Local Development

1. **Backend**
```bash
cd backend
npm install
npm run dev
```

2. **Mobile App**
```bash
cd mobile
flutter pub get
flutter run
```

## 📊 Database Schema

Database được khởi tạo tự động với schema đầy đủ từ `bepviet_full_schema.sql`:
- 22+ bảng core (users, recipes, ingredients, etc.)
- Hỗ trợ đa vùng miền (Bắc/Trung/Nam)
- Quản lý mùa vụ và giá cả
- Premium features (family profiles, subscriptions)
- Community features (recipes, comments, ratings)

## 🎯 Features

### Core Features
- ✅ **Smart Suggestions**: Gợi ý món ăn theo vùng miền, mùa vụ, ngân sách
- ✅ **Recipe Management**: Quản lý công thức với variants theo vùng
- ✅ **Meal Planning**: Lập kế hoạch bữa ăn tuần
- ✅ **Shopping Lists**: Tạo danh sách mua sắm từ meal plan
- ✅ **Pantry Management**: Quản lý tủ lạnh và cảnh báo hết hạn

### Premium Features
- 🔒 **Family Profiles**: Hồ sơ gia đình với khẩu vị và dị ứng
- 🔒 **Nutrition Advisory**: Cảnh báo dinh dưỡng theo hồ sơ
- 🔒 **Advanced Planning**: Kế hoạch nâng cao với AI

### Community Features
- 👥 **Community Recipes**: Đăng và chia sẻ công thức
- 💬 **Comments & Ratings**: Bình luận và đánh giá
- 🏆 **Featured Content**: Nội dung nổi bật

## 🔧 API Documentation

API được document với OpenAPI/Swagger tại: http://localhost:8080/api-docs

### Key Endpoints
- `POST /v1/suggestions/search` - Tìm kiếm gợi ý món ăn
- `GET /v1/recipes` - Danh sách công thức
- `POST /v1/meal-plans/generate` - Tạo kế hoạch bữa ăn
- `POST /v1/shopping-lists/from-meal-plan` - Tạo danh sách mua sắm

## 🎨 UI Design

Giao diện được thiết kế với:
- **Màu chủ đạo**: Xanh lá gradient (#10B981 → #059669)
- **Màu phụ**: Trắng (#FFFFFF)
- **Text**: Đen gradient (#111827 → #374151)
- **Style**: Hiện đại, clean, responsive

## 🚀 Deployment

### Production
```bash
docker-compose -f docker-compose.prod.yml up -d
```

### Environment Variables
Copy `.env.example` to `.env` and configure:
```env
NODE_ENV=production
DB_HOST=your-db-host
JWT_SECRET=your-secret-key
```

## 📝 Development Roadmap

- [x] **Phase 0**: Project setup & infrastructure
- [ ] **Phase 1**: Database & Authentication
- [ ] **Phase 2**: Recipes & Smart Suggestions
- [ ] **Phase 3**: Meal Planning & Shopping
- [ ] **Phase 4**: Premium Features
- [ ] **Phase 5**: Community & Moderation
- [ ] **Phase 6**: Mobile App (Flutter)

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Vietnamese cuisine inspiration
- Community contributors
- Open source libraries
