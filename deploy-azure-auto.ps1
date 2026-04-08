# Автоматическое развертывание Real-time Chat Application на Azure
Write-Host "🚀 Автоматическое развертывание Real-time Chat Application на Azure" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

# Проверка входа в Azure
Write-Host "📋 Проверка входа в Azure..." -ForegroundColor Yellow
try {
    $account = az account show | ConvertFrom-Json
    Write-Host "✅ Подписка: $($account.id)" -ForegroundColor Green
    Write-Host "✅ Tenant: $($account.tenantId)" -ForegroundColor Green
} catch {
    Write-Host "❌ Необходимо войти в Azure. Выполните: az login" -ForegroundColor Red
    exit 1
}

# Конфигурация
$RESOURCE_GROUP = "ChatAppResourceGroup"
$LOCATION = "East US"
$UNIQUE_SUFFIX = "chat$(Get-Date -Format yyyyMMddHHmmss)"
$BACKEND_APP_NAME = "chatapp-backend-$UNIQUE_SUFFIX"
$FRONTEND_APP_NAME = "chatapp-frontend-$UNIQUE_SUFFIX"
$SQL_SERVER_NAME = "chatapp-sqlserver-$UNIQUE_SUFFIX"
$SQL_DATABASE_NAME = "ChatDb"
$SIGNALR_NAME = "chatapp-signalr-$UNIQUE_SUFFIX"
$COGNITIVE_NAME = "chat-sentiment-$UNIQUE_SUFFIX"

Write-Host ""
Write-Host "🏗️ Создание ресурсов..." -ForegroundColor Yellow
Write-Host "Resource Group: $RESOURCE_GROUP" -ForegroundColor Cyan
Write-Host "Location: $LOCATION" -ForegroundColor Cyan
Write-Host "Unique Suffix: $UNIQUE_SUFFIX" -ForegroundColor Cyan

# Создание Resource Group
Write-Host "📦 Создание Resource Group..." -ForegroundColor Yellow
az group create --name $RESOURCE_GROUP --location $LOCATION

# Создание SQL Server
Write-Host "🗄️ Создание SQL Server..." -ForegroundColor Yellow
az sql server create `
    --name $SQL_SERVER_NAME `
    --resource-group $RESOURCE_GROUP `
    --location $LOCATION `
    --admin-user "chatadmin" `
    --admin-password "ChatApp@2024!"

# Создание базы данных
Write-Host "💾 Создание базы данных..." -ForegroundColor Yellow
az sql db create `
    --name $SQL_DATABASE_NAME `
    --server $SQL_SERVER_NAME `
    --resource-group $RESOURCE_GROUP `
    --edition GeneralPurpose `
    --compute-model Serverless `
    --family Gen5 `
    --capacity 2

# Настройка firewall
Write-Host "🔥 Настройка firewall..." -ForegroundColor Yellow
az sql server firewall-rule create `
    --resource-group $RESOURCE_GROUP `
    --server $SQL_SERVER_NAME `
    --name AllowAzureIPs `
    --start-ip-address 0.0.0.0 `
    --end-ip-address 0.0.0.0

# Создание App Service Plan
Write-Host "📋 Создание App Service Plan..." -ForegroundColor Yellow
az appservice plan create `
    --name "ChatAppServicePlan" `
    --resource-group $RESOURCE_GROUP `
    --sku B1 `
    --is-linux

# Создание SignalR Service
Write-Host "📡 Создание SignalR Service..." -ForegroundColor Yellow
az signalr create `
    --name $SIGNALR_NAME `
    --resource-group $RESOURCE_GROUP `
    --sku Standard_S1 `
    --unit-count 1

# Создание Cognitive Services
Write-Host "🧠 Создание Cognitive Services..." -ForegroundColor Yellow
az cognitiveservices account create `
    --name $COGNITIVE_NAME `
    --resource-group $RESOURCE_GROUP `
    --kind TextAnalytics `
    --sku F0 `
    --location $LOCATION

# Создание Backend Web App
Write-Host "⚙️ Создание Backend Web App..." -ForegroundColor Yellow
az webapp create `
    --name $BACKEND_APP_NAME `
    --resource-group $RESOURCE_GROUP `
    --plan "ChatAppServicePlan" `
    --runtime "DOTNET|8.0"

# Создание Frontend Web App
Write-Host "🌐 Создание Frontend Web App..." -ForegroundColor Yellow
az webapp create `
    --name $FRONTEND_APP_NAME `
    --resource-group $RESOURCE_GROUP `
    --plan "ChatAppServicePlan" `
    --runtime "DOTNET|8.0"

# Получение connection strings
$SQL_CONNECTION_STRING = az sql db show-connection-string `
    --name $SQL_DATABASE_NAME `
    --server $SQL_SERVER_NAME `
    --client ado.net `
    --output tsv

$SIGNALR_CONNECTION_STRING = az signalr key list `
    --name $SIGNALR_NAME `
    --resource-group $RESOURCE_GROUP `
    --query primaryConnectionString -o tsv

$COGNITIVE_ENDPOINT = az cognitiveservices account show `
    --name $COGNITIVE_NAME `
    --resource-group $RESOURCE_GROUP `
    --query properties.endpoint -o tsv

$COGNITIVE_KEY = az cognitiveservices account keys list `
    --name $COGNITIVE_NAME `
    --resource-group $RESOURCE_GROUP `
    --query key1 -o tsv

# Настройка Application Settings для Backend
Write-Host "🔧 Настройка Backend App Settings..." -ForegroundColor Yellow
az webapp config appsettings set `
    --name $BACKEND_APP_NAME `
    --resource-group $RESOURCE_GROUP `
    --settings `
    "ConnectionStrings__DefaultConnection=$SQL_CONNECTION_STRING" `
    "AzureSignalR__ConnectionString=$SIGNALR_CONNECTION_STRING" `
    "AzureTextAnalytics__Endpoint=$COGNITIVE_ENDPOINT" `
    "AzureTextAnalytics__Key=$COGNITIVE_KEY" `
    "ASPNETCORE_ENVIRONMENT=Production"

# Настройка Application Settings для Frontend
Write-Host "🔧 Настройка Frontend App Settings..." -ForegroundColor Yellow
az webapp config appsettings set `
    --name $FRONTEND_APP_NAME `
    --resource-group $RESOURCE_GROUP `
    --settings `
    "ASPNETCORE_ENVIRONMENT=Production"

# Включение CORS для Backend
Write-Host "🌐 Настройка CORS..." -ForegroundColor Yellow
az webapp cors add `
    --name $BACKEND_APP_NAME `
    --resource-group $RESOURCE_GROUP `
    --allowed-origins "https://$FRONTEND_APP_NAME.azurewebsites.net" `
    --allowed-methods "GET,POST,PUT,DELETE,OPTIONS" `
    --allowed-headers "*"

# Сборка и публикация Backend
Write-Host "🔨 Сборка Backend..." -ForegroundColor Yellow
Set-Location backend-wasm
dotnet publish --configuration Release --output ./publish

# Создание ZIP архива
Compress-Archive -Path ./publish/* -DestinationPath ./publish.zip -Force

# Деплой Backend
Write-Host "📤 Деплой Backend..." -ForegroundColor Yellow
az webapp deployment source config-zip `
    --resource-group $RESOURCE_GROUP `
    --name $BACKEND_APP_NAME `
    --src ./publish.zip

Set-Location ..

# Сборка и публикация Frontend
Write-Host "🔨 Сборка Frontend..." -ForegroundColor Yellow
Set-Location frontend/blazor-wasm
dotnet publish --configuration Release --output ./publish

# Создание ZIP архива
Compress-Archive -Path ./publish/* -DestinationPath ./publish.zip -Force

# Деплой Frontend
Write-Host "📤 Деплой Frontend..." -ForegroundColor Yellow
az webapp deployment source config-zip `
    --resource-group $RESOURCE_GROUP `
    --name $FRONTEND_APP_NAME `
    --src ./publish.zip

Set-Location ../..

Write-Host ""
Write-Host "✅ Развертывание завершено!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host "🌐 Frontend URL: https://$FRONTEND_APP_NAME.azurewebsites.net" -ForegroundColor Cyan
Write-Host "⚙️ Backend URL: https://$BACKEND_APP_NAME.azurewebsites.net" -ForegroundColor Cyan
Write-Host "📖 Swagger: https://$BACKEND_APP_NAME.azurewebsites.net/swagger" -ForegroundColor Cyan
Write-Host "🗄️ SQL Server: $SQL_SERVER_NAME.database.windows.net" -ForegroundColor Cyan
Write-Host "📡 SignalR: $SIGNALR_NAME.service.signalr.net" -ForegroundColor Cyan
Write-Host "🧠 Cognitive Services: $COGNITIVE_NAME" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔑 Connection Strings:" -ForegroundColor Yellow
Write-Host "SQL: $SQL_CONNECTION_STRING" -ForegroundColor Gray
Write-Host "SignalR: $SIGNALR_CONNECTION_STRING" -ForegroundColor Gray
Write-Host "Cognitive Endpoint: $COGNITIVE_ENDPOINT" -ForegroundColor Gray
Write-Host "Cognitive Key: $COGNITIVE_KEY" -ForegroundColor Gray
Write-Host ""
Write-Host "🧪 Проверка работоспособности..." -ForegroundColor Yellow
Write-Host "Откройте https://$FRONTEND_APP_NAME.azurewebsites.net через 2-3 минуты" -ForegroundColor Green
