# Community API - New Endpoints Documentation

## ✅ ĐÃ THÊM 2 TÍNH NĂNG MỚI

### 📋 **Tổng quan**
Module Community đã được nâng cấp với 2 tính năng quan trọng:
1. **Upload ảnh** cho bài đăng community recipe
2. **Delete bài đăng** của người dùng

---

## 🔧 **DATABASE CHANGES**

### Thêm cột `image_url` vào bảng `community_recipes`

```sql
-- Thực thi SQL này trên database để thêm cột mới
ALTER TABLE community_recipes 
ADD COLUMN image_url TEXT NULL AFTER cost_hint;
```

**Lưu ý:** Schema files đã được cập nhật:
- ✅ `bepviet_full_schema.sql` 
- ✅ `backend/src/database/migrations/001_create_initial_schema.sql`

---

## 📡 **API ENDPOINTS MỚI**

### 1. **DELETE** `/community/recipes/:id` - Xóa bài đăng

**Mô tả:** Xóa community recipe (chỉ tác giả mới có quyền xóa)

**Authentication:** Required (JWT Token)

**Headers:**
```http
Authorization: Bearer {your_jwt_token}
```

**Parameters:**
- `id` (path): Recipe ID (UUID)

**Response Success (200):**
```json
{
  "success": true,
  "message": "Community recipe deleted successfully"
}
```

**Response Errors:**
- `401 Unauthorized`: Không có token hoặc token không hợp lệ
- `403 Forbidden`: Không phải tác giả bài viết
- `404 Not Found`: Không tìm thấy recipe

**Example cURL:**
```bash
curl -X DELETE \
  'http://localhost:3000/community/recipes/uuid-recipe-id' \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN'
```

---

### 2. **POST** `/community/upload-image` - Upload ảnh

**Mô tả:** Upload ảnh cho community recipe (trả về base64 image URL)

**Authentication:** Required (JWT Token)

**Headers:**
```http
Authorization: Bearer {your_jwt_token}
Content-Type: multipart/form-data
```

**Body (Form Data):**
- `image`: File (jpeg, png, jpg, gif)

**Response Success (200):**
```json
{
  "success": true,
  "data": {
    "imageUrl": "data:image/jpeg;base64,/9j/4AAQSkZJRg...",
    "mimetype": "image/jpeg",
    "size": 245678
  },
  "message": "Image uploaded successfully"
}
```

**Response Error (400):**
```json
{
  "success": false,
  "message": "No image file provided"
}
```

**Example cURL:**
```bash
curl -X POST \
  'http://localhost:3000/community/upload-image' \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN' \
  -F 'image=@/path/to/your/image.jpg'
```

**Example JavaScript (Fetch API):**
```javascript
const formData = new FormData();
formData.append('image', imageFile); // imageFile from <input type="file">

const response = await fetch('http://localhost:3000/community/upload-image', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`
  },
  body: formData
});

const result = await response.json();
console.log(result.data.imageUrl); // Use this URL in createCommunityRecipe
```

---

## 🔄 **CẬP NHẬT ENDPOINT CŨ**

### **POST** `/community/recipes` - Create Community Recipe

**DTO đã được cập nhật để hỗ trợ `image_url`:**

```typescript
{
  "title": "Phở Bò Hà Nội",
  "region": "BAC",
  "description_md": "Món phở ngon nhất Hà Nội",
  "difficulty": "TRUNG_BINH",
  "time_min": 60,
  "cost_hint": 50000,
  "image_url": "data:image/jpeg;base64,/9j/4AAQSkZJRg...", // ✨ MỚI
  "ingredients": [
    {
      "name": "Bánh phở",
      "quantity": "200g",
      "note": "Loại tươi"
    }
  ],
  "steps": [
    {
      "order_no": 1,
      "content_md": "Chuẩn bị nguyên liệu"
    }
  ]
}
```

---

## 📊 **TẤT CẢ ENDPOINT TRẢ VỀ `image_url`**

Các endpoint sau đã được cập nhật để trả về `image_url`:

✅ `GET /community/recipes` - Danh sách community recipes  
✅ `GET /community/recipes/:id` - Chi tiết recipe  
✅ `GET /community/recipes/featured` - Recipes nổi bật  
✅ `GET /community/my-recipes` - Recipes của user  
✅ `GET /community/moderation/pending` - Recipes chờ duyệt (admin)

---

## 🎯 **WORKFLOW HOÀN CHỈNH**

### Tạo bài đăng có ảnh:

```javascript
// 1. Upload ảnh trước
const uploadResponse = await uploadImage(imageFile);
const imageUrl = uploadResponse.data.imageUrl;

// 2. Tạo recipe với imageUrl
const createResponse = await createCommunityRecipe({
  title: "Phở Bò",
  region: "BAC",
  description_md: "Ngon tuyệt",
  difficulty: "DE",
  time_min: 45,
  cost_hint: 50000,
  image_url: imageUrl, // ✨ Từ bước 1
  ingredients: [...],
  steps: [...]
});
```

### Xóa bài đăng:

```javascript
const deleteResponse = await deleteCommunityRecipe(recipeId);
if (deleteResponse.success) {
  console.log('Đã xóa thành công!');
}
```

---

## 🧪 **TESTING**

### Test với Postman/Thunder Client:

**1. Test Upload Image:**
```
POST http://localhost:3000/community/upload-image
Authorization: Bearer YOUR_TOKEN
Body: form-data
  - Key: image
  - Type: File
  - Value: [Select an image file]
```

**2. Test Create với Image:**
```
POST http://localhost:3000/community/recipes
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

Body:
{
  "title": "Test Recipe",
  "region": "BAC",
  "description_md": "Test",
  "difficulty": "DE",
  "time_min": 30,
  "image_url": "data:image/jpeg;base64,...", // From step 1
  "ingredients": [{"name": "Test", "quantity": "100g"}],
  "steps": [{"order_no": 1, "content_md": "Test"}]
}
```

**3. Test Delete:**
```
DELETE http://localhost:3000/community/recipes/{recipe-id}
Authorization: Bearer YOUR_TOKEN
```

---

## 🔐 **AUTHORIZATION RULES**

| Endpoint | Public | User | Admin |
|----------|--------|------|-------|
| `GET /community/recipes` | ✅ | ✅ | ✅ |
| `GET /community/recipes/:id` | ✅ | ✅ | ✅ |
| `POST /community/recipes` | ❌ | ✅ | ✅ |
| `POST /community/upload-image` | ❌ | ✅ | ✅ |
| `DELETE /community/recipes/:id` | ❌ | ✅ (own only) | ✅ |
| `GET /community/moderation/pending` | ❌ | ❌ | ✅ |
| `PUT /community/moderation/:id` | ❌ | ❌ | ✅ |

---

## 📝 **NOTES**

- **Image Storage:** Hiện tại sử dụng base64 encoding để lưu ảnh trực tiếp trong database
- **Size Limit:** Recommend < 1MB cho mỗi ảnh để tránh database quá nặng
- **Future Enhancement:** Có thể chuyển sang Cloudinary/AWS S3 cho production
- **Cascade Delete:** Khi xóa recipe, tất cả ingredients, steps, comments, ratings sẽ tự động xóa theo

---

## ✅ **CHECKLIST DEPLOY**

- [ ] Chạy migration SQL để thêm cột `image_url`
- [ ] Restart backend service
- [ ] Test upload image endpoint
- [ ] Test create recipe với image
- [ ] Test delete recipe
- [ ] Cập nhật frontend/mobile để sử dụng endpoints mới

---

**Created:** 2025-01-22  
**Version:** 1.0  
**Author:** AI Assistant

