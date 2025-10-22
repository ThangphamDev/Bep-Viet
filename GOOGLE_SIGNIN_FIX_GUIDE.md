# 🔧 Hướng dẫn sửa lỗi Google Sign-In (ApiException: 10)

## ❌ Lỗi hiện tại
```
PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10: , null, null)
```

**ApiException: 10** = **DEVELOPER_ERROR** - Cấu hình Google Cloud Console SAI!

---

## ✅ Giải pháp (Làm từng bước)

### Bước 1: Xóa toàn bộ OAuth Client cũ

1. Vào: https://console.cloud.google.com/apis/credentials
2. **XÓA** tất cả OAuth 2.0 Client IDs hiện có (cả Web và Android nếu có)
3. Chỉ giữ lại nếu bạn chắc chắn đã cấu hình đúng

---

### Bước 2: Tạo Web OAuth Client ID (cho Backend)

1. Click **"+ CREATE CREDENTIALS"** → **"OAuth client ID"**
2. Application type: **Web application**
3. Name: `Bep Viet Web Client`
4. Click **"CREATE"**
5. **Copy Web Client ID** này (dạng: `xxxxx.apps.googleusercontent.com`)
6. Paste vào `backend/.env`:
   ```
   GOOGLE_CLIENT_ID=xxxxx-xxxxxx.apps.googleusercontent.com
   ```

---

### Bước 3: Tạo Android OAuth Client ID (cho Mobile App)

1. Click **"+ CREATE CREDENTIALS"** → **"OAuth client ID"**
2. Application type: **Android**
3. Name: `Bep Viet Android Client`
4. Package name: `com.bepviet.app.mobile`
5. SHA-1 certificate fingerprint: 
   ```
   FC:FB:C6:34:BF:23:19:A7:89:EE:AE:08:D4:DF:3D:43:6A:1C:D5:31
   ```
6. Click **"CREATE"**
7. **QUAN TRỌNG**: Click **"SAVE"** (nút ở góc dưới màn hình)

---

### Bước 4: Kiểm tra OAuth Consent Screen

1. Vào: https://console.cloud.google.com/apis/credentials/consent
2. User Type: **External**
3. Publishing status: 
   - **In production** (nếu muốn ai cũng dùng được)
   - HOẶC **Testing** + thêm email của bạn vào **Test users**

---

### Bước 5: Đợi Google cập nhật

⏰ **ĐỢI 10-15 PHÚT** sau khi click "Save" để Google cập nhật hệ thống toàn cầu!

---

### Bước 6: Cập nhật code Flutter

Trong `mobile/lib/data/sources/remote/google_auth_service.dart`:

```dart
GoogleAuthService(this._dio) {
  _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
    // QUAN TRỌNG: Phải có serverClientId (dùng WEB CLIENT ID)
    serverClientId: 'YOUR_WEB_CLIENT_ID_HERE.apps.googleusercontent.com',
  );
}
```

**CHÚ Ý**: `serverClientId` phải dùng **Web Client ID** (không phải Android Client ID)!

---

### Bước 7: Rebuild và test

```bash
cd mobile
flutter clean
flutter pub get
flutter run --debug
```

Nhấn Google trên app và kiểm tra!

---

## 🔍 Cách kiểm tra cấu hình đúng chưa

Vào https://console.cloud.google.com/apis/credentials, bạn phải thấy:

✅ **2 OAuth 2.0 Client IDs**:
1. **Web application** - cho backend
2. **Android** - cho mobile app với:
   - Package: `com.bepviet.app.mobile`
   - SHA-1: `FC:FB:C6:34:BF:23:19:A7:89:EE:AE:08:D4:DF:3D:43:6A:1C:D5:31`

---

## 📝 Thông tin quan trọng

- **Package name**: `com.bepviet.app.mobile`
- **SHA-1 fingerprint**: `FC:FB:C6:34:BF:23:19:A7:89:EE:AE:08:D4:DF:3D:43:6A:1C:D5:31`
- **Web Client ID** (đã có): `823375731447-4qmn58ipe5em1itei0jllgpcm2p09fom.apps.googleusercontent.com`

---

## ❓ Nếu vẫn lỗi

1. Kiểm tra lại **chính xác** Package name và SHA-1 trong Google Cloud Console
2. Đợi đủ 15 phút sau khi Save
3. Xóa app và cài lại: `adb uninstall com.bepviet.app.mobile`
4. Clear cache Google Play Services trên điện thoại:
   - Settings → Apps → Google Play Services → Storage → Clear Cache

