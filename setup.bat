@echo off
REM Bếp Việt - Development Setup Script for Windows
REM This script helps setup the development environment

echo 🍳 Bếp Việt - Development Setup
echo ================================

REM Check if Docker is installed
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker is not installed. Please install Docker first.
    pause
    exit /b 1
)

REM Check if Docker Compose is installed
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker Compose is not installed. Please install Docker Compose first.
    pause
    exit /b 1
)

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter is not installed. Please install Flutter first.
    echo    Visit: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo ✅ All required tools are installed

REM Start Docker services
echo 🐳 Starting Docker services...
docker-compose up -d

REM Wait for services to be ready
echo ⏳ Waiting for services to be ready...
timeout /t 10 /nobreak >nul

REM Check if services are running
echo 🔍 Checking service status...
docker-compose ps

REM Install Flutter dependencies
echo 📱 Installing Flutter dependencies...
cd mobile
flutter pub get
cd ..

REM Setup ngrok (if ngrok is installed)
ngrok version >nul 2>&1
if %errorlevel% equ 0 (
    echo 🌐 Setting up ngrok tunnel...
    echo    Please run: ngrok http 8080
    echo    Then update mobile\lib\core\config\app_config.dart with your ngrok URL
) else (
    echo ⚠️  Ngrok is not installed. Install it from: https://ngrok.com/download
    echo    Or use the Docker ngrok service in docker-compose.yml
)

echo.
echo 🎉 Setup complete!
echo.
echo 📋 Next steps:
echo    1. Backend API: http://localhost:8080
echo    2. Database Admin: http://localhost:8081
echo    3. Ngrok Dashboard: http://localhost:4040
echo    4. Run Flutter app: cd mobile ^&^& flutter run
echo.
echo 🔧 Useful commands:
echo    - View logs: docker-compose logs -f
echo    - Stop services: docker-compose down
echo    - Restart services: docker-compose restart
echo.
echo 📚 API Documentation: http://localhost:8080/api-docs
pause
