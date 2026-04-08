#!/bin/bash

echo "🗄️ Applying EF Core Migrations..."

# Configuration
PROJECT_PATH="backend-wasm/backend-wasm.csproj"
STARTUP_PROJECT="backend-wasm/src/WebApi"
MIGRATION_NAME="InitialCreate"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if dotnet-ef is installed
if ! command -v dotnet-ef &> /dev/null; then
    echo -e "${YELLOW}Installing dotnet-ef tool...${NC}"
    dotnet tool install --global dotnet-ef
fi

echo -e "${GREEN}Creating initial migration...${NC}"
dotnet ef migrations add $MIGRATION_NAME \
    --project $PROJECT_PATH \
    --startup-project $STARTUP_PROJECT

echo -e "${GREEN}Updating database...${NC}"
dotnet ef database update \
    --project $PROJECT_PATH \
    --startup-project $STARTUP_PROJECT

echo -e "${GREEN}✅ Database migrations completed successfully!${NC}"
