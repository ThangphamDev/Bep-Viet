# Gemini API Test Suite
Write-Host "🧪 GEMINI API TEST SUITE" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green
Write-Host ""

# Check if Node.js is installed
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js version: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js not found. Please install Node.js first." -ForegroundColor Red
    exit 1
}

# Check if Dart is installed
try {
    $dartVersion = dart --version
    Write-Host "✅ Dart version: $dartVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Dart not found. Please install Dart first." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
npm install

Write-Host ""
Write-Host "🚀 Running JavaScript tests..." -ForegroundColor Yellow
Write-Host ""

Write-Host "1. Quick Test:" -ForegroundColor Cyan
node quick_test.js
Write-Host ""

Write-Host "2. Full Test Suite:" -ForegroundColor Cyan
node test_gemini.js
Write-Host ""

Write-Host "🎯 Running Flutter Dart test..." -ForegroundColor Yellow
dart test_flutter_gemini.dart
Write-Host ""

Write-Host "✅ All tests completed!" -ForegroundColor Green
Read-Host "Press Enter to continue..."


