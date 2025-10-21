#!/usr/bin/env python3
import requests
import json

# API endpoint
API_URL = "https://gullably-nonpsychological-leisha.ngrok-free.dev/api/community/recipes"

# JWT Token
JWT_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIxZTgyZDRlYi01MWU5LTRjODgtYjRkNy01ODgyNGY3ZjM1ZDgiLCJlbWFpbCI6InZpZXRAZ21haWwuY29tIiwicm9sZSI6IlVTRVIiLCJ0eXBlIjoiYWNjZXNzIiwiaWF0IjoxNzYxMDY0NTIwLCJleHAiOjE3NjEwNjgxMjB9.MYdyEppgGaLMoQezh2BESYOc4_RZTZDHMshSn8_epts"

def test_with_correct_field_names():
    """Test with correct field names that backend expects"""
    print("🧪 Testing with correct field names...")
    
    recipe = {
        "title": "Phở Bò Hà Nội",
        "region": "BAC",
        "description_md": "Món phở truyền thống của Hà Nội với nước dùng đậm đà và thịt bò tươi ngon",
        "difficulty": "TRUNG_BINH",
        "time_min": 45,
        "cost_hint": 50000,
        "ingredients": [
            {
                "name": "Bánh phở",
                "quantity": "200g",
                "note": "Loại tươi"
            },
            {
                "name": "Thịt bò",
                "quantity": "150g",
                "note": "Thịt bò tái"
            },
            {
                "name": "Hành tây",
                "quantity": "1 củ",
                "note": ""
            },
            {
                "name": "Gừng",
                "quantity": "1 củ",
                "note": ""
            },
            {
                "name": "Quế",
                "quantity": "1 thanh",
                "note": ""
            },
            {
                "name": "Hoa hồi",
                "quantity": "2 cái",
                "note": ""
            }
        ],
        "steps": [
            {
                "order_no": 1,
                "content_md": "Rửa sạch thịt bò và cắt thành lát mỏng"
            },
            {
                "order_no": 2,
                "content_md": "Nướng hành tây và gừng cho thơm"
            },
            {
                "order_no": 3,
                "content_md": "Nấu nước dùng với quế, hoa hồi trong 30 phút"
            },
            {
                "order_no": 4,
                "content_md": "Trần bánh phở qua nước sôi"
            },
            {
                "order_no": 5,
                "content_md": "Cho bánh phở vào tô, thêm thịt bò và chan nước dùng nóng"
            },
            {
                "order_no": 6,
                "content_md": "Thêm hành lá, ngò gai và thưởng thức"
            }
        ]
    }
    
    headers = {
        'Authorization': f'Bearer {JWT_TOKEN}',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true'
    }
    
    print("📝 Recipe data:")
    print(json.dumps(recipe, indent=2, ensure_ascii=False))
    
    try:
        response = requests.post(API_URL, json=recipe, headers=headers)
        print(f"\n📊 Response Status: {response.status_code}")
        print(f"📄 Response: {response.text}")
        
        if response.status_code == 200 or response.status_code == 201:
            print("✅ Success! Recipe created!")
        else:
            print("❌ Failed!")
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_with_correct_field_names()
