#!/bin/bash

# BẾP VIỆT - Docker Deployment Script
# This script helps deploy the Bếp Việt backend using Docker Compose

set -e

echo "🚀 BẾP VIỆT - Docker Deployment Script"
echo "======================================"

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

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp docker.env.example .env
    echo "✅ .env file created. Please update the values as needed."
fi

# Build and start services
echo "🔨 Building and starting services..."
docker-compose up --build -d

# Wait for services to be healthy
echo "⏳ Waiting for services to be ready..."
sleep 30

# Check service health
echo "🔍 Checking service health..."

# Check MySQL
if docker-compose exec mysql mysqladmin ping -h localhost --silent; then
    echo "✅ MySQL is healthy"
else
    echo "❌ MySQL is not responding"
fi

# Check Backend
if curl -f http://localhost:8080/api/v1 > /dev/null 2>&1; then
    echo "✅ Backend API is healthy"
else
    echo "❌ Backend API is not responding"
fi

# Check Redis
if docker-compose exec redis redis-cli ping | grep -q PONG; then
    echo "✅ Redis is healthy"
else
    echo "❌ Redis is not responding"
fi

echo ""
echo "🎉 Deployment completed!"
echo ""
echo "📊 Service URLs:"
echo "  Backend API: http://localhost:8080/api/v1"
echo "  Adminer (DB): http://localhost:8081"
echo ""
echo "🔧 Useful commands:"
echo "  View logs: docker-compose logs -f"
echo "  Stop services: docker-compose down"
echo "  Restart services: docker-compose restart"
echo "  Update services: docker-compose up --build -d"
echo ""
echo "📚 Next steps:"
echo "  1. Access Adminer at http://localhost:8081 to manage database"
echo "  2. Test API endpoints at http://localhost:8080/api/v1"
echo "  3. Check logs with: docker-compose logs -f backend"
