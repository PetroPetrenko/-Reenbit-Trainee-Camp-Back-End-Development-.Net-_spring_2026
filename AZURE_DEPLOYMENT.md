# 🚀 Автоматическое развертывание на Azure

## 📋 Подготовка

### 1. Установка Azure CLI
```powershell
# Установка через PowerShell (Admin)
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile AzureCLI.msi
Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
```

### 2. Вход в Azure
```powershell
# Интерактивный вход (откроется браузер)
az login

# Или вход с tenant ID
az login --tenant "72f988bf-86f1-41af-91ab-2d7cd011db47"
```

### 3. Проверка подписки
```powershell
az account show --query "{name: name, id: id, tenantId: tenantId}"
```

## 🚀 Развертывание

### Автоматическое развертывание (PowerShell)
```powershell
# Запуск скрипта развертывания
.\deploy-azure-auto.ps1
```

### Автоматическое развертывание (Bash)
```bash
# Для Linux/macOS/WSL
chmod +x deploy-azure-auto.sh
./deploy-azure-auto.sh
```

## 🧪 Проверка работоспособности

После развертывания (2-3 минуты):

```powershell
# Проверка развернутого приложения
.\test-deployment.ps1 -FrontendUrl "https://chatapp-frontend-xxx.azurewebsites.net" -BackendUrl "https://chatapp-backend-xxx.azurewebsites.net"
```

## 📊 Что будет создано

### Azure Resources:
- **Resource Group**: `ChatAppResourceGroup`
- **Backend Web App**: `chatapp-backend-{unique}`
- **Frontend Web App**: `chatapp-frontend-{unique}`
- **SQL Server**: `chatapp-sqlserver-{unique}`
- **SQL Database**: `ChatDb`
- **SignalR Service**: `chatapp-signalr-{unique}`
- **Cognitive Services**: `chat-sentiment-{unique}`

### Configuration:
- ✅ Connection strings настроены
- ✅ CORS включен
- ✅ Application settings установлены
- ✅ База данных создана
- ✅ Миграции применены

## 🔗 Доступные URL после развертывания

- **Frontend**: `https://chatapp-frontend-{unique}.azurewebsites.net`
- **Backend API**: `https://chatapp-backend-{unique}.azurewebsites.net`
- **Swagger Docs**: `https://chatapp-backend-{unique}.azurewebsites.net/swagger`
- **SignalR**: Автоматически настроен
- **Database**: `{server}.database.windows.net`

## 🛠️ Управление ресурсами

### Просмотр логов
```powershell
# Логи бэкенда
az webapp log tail --name chatapp-backend-{unique} --resource-group ChatAppResourceGroup

# Логи фронтенда
az webapp log tail --name chatapp-frontend-{unique} --resource-group ChatAppResourceGroup
```

### Перезапуск приложений
```powershell
az webapp restart --name chatapp-backend-{unique} --resource-group ChatAppResourceGroup
az webapp restart --name chatapp-frontend-{unique} --resource-group ChatAppResourceGroup
```

### Обновление настроек
```powershell
az webapp config appsettings set --name chatapp-backend-{unique} --resource-group ChatAppResourceGroup --settings "KEY=VALUE"
```

## 🗑️ Удаление ресурсов (если нужно)
```powershell
az group delete --name ChatAppResourceGroup --yes --no-wait
```

## ⚠️ Важные замечания

1. **Время развертывания**: 5-10 минут
2. **Стоимость**: Используются бесплатные/дешевые tier'ы (B1, F0)
3. **Безопасность**: Пароли и ключи хранятся в App Settings
4. **Масштабирование**: Можно масштабировать через Azure Portal

## 🆘 Поддержка

Если возникнут проблемы:
1. Проверьте статус развертывания: `az group show --name ChatAppResourceGroup`
2. Посмотрите логи приложений
3. Проверьте настройки CORS и connection strings
4. Убедитесь что все ресурсы созданы в одном регионе

## 📈 Мониторинг

После развертывания можно настроить:
- Application Insights для мониторинга
- Azure Monitor для метрик
- Log Analytics для логов
- Alerts для уведомлений
