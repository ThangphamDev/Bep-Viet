# 📸 Tính năng Nhận diện Nguyên liệu bằng Hình ảnh

## 🚀 Cách sử dụng

### Backend Setup

1. **Lấy Gemini API Key:**
   - Truy cập: https://makersuite.google.com/app/apikey
   - Tạo API key mới cho Gemini 2.0 Flash Exp
   - Copy API key

2. **Cấu hình Backend:**
   ```bash
   cd backend
   
   # Thêm vào file .env
   GEMINI_API_KEY=your_actual_gemini_api_key_here
   ```

3. **Cài đặt dependencies:**
   ```bash
   npm install
   ```

4. **Chạy backend:**
   ```bash
   npm run start:dev
   ```

### Mobile Setup

1. **Cài đặt dependencies:**
   ```bash
   cd mobile
   flutter pub get
   ```

2. **Chạy app:**
   ```bash
   flutter run
   ```

## 🎯 API Endpoints

### 1. Analyze Image (Base64)
```
POST /api/gemini/analyze-image-base64
Content-Type: application/json

{
  "imageBase64": "data:image/jpeg;base64,/9j/4AAQSkZJRg..."
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "ingredients": [
      {
        "name": "Cà chua",
        "confidence": 95,
        "category": "Rau củ",
        "matched_id": "uuid-1"
      },
      {
        "name": "Hành tây",
        "confidence": 88,
        "category": "Rau củ",
        "matched_id": "uuid-2"
      }
    ],
    "suggestions": [
      "Canh chua cá",
      "Thịt kho tàu",
      "Cơm rang"
    ]
  }
}
```

### 2. Analyze Image (Multipart)
```
POST /api/gemini/analyze-image
Content-Type: multipart/form-data

Form Data:
- image: [file]
```

### 3. Get Recipe Suggestions from Ingredients
```
POST /api/gemini/suggest-from-ingredients?region=NAM&limit=10
Content-Type: application/json

{
  "ingredient_ids": ["uuid-1", "uuid-2", "uuid-3"]
}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "recipe_id": "r1",
      "name_vi": "Canh chua cá",
      "match_percentage": 85,
      "matched_ingredients": 6,
      "total_ingredients": 7
    }
  ],
  "count": 5
}
```

## 🎨 UI Features

### Trang Gợi ý đã được nâng cấp với:

1. **Camera Button** (Icon camera với gradient)
   - Nhấn để mở Image Analysis Widget
   - Có animation khi mở/đóng

2. **Image Analysis Widget** - Modal glassmorphism
   - Chọn ảnh từ Camera hoặc Gallery
   - Preview ảnh đã chọn
   - Loading animation khi phân tích
   - Hiển thị danh sách nguyên liệu với độ tin cậy
   - Button "Chọn lại" và "Tìm món"

3. **Suggestion Cards** - Card đẹp hơn với:
   - Gradient background subtle
   - Box shadow đa lớp
   - Hero animation cho image
   - Region badge với gradient
   - Better typography
   - Smooth transitions

## 🔧 Cấu trúc Code

### Backend
```
backend/src/modules/gemini/
├── gemini.module.ts         # Module definition
├── gemini.service.ts        # Gemini API integration
├── gemini.controller.ts     # API endpoints
└── dto/
    └── gemini.dto.ts        # Request/Response DTOs
```

### Mobile
```
mobile/lib/presentation/features/suggest/
├── pages/
│   └── suggest_page.dart    # Main suggest page (updated)
└── widgets/
    ├── image_analysis_widget.dart  # NEW: Image analysis modal
    ├── suggestion_card.dart         # UPDATED: Better design
    └── suggest_filters.dart         # Filters widget
```

## 🎯 How It Works

1. **User chụp/chọn ảnh** → Image Analysis Widget
2. **Convert to Base64** → Send to Backend
3. **Gemini AI phân tích** → Detect ingredients
4. **Match với database** → Get ingredient IDs
5. **Query recipes** → Find matching recipes
6. **Display suggestions** → Beautiful cards with animations

## ✨ Features Highlights

- 🤖 **Gemini 2.0 Flash Exp** - Latest AI model
- 📸 **Image Recognition** - Detect multiple ingredients
- 🎯 **Smart Matching** - Fuzzy match with database
- 🏆 **Confidence Score** - Show detection accuracy
- 🎨 **Beautiful UI** - Glassmorphism & animations
- ⚡ **Fast Response** - Optimized API calls
- 🔄 **Real-time Updates** - Instant suggestions

## 🐛 Troubleshooting

### Backend Issues:

1. **"Gemini API key not configured"**
   - Kiểm tra file `.env` có `GEMINI_API_KEY`
   - Restart backend server

2. **"Failed to analyze image"**
   - Check internet connection
   - Verify API key is valid
   - Check image format (JPEG/PNG)

### Mobile Issues:

1. **Camera/Gallery không mở**
   - Check permissions trong Android/iOS settings
   - Add permissions vào AndroidManifest.xml / Info.plist

2. **Image không upload**
   - Check file size (< 5MB recommended)
   - Check network connection
   - Check API endpoint URL

## 📝 TODO & Future Enhancements

- [ ] Add caching cho ingredient detection
- [ ] Support video analysis (real-time)
- [ ] Multi-language support
- [ ] Save detected ingredients to Pantry
- [ ] Share detection results
- [ ] OCR for recipe text recognition
- [ ] Barcode scanning for packaged foods
- [ ] Nutrition information from Gemini

## 🎉 Demo Flow

1. Mở app → Navigate to "Gợi ý"
2. Nhấn button Camera (gradient icon)
3. Chọn "Chụp ảnh" hoặc "Chọn từ thư viện"
4. Chụp/chọn ảnh nguyên liệu
5. Nhấn "Phân tích nguyên liệu"
6. Xem kết quả nhận diện
7. App tự động gợi ý món ăn phù hợp!

---

**Powered by Gemini 2.0 Flash Exp 🤖**
