#!/bin/bash

# BẾP VIỆT API - Endpoint Testing Script
# This script tests the main API endpoints

BASE_URL="http://localhost:8080/api/v1"
API_DOCS_URL="http://localhost:8080/api/v1/docs"
ADMINER_URL="http://localhost:8081"

echo "🚀 BẾP VIỆT API - Endpoint Testing"
echo "=================================="
echo ""

# Check if services are running
echo "📊 Checking services status..."
echo ""

# Check Backend API
echo "🔍 Testing Backend API..."
if curl -s -f "$BASE_URL" > /dev/null; then
    echo "✅ Backend API: Running at $BASE_URL"
else
    echo "❌ Backend API: Not responding"
    exit 1
fi

# Check Swagger Documentation
echo "🔍 Testing Swagger Documentation..."
if curl -s -f "$API_DOCS_URL" > /dev/null; then
    echo "✅ Swagger Docs: Available at $API_DOCS_URL"
else
    echo "❌ Swagger Docs: Not available"
fi

# Check Adminer
echo "🔍 Testing Adminer..."
if curl -s -f "$ADMINER_URL" > /dev/null; then
    echo "✅ Adminer: Available at $ADMINER_URL"
else
    echo "❌ Adminer: Not available"
fi

echo ""
echo "🧪 Testing API Endpoints..."
echo "=========================="

# Test basic endpoints
echo ""
echo "📋 Testing Basic Endpoints:"

# Test root endpoint
echo "1. Testing root endpoint..."
response=$(curl -s -w "%{http_code}" -o /dev/null "$BASE_URL")
if [ "$response" = "200" ]; then
    echo "   ✅ GET $BASE_URL - Status: $response"
else
    echo "   ❌ GET $BASE_URL - Status: $response"
fi

# Test regions endpoint
echo "2. Testing regions endpoint..."
response=$(curl -s -w "%{http_code}" -o /dev/null "$BASE_URL/regions")
if [ "$response" = "200" ]; then
    echo "   ✅ GET $BASE_URL/regions - Status: $response"
else
    echo "   ❌ GET $BASE_URL/regions - Status: $response"
fi

# Test seasons endpoint
echo "3. Testing seasons endpoint..."
response=$(curl -s -w "%{http_code}" -o /dev/null "$BASE_URL/seasons")
if [ "$response" = "200" ]; then
    echo "   ✅ GET $BASE_URL/seasons - Status: $response"
else
    echo "   ❌ GET $BASE_URL/seasons - Status: $response"
fi

# Test ingredients endpoint
echo "4. Testing ingredients endpoint..."
response=$(curl -s -w "%{http_code}" -o /dev/null "$BASE_URL/ingredients")
if [ "$response" = "200" ]; then
    echo "   ✅ GET $BASE_URL/ingredients - Status: $response"
else
    echo "   ❌ GET $BASE_URL/ingredients - Status: $response"
fi

# Test recipes endpoint
echo "5. Testing recipes endpoint..."
response=$(curl -s -w "%{http_code}" -o /dev/null "$BASE_URL/recipes")
if [ "$response" = "200" ]; then
    echo "   ✅ GET $BASE_URL/recipes - Status: $response"
else
    echo "   ❌ GET $BASE_URL/recipes - Status: $response"
fi

# Test community recipes endpoint
echo "6. Testing community recipes endpoint..."
response=$(curl -s -w "%{http_code}" -o /dev/null "$BASE_URL/community/recipes")
if [ "$response" = "200" ]; then
    echo "   ✅ GET $BASE_URL/community/recipes - Status: $response"
else
    echo "   ❌ GET $BASE_URL/community/recipes - Status: $response"
fi

# Test ratings statistics endpoint
echo "7. Testing ratings statistics endpoint..."
response=$(curl -s -w "%{http_code}" -o /dev/null "$BASE_URL/ratings/statistics")
if [ "$response" = "200" ]; then
    echo "   ✅ GET $BASE_URL/ratings/statistics - Status: $response"
else
    echo "   ❌ GET $BASE_URL/ratings/statistics - Status: $response"
fi

echo ""
echo "🔐 Testing Authentication Endpoints:"

# Test auth register endpoint (should return validation error)
echo "8. Testing auth register endpoint..."
response=$(curl -s -w "%{http_code}" -o /dev/null -X POST "$BASE_URL/auth/register" \
    -H "Content-Type: application/json" \
    -d '{}')
if [ "$response" = "400" ]; then
    echo "   ✅ POST $BASE_URL/auth/register - Status: $response (Validation error expected)"
else
    echo "   ❌ POST $BASE_URL/auth/register - Status: $response"
fi

# Test auth login endpoint (should return validation error)
echo "9. Testing auth login endpoint..."
response=$(curl -s -w "%{http_code}" -o /dev/null -X POST "$BASE_URL/auth/login" \
    -H "Content-Type: application/json" \
    -d '{}')
if [ "$response" = "400" ]; then
    echo "   ✅ POST $BASE_URL/auth/login - Status: $response (Validation error expected)"
else
    echo "   ❌ POST $BASE_URL/auth/login - Status: $response"
fi

echo ""
echo "📊 Testing Protected Endpoints (should return 401):"

# Test protected endpoints
echo "10. Testing protected users endpoint..."
response=$(curl -s -w "%{http_code}" -o /dev/null "$BASE_URL/users/me")
if [ "$response" = "401" ]; then
    echo "    ✅ GET $BASE_URL/users/me - Status: $response (Unauthorized expected)"
else
    echo "    ❌ GET $BASE_URL/users/me - Status: $response"
fi

echo "11. Testing protected pantry endpoint..."
response=$(curl -s -w "%{http_code}" -o /dev/null "$BASE_URL/pantry")
if [ "$response" = "401" ]; then
    echo "    ✅ GET $BASE_URL/pantry - Status: $response (Unauthorized expected)"
else
    echo "    ❌ GET $BASE_URL/pantry - Status: $response"
fi

echo ""
echo "🎯 Testing Sample Data Endpoints:"

# Test with sample data
echo "12. Testing regions with sample data..."
regions_data=$(curl -s "$BASE_URL/regions")
if echo "$regions_data" | grep -q "BAC\|TRUNG\|NAM"; then
    echo "    ✅ Regions data contains expected values"
else
    echo "    ⚠️  Regions data may be empty (database not seeded)"
fi

echo "13. Testing seasons with sample data..."
seasons_data=$(curl -s "$BASE_URL/seasons")
if echo "$seasons_data" | grep -q "XUAN\|HA\|THU\|DONG"; then
    echo "    ✅ Seasons data contains expected values"
else
    echo "    ⚠️  Seasons data may be empty (database not seeded)"
fi

echo ""
echo "📋 Summary:"
echo "==========="
echo "✅ Backend API: http://localhost:8080/api/v1"
echo "✅ Swagger Documentation: http://localhost:8080/api/v1/docs"
echo "✅ Adminer Database UI: http://localhost:8081"
echo ""
echo "🔧 Database Connection Info:"
echo "   Host: localhost:3306"
echo "   Database: bepviet"
echo "   Username: bepviet"
echo "   Password: secret"
echo ""
echo "📚 Next Steps:"
echo "1. Visit http://localhost:8080/api/v1/docs to explore API documentation"
echo "2. Visit http://localhost:8081 to manage database"
echo "3. Run database migrations and seeds to populate data"
echo "4. Test authentication flow with valid user data"
echo ""
echo "🎉 API Testing Complete!"
