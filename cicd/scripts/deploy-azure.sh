#!/bin/bash

echo "🚀 Deploying Real-time Chat Application to Azure..."

# Configuration
RESOURCE_GROUP="ChatAppResourceGroup"
LOCATION="East US"
BACKEND_APP_NAME="chatapp-backend"
FRONTEND_APP_NAME="chatapp-frontend"
SQL_SERVER_NAME="chatapp-sqlserver"
SQL_DATABASE_NAME="ChatDb"
ADMIN_USER="chatadmin"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Creating resource group...${NC}"
az group create --name $RESOURCE_GROUP --location $LOCATION

echo -e "${GREEN}Creating SQL Server...${NC}"
az sql server create \
    --name $SQL_SERVER_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --admin-user $ADMIN_USER \
    --admin-password $SQL_PASSWORD

echo -e "${GREEN}Creating SQL Database...${NC}"
az sql db create \
    --name $SQL_DATABASE_NAME \
    --server $SQL_SERVER_NAME \
    --resource-group $RESOURCE_GROUP \
    --edition GeneralPurpose \
    --compute-model Serverless \
    --family Gen5 \
    --capacity 2

echo -e "${GREEN}Configuring firewall...${NC}"
az sql server firewall-rule create \
    --resource-group $RESOURCE_GROUP \
    --server $SQL_SERVER_NAME \
    --name AllowAzureIPs \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0

echo -e "${GREEN}Creating App Service Plan...${NC}"
az appservice plan create \
    --name "ChatAppServicePlan" \
    --resource-group $RESOURCE_GROUP \
    --sku B1 \
    --is-linux

echo -e "${GREEN}Deploying Backend...${NC}"
az webapp create \
    --name $BACKEND_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --plan "ChatAppServicePlan" \
    --runtime "DOTNET|8.0" \
    --deployment-local-git

echo -e "${GREEN}Deploying Frontend...${NC}"
az webapp create \
    --name $FRONTEND_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --plan "ChatAppServicePlan" \
    --runtime "DOTNET|8.0" \
    --deployment-local-git

# Get connection string
CONNECTION_STRING=$(az sql db show-connection-string --name $SQL_DATABASE_NAME --server $SQL_SERVER_NAME --client ado.net --output tsv)

echo -e "${GREEN}Setting up Application Settings...${NC}"
az webapp config appsettings set \
    --name $BACKEND_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --settings "ConnectionStrings__DefaultConnection=$CONNECTION_STRING"

echo -e "${YELLOW}Backend URL: https://$BACKEND_APP_NAME.azurewebsites.net${NC}"
echo -e "${YELLOW}Frontend URL: https://$FRONTEND_APP_NAME.azurewebsites.net${NC}"
echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
