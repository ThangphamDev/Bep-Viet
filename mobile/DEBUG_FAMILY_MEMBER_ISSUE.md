# Debug: Thêm thành viên gia đình không lưu được

## 🔍 Nguyên nhân có thể gây ra vấn đề

### 1. **Authentication Issues**
- Backend yêu cầu JWT token (`@UseGuards(JwtAuthGuard)`)
- Mobile app có thể chưa gửi token đúng cách
- **Giải pháp**: Thêm JWT token vào headers

### 2. **API Response Structure Mismatch**
- Backend trả về: `{success: true, data: {...}}`
- Mobile app expect: `response['data']` trực tiếp
- **Giải pháp**: Đã cập nhật ApiService để xử lý đúng

### 3. **Database Issues**
- Database connection có thể bị lỗi
- Table `family_members` có thể chưa tồn tại
- **Giải pháp**: Kiểm tra database schema

### 4. **Network Issues**
- API endpoint không accessible
- Backend server không chạy
- **Giải pháp**: Kiểm tra server status

## 🛠️ Các thay đổi đã thực hiện

### 1. **Cập nhật ApiService**
```dart
// Thêm xử lý response structure
if (responseData is Map && responseData.containsKey('success')) {
  if (responseData['success'] == true) {
    return responseData;
  } else {
    throw Exception('API Error: ${responseData['message'] ?? 'Unknown error'}');
  }
}
```

### 2. **Cập nhật FamilyService**
```dart
// Thêm debug logging
print('🔍 Adding family member: $name to family $familyId');
print('✅ API Response: $response');

// Xử lý response structure
final memberData = response['data'] ?? response;
```

### 3. **Thêm Test Method**
```dart
Future<bool> testConnection() async {
  try {
    await _apiService.getUserFamilyProfiles();
    return true;
  } catch (e) {
    return false;
  }
}
```

## 🧪 Cách test và debug

### 1. **Chạy Test File**
```bash
dart test_add_family_member.dart
```

### 2. **Kiểm tra Console Logs**
- Tìm các log: `🔍 Adding family member...`
- Tìm các log: `✅ API Response: ...`
- Tìm các log: `❌ Error adding family member: ...`

### 3. **Kiểm tra Backend Logs**
- Xem server console có nhận được request không
- Kiểm tra database có insert record không
- Xem có lỗi authentication không

### 4. **Kiểm tra Database**
```sql
-- Kiểm tra table có tồn tại không
SHOW TABLES LIKE 'family_members';

-- Kiểm tra data có được insert không
SELECT * FROM family_members ORDER BY id DESC LIMIT 5;
```

## 🔧 Các bước debug chi tiết

### Bước 1: Kiểm tra Backend Server
```bash
# Kiểm tra server có chạy không
curl http://localhost:3000/api/family/profiles

# Hoặc kiểm tra health endpoint
curl http://localhost:3000/health
```

### Bước 2: Kiểm tra API Endpoints
```bash
# Test GET profiles
curl -X GET http://localhost:3000/api/family/profiles \
  -H "Content-Type: application/json"

# Test POST member (cần JWT token)
curl -X POST http://localhost:3000/api/family/profiles/1/members \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{"name": "Test Member", "age": 25, "dietary_restrictions": "Vegetarian", "allergies": "Peanuts"}'
```

### Bước 3: Kiểm tra Database Schema
```sql
-- Tạo table nếu chưa có
CREATE TABLE IF NOT EXISTS family_members (
  id INT PRIMARY KEY AUTO_INCREMENT,
  family_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  age INT NOT NULL,
  dietary_restrictions TEXT,
  allergies TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Bước 4: Kiểm tra Authentication
- Đảm bảo JWT token được gửi đúng cách
- Kiểm tra token có valid không
- Xem backend có reject request vì authentication không

## 🚨 Các lỗi thường gặp

### 1. **401 Unauthorized**
```
HTTP 401: {"message": "Unauthorized"}
```
**Nguyên nhân**: JWT token không được gửi hoặc invalid
**Giải pháp**: Thêm JWT token vào headers

### 2. **404 Not Found**
```
HTTP 404: {"message": "Not Found"}
```
**Nguyên nhân**: API endpoint không đúng
**Giải pháp**: Kiểm tra URL endpoint

### 3. **500 Internal Server Error**
```
HTTP 500: {"message": "Internal Server Error"}
```
**Nguyên nhân**: Database connection hoặc query lỗi
**Giải pháp**: Kiểm tra database và logs

### 4. **Network Error**
```
API request failed: SocketException: Failed to connect
```
**Nguyên nhân**: Server không chạy hoặc network issue
**Giải pháp**: Kiểm tra server status và network

## 📝 Checklist Debug

- [ ] Backend server đang chạy
- [ ] API endpoints accessible
- [ ] Database connection OK
- [ ] JWT authentication working
- [ ] Network connectivity OK
- [ ] Database schema correct
- [ ] API response structure handled
- [ ] Error logging enabled
- [ ] Test file runs successfully

## 🎯 Next Steps

1. **Chạy test file** để xem lỗi cụ thể
2. **Kiểm tra backend logs** để xem request có đến server không
3. **Verify database** để xem data có được lưu không
4. **Check authentication** để đảm bảo JWT token đúng
5. **Update mobile app** với JWT token nếu cần
