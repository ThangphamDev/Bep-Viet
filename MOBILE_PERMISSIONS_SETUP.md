# 📱 Mobile App Setup - Camera & Gallery Permissions

## Android Setup

### 1. Update `android/app/src/main/AndroidManifest.xml`

Thêm permissions vào file:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Camera Permission -->
    <uses-permission android:name="android.permission.CAMERA" />
    
    <!-- Storage Permissions -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
                     android:maxSdkVersion="32" />
    
    <!-- For Android 13+ (API 33+) -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    
    <!-- Internet Permission (should already exist) -->
    <uses-permission android:name="android.permission.INTERNET" />
    
    <application
        android:label="Bếp Việt"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <!-- ... rest of your config ... -->
    </application>
</manifest>
```

### 2. Update `android/app/build.gradle`

Đảm bảo minSdkVersion >= 21:

```gradle
android {
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 33
    }
}
```

## iOS Setup

### 1. Update `ios/Runner/Info.plist`

Thêm permissions descriptions:

```xml
<dict>
    <!-- ... existing keys ... -->
    
    <!-- Camera Permission -->
    <key>NSCameraUsageDescription</key>
    <string>Bếp Việt cần quyền truy cập camera để nhận diện nguyên liệu từ hình ảnh</string>
    
    <!-- Photo Library Permission -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Bếp Việt cần quyền truy cập thư viện ảnh để chọn hình ảnh nguyên liệu</string>
    
    <!-- For iOS 14+ -->
    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>Bếp Việt cần quyền lưu ảnh vào thư viện</string>
    
</dict>
```

### 2. Update `ios/Podfile`

Đảm bảo platform >= 12.0:

```ruby
platform :ios, '12.0'
```

## Testing

### Android
```bash
# Clean build
cd mobile
flutter clean
flutter pub get

# Run on Android device/emulator
flutter run -d android
```

### iOS
```bash
# Install pods
cd ios
pod install
cd ..

# Run on iOS simulator/device
flutter run -d ios
```

## Common Issues

### Android

**Issue 1: Permission denied**
```
Solution: Uninstall app and reinstall to trigger permission prompt
```

**Issue 2: Camera not opening**
```
Solution: Check device has camera and permissions are granted in Settings
```

### iOS

**Issue 1: Pod install fails**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

**Issue 2: Permissions not asking**
```
Solution: Delete app, clean build folder, and reinstall
```

## Runtime Permission Handling

The app automatically requests permissions when user taps Camera/Gallery buttons.

If user denies, app shows error message and can guide to Settings:

```dart
// In image_analysis_widget.dart
if (permissionDenied) {
  // Show dialog to open settings
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Cần cấp quyền'),
      content: Text('Vui lòng cấp quyền Camera/Gallery trong Settings'),
      actions: [
        TextButton(
          onPressed: () => openAppSettings(),
          child: Text('Mở Settings'),
        ),
      ],
    ),
  );
}
```

## Package Used

```yaml
dependencies:
  image_picker: ^1.0.7
```

**Features:**
- ✅ Camera capture
- ✅ Gallery selection
- ✅ Image compression
- ✅ Cross-platform support
- ✅ Permission handling

## Testing Checklist

- [ ] Test camera capture on Android
- [ ] Test gallery selection on Android
- [ ] Test camera capture on iOS
- [ ] Test gallery selection on iOS
- [ ] Test permission denied scenario
- [ ] Test with no camera device
- [ ] Test with large images (> 5MB)
- [ ] Test image compression
- [ ] Test upload to backend
- [ ] Test Gemini AI response

---

**Ready to use! 🚀**
