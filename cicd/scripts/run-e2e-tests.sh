#!/bin/bash

echo "🧪 Running E2E Tests for Chat Application..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Navigate to tests directory
cd backend-wasm/src/Tests

echo -e "${GREEN}Installing Playwright browsers...${NC}"
npx playwright install

echo -e "${GREEN}Building application...${NC}"
dotnet build ../WebApi --configuration Release

echo -e "${GREEN}Running API E2E Tests...${NC}"
dotnet test --configuration Release --filter "Category=API" --logger "console;verbosity=detailed"

echo -e "${GREEN}Running SignalR E2E Tests...${NC}"
dotnet test --configuration Release --filter "Category=SignalR" --logger "console;verbosity=detailed"

echo -e "${GREEN}Running UI E2E Tests with Playwright...${NC}"
dotnet test --configuration Release --filter "Category=UI" --logger "console;verbosity=detailed"

echo -e "${GREEN}Generating test reports...${NC}"
npx playwright show-report

echo -e "${GREEN}✅ All E2E tests completed!${NC}"
echo -e "${YELLOW}📊 Test reports available in playwright-report/index.html${NC}"
