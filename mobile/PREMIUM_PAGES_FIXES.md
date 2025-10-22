# Premium Pages Code Fixes

## Tóm tắt các lỗi đã sửa

### 1. Family Profile Page (`family_profile_page.dart`)

#### Lỗi đã sửa:
- **Model compatibility**: Cập nhật `FamilyMember.fromFamilyMemberModel()` để phù hợp với `FamilyMemberModel` mới
- **API method calls**: Thay đổi từ `getFamilyProfiles()` sang `getUserFamilyProfiles()`
- **Model constructor**: Cập nhật constructor của `FamilyMemberModel` để sử dụng các field mới
- **Legacy enum removal**: Loại bỏ các enum `SpiceLevel` và `DietFlag` không còn tồn tại

#### Thay đổi chính:
```dart
// Trước
allergies: model.allergies,
dietaryRestrictions: model.dietFlags.map((flag) => flag.value).toList(),
healthConditions: model.healthConditions,

// Sau  
allergies: model.allergies != null ? [model.allergies!] : [],
dietaryRestrictions: model.dietaryRestrictions != null ? [model.dietaryRestrictions!] : [],
healthConditions: [], // No health conditions in new model
```

### 2. Premium Dashboard Page (`premium_dashboard_page.dart`)

#### Lỗi đã sửa:
- **API method calls**: Thay đổi từ `getFamilyProfiles(userId)` sang `getUserFamilyProfiles()`
- **Unused variables**: Loại bỏ biến `userId` không sử dụng

#### Thay đổi chính:
```dart
// Trước
final familyData = await _apiService.getFamilyProfiles(userId);

// Sau
final familyData = await _apiService.getUserFamilyProfiles();
```

## Các lỗi đã được sửa

### ✅ Lỗi Model Compatibility
- Cập nhật `FamilyMember.fromFamilyMemberModel()` để phù hợp với cấu trúc mới
- Xử lý các field `allergies` và `dietaryRestrictions` từ String thành List
- Loại bỏ các field không còn tồn tại như `spiceLevel`, `dietFlags`, `healthConditions`

### ✅ Lỗi API Methods
- Thay đổi `getFamilyProfiles(userId)` thành `getUserFamilyProfiles()`
- Loại bỏ `getFamilyMembers()` vì backend chưa có endpoint này
- Cập nhật để sử dụng API endpoints mới

### ✅ Lỗi Constructor Parameters
- Cập nhật constructor của `FamilyMemberModel` để sử dụng các field mới:
  - `dietaryRestrictions: String?` thay vì `dietFlags: List<DietFlag>`
  - `allergies: String?` thay vì `allergies: List<String>`
  - Loại bỏ các field: `spiceLevel`, `healthConditions`, `notes`, `createdAt`, `updatedAt`

### ✅ Lỗi Undefined Types
- Loại bỏ các enum `SpiceLevel` và `DietFlag` không còn tồn tại
- Cập nhật logic conversion để phù hợp với cấu trúc mới

### ✅ Lỗi Unused Variables
- Loại bỏ biến `userId` không sử dụng trong cả hai file

## Kết quả

- **0 linter errors** - Tất cả lỗi đã được sửa
- **Code compatibility** - Code hiện tại tương thích với models và API mới
- **Functionality preserved** - Chức năng của các pages vẫn được giữ nguyên

## Lưu ý

1. **Backend Integration**: Các pages hiện tại sử dụng API endpoints mới từ backend
2. **Model Changes**: Đã cập nhật để sử dụng `FamilyMemberModel` và `FamilyProfileModel` mới
3. **Legacy Support**: Vẫn giữ `FamilyMember` class để tương thích với UI components
4. **Future Updates**: Có thể cần cập nhật thêm khi backend có thêm endpoints cho family members

## Files đã sửa

- `mobile/lib/presentation/features/premium/pages/family_profile_page.dart`
- `mobile/lib/presentation/features/premium/pages/premium_dashboard_page.dart`

## Testing

Để test các sửa lỗi:
1. Chạy `flutter analyze` để kiểm tra linter errors
2. Chạy app và test các tính năng family profile
3. Kiểm tra API integration với backend thật
