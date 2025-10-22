# 🔐 Hướng dẫn cấu hình Google Sign-In cho Bếp Việt

## 📋 Tổng quan
Để đăng nhập bằng Google hoạt động, cần cấu hình OAuth 2.0 trên Google Cloud Console và thêm credentials vào backend.

---

## 🚀 BƯỚC 1: Tạo Project trên Google Cloud Console

### 1.1. Truy cập Google Cloud Console
- Vào: https://console.cloud.google.com/
- Đăng nhập bằng tài khoản Google của bạn

### 1.2. Tạo Project mới
1. Click vào dropdown "Select a project" ở góc trên
2. Click "NEW PROJECT"
3. Nhập tên project: `Bep Viet` hoặc `bep-viet-app`
4. Click "CREATE"

---

## 🔑 BƯỚC 2: Tạo OAuth 2.0 Credentials

### 2.1. Enable Google+ API (hoặc Google Identity API)
1. Vào menu bên trái → **APIs & Services** → **Library**
2. Tìm kiếm: `Google+ API` hoặc `Google Identity`
3. Click vào và nhấn **ENABLE**

### 2.2. Cấu hình OAuth Consent Screen
1. Vào **APIs & Services** → **OAuth consent screen**
2. Chọn **External** (để cho phép bất kỳ ai đăng nhập)
3. Click **CREATE**

**Điền thông tin:**
- **App name**: `Bếp Việt`
- **User support email**: Email của bạn
- **Developer contact email**: Email của bạn
- Click **SAVE AND CONTINUE**

**Scopes:**
- Click **ADD OR REMOVE SCOPES**
- Chọn:
  - `.../auth/userinfo.email`
  - `.../auth/userinfo.profile`
- Click **SAVE AND CONTINUE**

**Test users:** (Optional - bỏ qua được)
- Click **SAVE AND CONTINUE**

### 2.3. Tạo OAuth Client ID cho Web (Backend)
1. Vào **APIs & Services** → **Credentials**
2. Click **CREATE CREDENTIALS** → **OAuth client ID**
3. Chọn **Application type**: `Web application`
4. **Name**: `Bep Viet Web`
5. **Authorized redirect URIs**: 
   - `http://localhost:8080/auth/google/callback`
   - `https://your-ngrok-url.ngrok-free.dev/auth/google/callback`
6. Click **CREATE**
7. **QUAN TRỌNG**: Copy **Client ID** (dạng: `xxxx.apps.googleusercontent.com`)

---

## 📱 BƯỚC 3: Tạo OAuth Client ID cho Android

### 3.1. Lấy SHA-1 Fingerprint
Mở terminal tại thư mục project và chạy:

```bash
# Windows
cd D:\HUTECH\Mobile\DoAn\Bep-Viet\mobile\android
.\gradlew signingReport

# Tìm dòng SHA1 trong output:
# SHA1: 12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78
```

**Copy SHA-1 fingerprint** (cả debug và release nếu có)

### 3.2. Tạo Android Credentials
1. Vào **Credentials** → **CREATE CREDENTIALS** → **OAuth client ID**
2. Chọn **Application type**: `Android`
3. **Name**: `Bep Viet Android`
4. **Package name**: `com.bepviet.app.mobile` (hoặc check trong `android/app/build.gradle.kts`)
5. **SHA-1 certificate fingerprint**: Paste SHA-1 từ bước 3.1
6. Click **CREATE**

---

## 🔧 BƯỚC 4: Cấu hình Backend

### 4.1. Thêm GOOGLE_CLIENT_ID vào `.env`
File: `backend/.env`

```env
# ... các config khác ...

# Google OAuth
GOOGLE_CLIENT_ID=YOUR_WEB_CLIENT_ID_HERE.apps.googleusercontent.com
```

**LƯU Ý**: Dùng **Web Client ID** (không phải Android Client ID)

### 4.2. Restart Backend
```bash
cd backend
npm run start:dev
```

---

## 📱 BƯỚC 5: Cấu hình Mobile App (Optional)

### 5.1. Thêm google-services.json (Optional - nếu dùng Firebase)
Nếu muốn tích hợp Firebase:
1. Tạo Firebase project tại: https://console.firebase.google.com/
2. Thêm Android app với package name: `com.bepviet.app.mobile`
3. Download `google-services.json`
4. Copy vào: `mobile/android/app/google-services.json`

### 5.2. Update Package Name (nếu cần)
File: `mobile/android/app/build.gradle.kts`

```kotlin
android {
    namespace = "com.bepviet.app.mobile"  // Phải khớp với Google Console
    // ...
}
```

---

## ✅ BƯỚC 6: Test Google Sign-In

### 6.1. Khởi động Backend
```bash
cd backend
npm run start:dev
```

Kiểm tra log có dòng:
```
[Nest] INFO [NestFactory] Application is listening on port 8080
```

### 6.2. Mở app trên điện thoại
1. Mở app **Bếp Việt**
2. Vào trang **Đăng nhập**
3. Nhấn nút **"Đăng nhập với Google"**
4. Chọn tài khoản Google
5. Cho phép các quyền

### 6.3. Kết quả mong đợi
- ✅ App chuyển về Home page
- ✅ Hiển thị tên user từ Google
- ✅ Backend log: `Google login successful`

---

## 🐛 Xử lý lỗi thường gặp

### Lỗi 1: "Sign-in failed" hoặc "Network error"
**Nguyên nhân**: Backend chưa có GOOGLE_CLIENT_ID

**Giải pháp**:
```bash
# Kiểm tra .env
cat backend/.env | grep GOOGLE_CLIENT_ID

# Nếu không có, thêm vào:
echo "GOOGLE_CLIENT_ID=your_client_id.apps.googleusercontent.com" >> backend/.env

# Restart backend
npm run start:dev
```

### Lỗi 2: "Invalid ID token"
**Nguyên nhân**: Web Client ID không đúng

**Giải pháp**:
1. Vào Google Console → Credentials
2. Copy **Web Application** Client ID (không phải Android)
3. Update vào `backend/.env`
4. Restart backend

### Lỗi 3: "Developer Error" trên app
**Nguyên nhân**: SHA-1 fingerprint không đúng hoặc package name sai

**Giải pháp**:
```bash
# Lấy lại SHA-1
cd mobile/android
./gradlew signingReport

# Update SHA-1 mới trên Google Console
# Đảm bảo package name khớp
```

### Lỗi 4: "Sign-in cancelled"
**Nguyên nhân**: User tự cancel, hoặc Google Play Services chưa update

**Giải pháp**:
- Update Google Play Services trên điện thoại
- Thử lại

---

## 📝 Checklist cuối cùng

- [ ] Google Cloud project đã tạo
- [ ] OAuth Consent Screen đã cấu hình
- [ ] Web Client ID đã tạo
- [ ] Android Client ID đã tạo (với đúng SHA-1)
- [ ] `GOOGLE_CLIENT_ID` đã thêm vào `backend/.env`
- [ ] Backend đã restart
- [ ] App đã cài lên điện thoại
- [ ] Test đăng nhập Google thành công

---

## 🎯 Luồng hoạt động

```
User nhấn "Đăng nhập Google"
    ↓
App mở Google Sign-In UI
    ↓
User chọn tài khoản Google
    ↓
App nhận ID Token từ Google
    ↓
App gửi ID Token đến: POST /api/auth/google
    ↓
Backend verify với Google API
    ↓
Backend kiểm tra email trong DB
    ├─ Chưa có → Tạo user mới
    └─ Đã có → Login
    ↓
Backend trả JWT tokens
    ↓
App lưu tokens → Navigate to Home
    ↓
✅ ĐĂNG NHẬP THÀNH CÔNG!
```

---

## 📞 Hỗ trợ

Nếu gặp vấn đề:
1. Check backend logs: `npm run start:dev`
2. Check mobile logs: `adb logcat | grep -i google`
3. Verify Client ID: `echo $GOOGLE_CLIENT_ID`

---

**Chúc bạn thành công!** 🎉

