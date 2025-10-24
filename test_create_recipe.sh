#!/bin/bash

# Test create recipe API
echo "🚀 Testing create recipe API..."

# API endpoint
API_URL="https://gullably-nonpsychological-leisha.ngrok-free.dev/api/community/recipes"

# JWT Token (replace with real token)
JWT_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIxZTgyZDRlYi01MWU5LTRjODgtYjRkNy01ODgyNGY3ZjM1ZDgiLCJlbWFpbCI6InZpZXRAZ21haWwuY29tIiwicm9sZSI6IlVTRVIiLCJ0eXBlIjoiYWNjZXNzIiwiaWF0IjoxNzYxMDY0NTIwLCJleHAiOjE3NjEwNjgxMjB9.MYdyEppgGaLMoQezh2BESYOc4_RZTZDHMshSn8_epts"

# Test recipe data
RECIPE_DATA='{
  "title": "Phở Bò Hà Nội",
  "region": "BAC",
  "descriptionMd": "Món phở truyền thống của Hà Nội với nước dùng đậm đà và thịt bò tươi ngon",
  "difficulty": "TRUNG_BINH",
  "timeMin": 45,
  "costHint": 50000,
  "imageBase64": null,
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
}'

echo "📝 Recipe data:"
echo "$RECIPE_DATA" | jq '.'

echo ""
echo "🔄 Sending request..."

# Send POST request
response=$(curl -s -w "\n%{http_code}" -X POST "$API_URL" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -H "ngrok-skip-browser-warning: true" \
  -d "$RECIPE_DATA")

# Split response and status code
http_code=$(echo "$response" | tail -n1)
response_body=$(echo "$response" | head -n -1)

echo "📊 Response Status: $http_code"
echo "📄 Response Body:"
echo "$response_body" | jq '.' 2>/dev/null || echo "$response_body"

if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 201 ]; then
    echo "✅ Success! Recipe created successfully!"
else
    echo "❌ Error creating recipe!"
fi
