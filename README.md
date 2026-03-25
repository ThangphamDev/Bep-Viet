# Bếp Việt

Ứng dụng hỗ trợ nấu ăn thông minh dành cho người dùng Việt Nam, tập trung vào việc **gợi ý món ăn theo vùng miền, mùa vụ, ngân sách và nguyên liệu sẵn có**.

Repo này được tổ chức theo mô hình **monorepo**, bao gồm:

- **Mobile App**: Flutter application cho người dùng cuối
- **Backend API**: NestJS service cung cấp REST API, authentication, gợi ý món ăn, meal planning, pantry, notifications, subscriptions, v.v.

---

## Mục lục

- [Tổng quan](#tổng-quan)
- [Tính năng nổi bật](#tính-năng-nổi-bật)
- [Kiến trúc hệ thống](#kiến-trúc-hệ-thống)
- [Cấu trúc thư mục](#cấu-trúc-thư-mục)
- [Tech Stack](#tech-stack)
- [Yêu cầu môi trường](#yêu-cầu-môi-trường)
- [Khởi chạy nhanh với Docker](#khởi-chạy-nhanh-với-docker)
- [Chạy local cho backend](#chạy-local-cho-backend)
- [Chạy mobile app](#chạy-mobile-app)
- [API Documentation](#api-documentation)
- [Scripts hữu ích](#scripts-hữu-ích)
- [Roadmap](#roadmap)
- [Định hướng cải thiện](#định-hướng-cải-thiện)
- [Contributing](#contributing)
- [License](#license)

---

## Tổng quan

**Bếp Việt** được xây dựng để giải quyết bài toán lên món ăn hằng ngày theo ngữ cảnh thực tế của người dùng:

- Hôm nay nên ăn gì?
- Món nào phù hợp với **nguyên liệu đang có trong tủ lạnh**?
- Món nào hợp **mùa**, **vùng miền** và **ngân sách**?
- Làm sao để lên **meal plan** cho cả tuần?
- Làm sao để theo dõi nguyên liệu sắp hết hạn và tối ưu đi chợ?

Ứng dụng hướng tới trải nghiệm nấu ăn thông minh, cá nhân hóa và gần với thói quen ẩm thực Việt Nam.

---

## Tính năng nổi bật

### Mobile App
- Đăng nhập / xác thực người dùng
- Điều hướng app với router rõ ràng
- Quản lý trạng thái bằng BLoC/Cubit
- Tích hợp Google Sign-In, biometric auth
- Hỗ trợ push notification và websocket notification
- Meal planner, shopping list, pantry management
- Tối ưu trải nghiệm UI với animation, cached image, shimmer

### Backend API
- JWT Authentication / Authorization
- Quản lý người dùng và hồ sơ cá nhân
- Quản lý công thức nấu ăn và biến thể theo vùng miền
- Gợi ý món ăn thông minh theo mùa, vùng và ngân sách
- Meal planning theo tuần
- Pantry management + cảnh báo nguyên liệu sắp hết hạn
- Shopping list
- Community, comments, ratings
- Notifications, subscriptions, payments
- Redis, storage và tích hợp AI/Gemini module

---

## Kiến trúc hệ thống

```text
Bep-Viet
├── mobile/    # Flutter app
└── backend/   # NestJS API
