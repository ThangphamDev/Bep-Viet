#!/bin/bash

# Bếp Việt - Development Setup Script
# This script helps setup the development environment

echo "🍳 Bếp Việt - Development Setup"
echo "================================"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    echo "   Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ All required tools are installed"

# Start Docker services
echo "🐳 Starting Docker services..."
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check if services are running
echo "🔍 Checking service status..."
docker-compose ps

# Install Flutter dependencies
echo "📱 Installing Flutter dependencies..."
cd mobile
flutter pub get
cd ..

# Setup ngrok (if ngrok is installed)
if command -v ngrok &> /dev/null; then
    echo "🌐 Setting up ngrok tunnel..."
    echo "   Please run: ngrok http 8080"
    echo "   Then update mobile/lib/core/config/app_config.dart with your ngrok URL"
else
    echo "⚠️  Ngrok is not installed. Install it from: https://ngrok.com/download"
    echo "   Or use the Docker ngrok service in docker-compose.yml"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Backend API: http://localhost:8080"
echo "   2. Database Admin: http://localhost:8081"
echo "   3. Ngrok Dashboard: http://localhost:4040"
echo "   4. Run Flutter app: cd mobile && flutter run"
echo ""
echo "🔧 Useful commands:"
echo "   - View logs: docker-compose logs -f"
echo "   - Stop services: docker-compose down"
echo "   - Restart services: docker-compose restart"
echo ""
echo "📚 API Documentation: http://localhost:8080/api-docs"
