#!/bin/bash

echo "🚀 Setting up development environment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Checking prerequisites...${NC}"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not installed. Please install Docker Compose first.${NC}"
    exit 1
fi

# Check if .NET 8 is installed
if ! command -v dotnet &> /dev/null; then
    echo -e "${RED}❌ .NET 8 is not installed. Please install .NET 8 SDK first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ All prerequisites are installed${NC}"

echo -e "${GREEN}Installing dotnet-ef tool...${NC}"
dotnet tool install --global dotnet-ef

echo -e "${GREEN}Copying environment file...${NC}"
if [ ! -f .env ]; then
    cp .env.example .env 2>/dev/null || echo "Creating .env file..."
    echo "# Azure Cognitive Services Configuration (Optional)" > .env
    echo "AZURE_TEXT_ANALYTICS_ENDPOINT=" >> .env
    echo "AZURE_TEXT_ANALYTICS_KEY=" >> .env
    echo "SA_PASSWORD=YourStrongPassword123" >> .env
fi

echo -e "${GREEN}Building and starting services...${NC}"
docker-compose up --build -d

echo -e "${YELLOW}Waiting for services to start...${NC}"
sleep 30

echo -e "${GREEN}Applying database migrations...${NC}"
./cicd/scripts/migrate-db.sh

echo -e "${GREEN}✅ Development environment is ready!${NC}"
echo -e "${YELLOW}🌐 Frontend: http://localhost:5000${NC}"
echo -e "${YELLOW}🔧 Backend API: http://localhost:5001${NC}"
echo -e "${YELLOW}🗄️ Database: localhost:1433${NC}"
echo -e "${YELLOW}📖 Swagger: http://localhost:5001/swagger${NC}"

echo -e "${GREEN}To stop the services, run: docker-compose down${NC}"
echo -e "${GREEN}To view logs, run: docker-compose logs -f${NC}"
