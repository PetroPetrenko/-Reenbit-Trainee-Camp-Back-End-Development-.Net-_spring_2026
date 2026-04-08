# 🚀 GitHub Deployment Instructions

## 📋 Создание репозитория на GitHub

### 1. Создайте репозиторий вручную:
1. Перейдите на https://github.com/new
2. **Repository name**: `realtime-chat-app-sentiment`
3. **Description**: `Real-time Chat Application with Sentiment Analysis using ASP.NET Core 8 and Blazor WASM`
4. **Visibility**: Public
5. **Initialize with**: README (можно убрать)
6. Нажмите **Create repository**

### 2. Свяжите локальный репозиторий:
```powershell
# Замените YOUR_USERNAME на ваш GitHub username
git remote set-url origin https://github.com/YOUR_USERNAME/realtime-chat-app-sentiment.git

# Отправьте код на GitHub
git push -u origin main
```

## 🔧 Настройка GitHub Actions

### 1. Секреты репозитория:
Перейдите в `Settings > Secrets and variables > Actions` и добавьте:

```
AZURE_CREDENTIALS
{
  "clientId": "your-client-id",
  "clientSecret": "your-client-secret", 
  "subscriptionId": "your-subscription-id",
  "tenantId": "your-tenant-id"
}

AZURE_WEBAPP_NAME_BACKEND
chatapp-backend-xxx

AZURE_WEBAPP_NAME_FRONTEND  
chatapp-frontend-xxx

AZURE_RESOURCE_GROUP
ChatAppResourceGroup

AZURE_SQL_CONNECTION_STRING
Server=xxx.database.windows.net;Database=ChatDb;User Id=chatadmin;Password=xxx;

AZURE_SIGNALR_CONNECTION_STRING
Endpoint=https://xxx.service.signalr.net;AccessKey=xxx;

AZURE_TEXT_ANALYTICS_ENDPOINT
https://xxx.cognitiveservices.azure.com/

AZURE_TEXT_ANALYTICS_KEY
your-cognitive-services-key
```

### 2. Активация GitHub Actions:
- Файлы воркфлоу уже созданы в `.github/workflows/`
- После первого push автоматически запустится CI/CD

## 🚀 Автоматический деплой

### Что делают GitHub Actions:

1. **Build Workflow** (`.github/workflows/build.yml`):
   - ✅ Сборка Backend (.NET 8)
   - ✅ Сборка Frontend (Blazor WASM)
   - ✅ Запуск E2E тестов
   - ✅ Создание Docker образов

2. **Deploy Backend** (`.github/workflows/deploy-backend.yml`):
   - ✅ Деплой Web API на Azure
   - ✅ Применение миграций базы данных
   - ✅ Настройка connection strings

3. **Deploy Frontend** (`.github/workflows/deploy-frontend.yml`):
   - ✅ Деплой Blazor WASM на Azure
   - ✅ Настройка CORS
   - ✅ Оптимизация статических файлов

## 📊 Структура репозитория

```
realtime-chat-app-sentiment/
├── .github/workflows/          # CI/CD пайплайны
├── backend-wasm/               # ASP.NET Core Web API
│   ├── src/
│   │   ├── Domain/            # Entities и Enums
│   │   ├── Infrastructure/     # DbContext и Repositories  
│   │   ├── Application/       # Services и Interfaces
│   │   ├── WebApi/           # Controllers и SignalR Hub
│   │   └── Tests/            # E2E тесты
│   └── Dockerfile
├── frontend/blazor-wasm/       # Blazor WebAssembly
│   ├── Pages/                # UI компоненты
│   ├── Components/           # Reusable компоненты
│   ├── Services/             # SignalR клиент
│   └── Dockerfile
├── cicd/scripts/              # Скрипты развертывания
├── docker-compose.yml         # Local development
├── deploy-azure-auto.ps1     # Azure deployment script
├── test-deployment.ps1       # Deployment validation
└── README.md                  # Documentation
```

## 🧪 Локальный запуск

```powershell
# Запуск через Docker Compose
docker-compose up -d

# Или локально
cd backend-wasm
dotnet run

cd ../frontend/blazor-wasm  
dotnet run
```

## 🌐 Доступные URL после деплоя

- **Frontend**: `https://chatapp-frontend-xxx.azurewebsites.net`
- **Backend API**: `https://chatapp-backend-xxx.azurewebsites.net`
- **Swagger**: `https://chatapp-backend-xxx.azurewebsites.net/swagger`
- **Health Check**: `https://chatapp-backend-xxx.azurewebsites.net/health`

## 📈 Мониторинг

### GitHub Actions Status:
- Переходите в `Actions` таб репозитория
- Смотрите логи сборки и деплоя
- Проверяйте статус тестов

### Azure Monitoring:
- Application Insights (если настроен)
- Azure Monitor alerts
- Log Analytics

## 🔄 CI/CD Process Flow

```
Push to Main Branch
        ↓
GitHub Actions Trigger
        ↓
Build & Test Phase
        ↓
Docker Image Build
        ↓
Deploy to Azure Staging
        ↓
Health Checks
        ↓
Production Deployment
        ↓
E2E Tests Validation
```

## 🛠️ Troubleshooting

### Common Issues:

1. **Build Failures**:
   - Проверьте `.csproj` файлы
   - Убедитесь что все NuGet пакеты доступны
   - Проверьте синтаксис C# кода

2. **Deploy Failures**:
   - Проверьте Azure credentials в Secrets
   - Убедитесь что ресурсы Azure существуют
   - Проверьте connection strings

3. **Test Failures**:
   - Проверьте тестовые данные
   - Убедитесь что все зависимости доступны
   - Посмотрите логи тестов в Actions

### Manual Recovery:

```powershell
# Пересобрать и задеплоить вручную
./deploy-azure-auto.ps1

# Проверить статус
./test-deployment.ps1 -FrontendUrl "https://..." -BackendUrl "https://..."
```

## 📝 Next Steps

1. ✅ Создайте репозиторий на GitHub
2. ✅ Запушьте код с инструкцией выше
3. ✅ Настройте Secrets в GitHub
4. ✅ Запустите первый деплой через Actions
5. ✅ Проверьте работоспособность
6. ✅ Настройте мониторинг и alerts

**Готово к продакшн развертыванию!** 🚀
