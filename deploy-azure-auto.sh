#!/bin/bash

echo "🚀 Автоматическое развертывание Real-time Chat Application на Azure"
echo "=================================================="

# Проверка входа в Azure
echo "📋 Проверка входа в Azure..."
if ! az account show &> /dev/null; then
    echo "❌ Необходимо войти в Azure. Выполните: az login"
    exit 1
fi

# Получение данных подписки
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)
echo "✅ Подписка: $SUBSCRIPTION_ID"
echo "✅ Tenant: $TENANT_ID"

# Конфигурация
RESOURCE_GROUP="ChatAppResourceGroup"
LOCATION="East US"
UNIQUE_SUFFIX="chat$(date +%s)"
BACKEND_APP_NAME="chatapp-backend-$UNIQUE_SUFFIX"
FRONTEND_APP_NAME="chatapp-frontend-$UNIQUE_SUFFIX"
SQL_SERVER_NAME="chatapp-sqlserver-$UNIQUE_SUFFIX"
SQL_DATABASE_NAME="ChatDb"
SIGNALR_NAME="chatapp-signalr-$UNIQUE_SUFFIX"
COGNITIVE_NAME="chat-sentiment-$UNIQUE_SUFFIX"

echo ""
echo "🏗️ Создание ресурсов..."
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo "Unique Suffix: $UNIQUE_SUFFIX"

# Создание Resource Group
echo "📦 Создание Resource Group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

# Создание SQL Server
echo "🗄️ Создание SQL Server..."
az sql server create \
    --name $SQL_SERVER_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --admin-user "chatadmin" \
    --admin-password "ChatApp@2024!"

# Создание базы данных
echo "💾 Создание базы данных..."
az sql db create \
    --name $SQL_DATABASE_NAME \
    --server $SQL_SERVER_NAME \
    --resource-group $RESOURCE_GROUP \
    --edition GeneralPurpose \
    --compute-model Serverless \
    --family Gen5 \
    --capacity 2

# Настройка firewall
echo "🔥 Настройка firewall..."
az sql server firewall-rule create \
    --resource-group $RESOURCE_GROUP \
    --server $SQL_SERVER_NAME \
    --name AllowAzureIPs \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0

# Создание App Service Plan
echo "📋 Создание App Service Plan..."
az appservice plan create \
    --name "ChatAppServicePlan" \
    --resource-group $RESOURCE_GROUP \
    --sku B1 \
    --is-linux

# Создание SignalR Service
echo "📡 Создание SignalR Service..."
az signalr create \
    --name $SIGNALR_NAME \
    --resource-group $RESOURCE_GROUP \
    --sku Standard_S1 \
    --unit-count 1

# Создание Cognitive Services
echo "🧠 Создание Cognitive Services..."
az cognitiveservices account create \
    --name $COGNITIVE_NAME \
    --resource-group $RESOURCE_GROUP \
    --kind TextAnalytics \
    --sku F0 \
    --location $LOCATION

# Создание Backend Web App
echo "⚙️ Создание Backend Web App..."
az webapp create \
    --name $BACKEND_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --plan "ChatAppServicePlan" \
    --runtime "DOTNET|8.0"

# Создание Frontend Web App
echo "🌐 Создание Frontend Web App..."
az webapp create \
    --name $FRONTEND_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --plan "ChatAppServicePlan" \
    --runtime "DOTNET|8.0"

# Получение connection strings
SQL_CONNECTION_STRING=$(az sql db show-connection-string \
    --name $SQL_DATABASE_NAME \
    --server $SQL_SERVER_NAME \
    --client ado.net \
    --output tsv)

SIGNALR_CONNECTION_STRING=$(az signalr key list \
    --name $SIGNALR_NAME \
    --resource-group $RESOURCE_GROUP \
    --query primaryConnectionString -o tsv)

COGNITIVE_ENDPOINT=$(az cognitiveservices account show \
    --name $COGNITIVE_NAME \
    --resource-group $RESOURCE_GROUP \
    --query properties.endpoint -o tsv)

COGNITIVE_KEY=$(az cognitiveservices account keys list \
    --name $COGNITIVE_NAME \
    --resource-group $RESOURCE_GROUP \
    --query key1 -o tsv)

# Настройка Application Settings для Backend
echo "🔧 Настройка Backend App Settings..."
az webapp config appsettings set \
    --name $BACKEND_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --settings \
    "ConnectionStrings__DefaultConnection=$SQL_CONNECTION_STRING" \
    "AzureSignalR__ConnectionString=$SIGNALR_CONNECTION_STRING" \
    "AzureTextAnalytics__Endpoint=$COGNITIVE_ENDPOINT" \
    "AzureTextAnalytics__Key=$COGNITIVE_KEY" \
    "ASPNETCORE_ENVIRONMENT=Production"

# Настройка Application Settings для Frontend
echo "🔧 Настройка Frontend App Settings..."
az webapp config appsettings set \
    --name $FRONTEND_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --settings \
    "ASPNETCORE_ENVIRONMENT=Production"

# Включение CORS для Backend
echo "🌐 Настройка CORS..."
az webapp cors add \
    --name $BACKEND_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --allowed-origins "https://$FRONTEND_APP_NAME.azurewebsites.net" \
    --allowed-methods "GET,POST,PUT,DELETE,OPTIONS" \
    --allowed-headers "*"

# Сборка и публикация Backend
echo "🔨 Сборка Backend..."
cd backend-wasm
dotnet publish --configuration Release --output ./publish

# Деплой Backend
echo "📤 Деплой Backend..."
az webapp deployment source config-zip \
    --resource-group $RESOURCE_GROUP \
    --name $BACKEND_APP_NAME \
    --src ./publish.zip

cd ..

# Сборка и публикация Frontend
echo "🔨 Сборка Frontend..."
cd frontend/blazor-wasm
dotnet publish --configuration Release --output ./publish

# Деплой Frontend
echo "📤 Деплой Frontend..."
az webapp deployment source config-zip \
    --resource-group $RESOURCE_GROUP \
    --name $FRONTEND_APP_NAME \
    --src ./publish.zip

cd ../..

# Применение миграций базы данных
echo "🗄️ Применение миграций базы данных..."
cd backend-wasm
dotnet ef database update \
    --connection "$SQL_CONNECTION_STRING"
cd ..

echo ""
echo "✅ Развертывание завершено!"
echo "=================================================="
echo "🌐 Frontend URL: https://$FRONTEND_APP_NAME.azurewebsites.net"
echo "⚙️ Backend URL: https://$BACKEND_APP_NAME.azurewebsites.net"
echo "📖 Swagger: https://$BACKEND_APP_NAME.azurewebsites.net/swagger"
echo "🗄️ SQL Server: $SQL_SERVER_NAME.database.windows.net"
echo "📡 SignalR: $SIGNALR_NAME.service.signalr.net"
echo "🧠 Cognitive Services: $COGNITIVE_NAME"
echo ""
echo "🔑 Connection Strings:"
echo "SQL: $SQL_CONNECTION_STRING"
echo "SignalR: $SIGNALR_CONNECTION_STRING"
echo "Cognitive Endpoint: $COGNITIVE_ENDPOINT"
echo "Cognitive Key: $COGNITIVE_KEY"
echo ""
echo "🧪 Проверка работоспособности..."
echo "Откройте https://$FRONTEND_APP_NAME.azurewebsites.net через 2-3 минуты"
