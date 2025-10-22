# Family API Integration

## Tổng quan
Đã cập nhật models và services để tích hợp với Family API backend thực tế.

## Các thay đổi chính

### 1. FamilyProfileModel
- **Trước**: Có các field phức tạp như `ownerUserId`, `memberCount`, `createdAt`, `updatedAt`
- **Sau**: Đơn giản hóa với `id`, `name`, `note`, `members`
- **Lý do**: Phù hợp với API response thực tế từ backend

### 2. FamilyMemberModel  
- **Trước**: Có các enum phức tạp như `SpiceLevel`, `DietFlag`, `healthConditions`
- **Sau**: Đơn giản với `id`, `familyId`, `name`, `age`, `dietaryRestrictions`, `allergies`
- **Lý do**: Phù hợp với database schema thực tế

### 3. API Service
- **Cập nhật endpoints** để khớp với backend:
  - `GET /family/profiles` - Lấy danh sách family profiles
  - `POST /family/profiles` - Tạo family profile mới
  - `POST /family/profiles/:id/members` - Thêm thành viên

### 4. Family Service
- **Tạo service riêng** để quản lý Family API
- **Các methods chính**:
  - `getUserFamilyProfiles()` - Lấy danh sách profiles
  - `createFamilyProfile()` - Tạo profile mới
  - `addFamilyMember()` - Thêm thành viên
  - `getFamilyProfileById()` - Lấy chi tiết profile

## Cách sử dụng

### 1. Import service
```dart
import 'package:bepviet_mobile/core/services/family_service.dart';
import 'package:bepviet_mobile/core/models/family_model.dart';
```

### 2. Lấy danh sách family profiles
```dart
final familyService = FamilyService();
final profiles = await familyService.getUserFamilyProfiles();
```

### 3. Tạo family profile mới
```dart
final newProfile = await familyService.createFamilyProfile(
  name: 'My Family',
  note: 'Family description',
);
```

### 4. Thêm thành viên
```dart
final member = await familyService.addFamilyMember(
  familyId: newProfile.id,
  name: 'John Doe',
  age: 30,
  dietaryRestrictions: 'Vegetarian',
  allergies: 'Peanuts',
);
```

## Test Integration

Chạy file test để kiểm tra tích hợp:
```bash
dart test_family_integration.dart
```

## Lưu ý

1. **Authentication**: API cần JWT token, đảm bảo đã đăng nhập
2. **Error Handling**: Tất cả methods đều có try-catch
3. **Backend Requirements**: Cần backend server đang chạy
4. **Database**: Đảm bảo database có các bảng `family_profiles` và `family_members`

## API Endpoints Backend

```typescript
// GET /family/profiles - Lấy danh sách family profiles
// POST /family/profiles - Tạo family profile mới  
// POST /family/profiles/:id/members - Thêm thành viên
```

## Database Schema

```sql
-- family_profiles table
CREATE TABLE family_profiles (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  note TEXT
);

-- family_members table  
CREATE TABLE family_members (
  id INT PRIMARY KEY AUTO_INCREMENT,
  family_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  age INT NOT NULL,
  dietary_restrictions TEXT,
  allergies TEXT
);
```
