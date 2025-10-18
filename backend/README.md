# BẾP VIỆT - BACKEND API

Backend API cho ứng dụng Bếp Việt - ứng dụng gợi ý món ăn theo vùng miền, mùa vụ và ngân sách.

## 🚀 Tính năng chính

- **Authentication**: Đăng ký, đăng nhập với JWT
- **Recipes**: Quản lý công thức nấu ăn với variants theo vùng miền
- **Suggestions**: Gợi ý món ăn thông minh theo vùng/mùa/ngân sách
- **Meal Plans**: Lập kế hoạch bữa ăn tuần
- **Pantry**: Quản lý tủ lạnh và cảnh báo hết hạn
- **Ingredients**: Quản lý nguyên liệu và giá cả theo vùng
- **Regions & Seasons**: Hỗ trợ 3 vùng miền và 4 mùa

## 🛠️ Tech Stack

- **Framework**: NestJS + TypeScript
- **Database**: MySQL 8
- **Authentication**: JWT + Passport
- **Validation**: class-validator + class-transformer
- **Documentation**: Swagger/OpenAPI

## 📦 Cài đặt

```bash
# Cài đặt dependencies
npm install

# Copy file environment
cp env.example .env

# Chạy migrations (cần MySQL)
npm run migration:fresh

# Chạy development server
npm run start:dev
```

## 🔧 Cấu hình

Cập nhật file `.env`:

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

## 📚 API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Đăng ký
- `POST /api/v1/auth/login` - Đăng nhập
- `POST /api/v1/auth/refresh` - Refresh token
- `POST /api/v1/auth/logout` - Đăng xuất

### Users
- `GET /api/v1/users/me` - Thông tin user hiện tại
- `PATCH /api/v1/users/me` - Cập nhật profile

### Regions
- `GET /api/v1/regions` - Danh sách vùng miền
- `GET /api/v1/regions/subregions` - Danh sách tỉnh/thành
- `GET /api/v1/regions/with-subregions` - Vùng miền với tỉnh/thành

### Seasons
- `GET /api/v1/seasons` - Danh sách mùa
- `GET /api/v1/seasons/current` - Mùa hiện tại
- `GET /api/v1/seasons/:code` - Thông tin mùa theo code

### Ingredients
- `GET /api/v1/ingredients` - Danh sách nguyên liệu
- `GET /api/v1/ingredients/search` - Tìm kiếm nguyên liệu
- `GET /api/v1/ingredients/:id` - Chi tiết nguyên liệu
- `GET /api/v1/ingredients/:id/prices` - Giá nguyên liệu theo vùng

### Recipes
- `GET /api/v1/recipes` - Danh sách công thức
- `GET /api/v1/recipes/:id` - Chi tiết công thức
- `GET /api/v1/recipes/:id/ingredients` - Nguyên liệu của công thức
- `GET /api/v1/recipes/:id/variants` - Variants theo vùng

### Suggestions
- `POST /api/v1/suggestions/search` - Tìm kiếm gợi ý món ăn
- `GET /api/v1/suggestions/pantry` - Gợi ý dựa trên tủ lạnh

### Meal Plans
- `GET /api/v1/meal-plans` - Danh sách kế hoạch bữa ăn
- `POST /api/v1/meal-plans` - Tạo kế hoạch mới
- `POST /api/v1/meal-plans/generate` - Tạo kế hoạch tự động
- `GET /api/v1/meal-plans/:userId/:weekStartDate` - Chi tiết kế hoạch

### Pantry
- `GET /api/v1/pantry` - Danh sách tủ lạnh
- `POST /api/v1/pantry` - Thêm nguyên liệu vào tủ lạnh
- `PUT /api/v1/pantry/:id` - Cập nhật nguyên liệu
- `DELETE /api/v1/pantry/:id` - Xóa nguyên liệu
- `GET /api/v1/pantry/expiring` - Nguyên liệu sắp hết hạn
- `GET /api/v1/pantry/suggestions` - Gợi ý món ăn từ tủ lạnh

## 🔐 Authentication

API sử dụng JWT Bearer token. Thêm header:

```
Authorization: Bearer <your_jwt_token>
```

## 📊 Database Schema

Database bao gồm 22+ bảng chính:

- **Users & Auth**: users, user_preferences, devices, subscriptions
- **Geographic**: geo_regions, geo_subregions
- **Ingredients**: ingredients, ingredient_categories, ingredient_prices, ingredient_seasonality
- **Recipes**: recipes, recipe_ingredients, recipe_tags, recipe_variants
- **Meal Planning**: meal_plans, meal_plan_items
- **Pantry**: pantry_items
- **Shopping**: shopping_lists, shopping_list_items
- **Community**: community_recipes, recipe_comments, recipe_ratings
- **Seasons**: seasons
- **Units**: units, unit_conversions

## 🧪 Testing

```bash
# Unit tests
npm run test

# E2E tests
npm run test:e2e

# Test coverage
npm run test:cov
```

## 📝 Scripts

```bash
npm run start:dev      # Development server
npm run start:prod     # Production server
npm run build          # Build project
npm run migration:migrate  # Run migrations
npm run migration:seed     # Run seeds
npm run migration:fresh    # Reset and seed database
```

## 🌟 Tính năng nổi bật

### Smart Suggestions
- Gợi ý món ăn dựa trên vùng miền, mùa vụ, ngân sách
- Ưu tiên nguyên liệu có sẵn trong tủ lạnh
- Tính toán chi phí và điểm số thông minh

### Regional Variants
- Mỗi món ăn có thể có variants cho 3 vùng miền
- Giá nguyên liệu khác nhau theo vùng
- Tính toán mùa vụ theo từng vùng

### Pantry Management
- Quản lý tủ lạnh với cảnh báo hết hạn
- Gợi ý món ăn dựa trên nguyên liệu có sẵn
- Theo dõi vị trí lưu trữ (tủ lạnh, ngăn đông, kệ)

## 📖 API Documentation

Khi server chạy, truy cập Swagger UI tại:
```
http://localhost:8080/api/v1
```

## 🤝 Contributing

1. Fork repository
2. Tạo feature branch
3. Commit changes
4. Push to branch
5. Tạo Pull Request

## 📄 License

MIT License