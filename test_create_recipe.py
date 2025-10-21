#!/usr/bin/env python3
import requests
import json

# API endpoint
API_URL = "https://gullably-nonpsychological-leisha.ngrok-free.dev/api/community/recipes"

# Test recipe data
test_recipe = {
    "title": "Phở Bò Hà Nội",
    "region": "BAC", 
    "descriptionMd": "Món phở truyền thống của Hà Nội với nước dùng đậm đà và thịt bò tươi ngon",
    "difficulty": "TRUNG_BINH",
    "timeMin": 45,
    "costHint": 50000,
    "imageBase64": None,
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
            "orderNo": 1,
            "contentMd": "Rửa sạch thịt bò và cắt thành lát mỏng"
        },
        {
            "orderNo": 2,
            "contentMd": "Nướng hành tây và gừng cho thơm"
        },
        {
            "orderNo": 3,
            "contentMd": "Nấu nước dùng với quế, hoa hồi trong 30 phút"
        },
        {
            "orderNo": 4,
            "contentMd": "Trần bánh phở qua nước sôi"
        },
        {
            "orderNo": 5,
            "contentMd": "Cho bánh phở vào tô, thêm thịt bò và chan nước dùng nóng"
        },
        {
            "orderNo": 6,
            "contentMd": "Thêm hành lá, ngò gai và thưởng thức"
        }
    ]
}

# JWT Token (replace with real token)
JWT_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIxZTgyZDRlYi01MWU5LTRjODgtYjRkNy01ODgyNGY3ZjM1ZDgiLCJlbWFpbCI6InZpZXRAZ21haWwuY29tIiwicm9sZSI6IlVTRVIiLCJ0eXBlIjoiYWNjZXNzIiwiaWF0IjoxNzYxMDY0NTIwLCJleHAiOjE3NjEwNjgxMjB9.MYdyEppgGaLMoQezh2BESYOc4_RZTZDHMshSn8_epts"

def test_create_recipe():
    print("🚀 Testing create recipe API...")
    print("📝 Recipe data:")
    print(json.dumps(test_recipe, indent=2, ensure_ascii=False))
    
    headers = {
        'Authorization': f'Bearer {JWT_TOKEN}',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true'
    }
    
    try:
        response = requests.post(API_URL, json=test_recipe, headers=headers)
        
        print(f"\n📊 Response Status: {response.status_code}")
        
        if response.status_code == 200 or response.status_code == 201:
            print("✅ Success! Recipe created:")
            print(json.dumps(response.json(), indent=2, ensure_ascii=False))
        else:
            print("❌ Error creating recipe:")
            print(f"Status: {response.status_code}")
            print(f"Response: {response.text}")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Network error: {e}")
    except Exception as e:
        print(f"❌ Unexpected error: {e}")

if __name__ == "__main__":
    test_create_recipe()
