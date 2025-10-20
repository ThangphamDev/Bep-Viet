@echo off
echo 🧪 GEMINI API TEST SUITE
echo ========================
echo.

echo 📦 Installing dependencies...
npm install
echo.

echo 🚀 Running JavaScript tests...
echo.
echo 1. Quick Test:
node quick_test.js
echo.

echo 2. Full Test Suite:
node test_gemini.js
echo.

echo 🎯 Running Flutter Dart test...
dart test_flutter_gemini.dart
echo.

echo ✅ All tests completed!
pause


