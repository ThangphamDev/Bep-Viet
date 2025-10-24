#!/usr/bin/env python3
import requests
import json

# API endpoint
API_URL = "https://gullably-nonpsychological-leisha.ngrok-free.dev/api/community/recipes"

# JWT Token
JWT_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIxZTgyZDRlYi01MWU5LTRjODgtYjRkNy01ODgyNGY3ZjM1ZDgiLCJlbWFpbCI6InZpZXRAZ21haWwuY29tIiwicm9sZSI6IlVTRVIiLCJ0eXBlIjoiYWNjZXNzIiwiaWF0IjoxNzYxMDY0NTIwLCJleHAiOjE3NjEwNjgxMjB9.MYdyEppgGaLMoQezh2BESYOc4_RZTZDHMshSn8_epts"

def test_minimal_recipe():
    """Test with minimal data"""
    print("🧪 Testing with minimal recipe data...")
    
    minimal_recipe = {
        "title": "Test Recipe",
        "region": "BAC",
        "descriptionMd": "Test description",
        "difficulty": "DE",
        "timeMin": 30,
        "ingredients": [
            {
                "name": "Test Ingredient",
                "quantity": "1 cup",
                "note": ""
            }
        ],
        "steps": [
            {
                "orderNo": 1,
                "contentMd": "Test step"
            }
        ]
    }
    
    headers = {
        'Authorization': f'Bearer {JWT_TOKEN}',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true'
    }
    
    try:
        response = requests.post(API_URL, json=minimal_recipe, headers=headers)
        print(f"📊 Status: {response.status_code}")
        print(f"📄 Response: {response.text}")
        
        if response.status_code == 200 or response.status_code == 201:
            print("✅ Success!")
        else:
            print("❌ Failed!")
            
    except Exception as e:
        print(f"❌ Error: {e}")

def test_without_image():
    """Test without imageBase64 field"""
    print("\n🧪 Testing without imageBase64 field...")
    
    recipe_no_image = {
        "title": "Phở Bò Hà Nội",
        "region": "BAC",
        "descriptionMd": "Món phở truyền thống của Hà Nội",
        "difficulty": "TRUNG_BINH",
        "timeMin": 45,
        "costHint": 50000,
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
            }
        ],
        "steps": [
            {
                "orderNo": 1,
                "contentMd": "Rửa sạch thịt bò và cắt thành lát mỏng"
            },
            {
                "orderNo": 2,
                "contentMd": "Nấu nước dùng trong 30 phút"
            }
        ]
    }
    
    headers = {
        'Authorization': f'Bearer {JWT_TOKEN}',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true'
    }
    
    try:
        response = requests.post(API_URL, json=recipe_no_image, headers=headers)
        print(f"📊 Status: {response.status_code}")
        print(f"📄 Response: {response.text}")
        
        if response.status_code == 200 or response.status_code == 201:
            print("✅ Success!")
        else:
            print("❌ Failed!")
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_minimal_recipe()
    test_without_image()
