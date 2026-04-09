# 🚀 Azure Deployment Guide

## 📋 Prerequisites

### 1. Install Azure CLI
```powershell
# Install via PowerShell (Admin)
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile AzureCLI.msi
Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
```

### 2. Azure Login
```powershell
# Interactive login (browser will open)
az login

# Or login with tenant ID
az login --tenant "72f988bf-86f1-41af-91ab-2d7cd011db47"
```

### 3. Verify Subscription
```powershell
az account show --query "{name: name, id: id, tenantId: tenantId}"
```

## 🚀 Deployment

### Automated Deployment (PowerShell)
```powershell
# Run deployment script
.\deploy-azure-auto.ps1
```

### Automated Deployment (Bash)
```bash
# For Linux/macOS/WSL
chmod +x deploy-azure-auto.sh
./deploy-azure-auto.sh
```

## 🧪 Verification

After deployment (2-3 minutes):

```powershell
# Verify deployed application
.\test-deployment.ps1 -FrontendUrl "https://chatapp-frontend-xxx.azurewebsites.net" -BackendUrl "https://chatapp-backend-xxx.azurewebsites.net"
```

## 📊 What Will Be Created

### Azure Resources:
- **Resource Group**: `ChatAppResourceGroup`
- **Backend Web App**: `chatapp-backend-{unique}`
- **Frontend Web App**: `chatapp-frontend-{unique}`
- **SQL Server**: `chatapp-sqlserver-{unique}`
- **SQL Database**: `ChatDb`
- **SignalR Service**: `chatapp-signalr-{unique}`
- **Cognitive Services**: `chat-sentiment-{unique}`

### Configuration:
- ✅ Connection strings configured
- ✅ CORS enabled
- ✅ Application settings set
- ✅ Database created
- ✅ Migrations applied

## 🔗 Available URLs After Deployment

- **Frontend**: `https://chatapp-frontend-{unique}.azurewebsites.net`
- **Backend API**: `https://chatapp-backend-{unique}.azurewebsites.net`
- **Swagger Docs**: `https://chatapp-backend-{unique}.azurewebsites.net/swagger`
- **SignalR**: Automatically configured
- **Database**: `{server}.database.windows.net`

## 🛠️ Resource Management

### View Logs
```powershell
# Backend logs
az webapp log tail --name chatapp-backend-{unique} --resource-group ChatAppResourceGroup

# Frontend logs
az webapp log tail --name chatapp-frontend-{unique} --resource-group ChatAppResourceGroup
```

### Restart Applications
```powershell
az webapp restart --name chatapp-backend-{unique} --resource-group ChatAppResourceGroup
az webapp restart --name chatapp-frontend-{unique} --resource-group ChatAppResourceGroup
```

### Update Settings
```powershell
az webapp config appsettings set --name chatapp-backend-{unique} --resource-group ChatAppResourceGroup --settings "KEY=VALUE"
```

## 🗑️ Cleanup (If Needed)
```powershell
az group delete --name ChatAppResourceGroup --yes --no-wait
```

## ⚠️ Important Notes

1. **Deployment Time**: 5-10 minutes
2. **Cost**: Uses free/cheap tiers (B1, F0)
3. **Security**: Passwords and keys stored in App Settings
4. **Scaling**: Can be scaled via Azure Portal

## 🆘 Support

If issues arise:
1. Check deployment status: `az group show --name ChatAppResourceGroup`
2. View application logs
3. Verify CORS settings and connection strings
4. Ensure all resources are in the same region

## 📈 Monitoring

After deployment, you can set up:
- Application Insights for monitoring
- Azure Monitor for metrics
- Log Analytics for logs
- Alerts for notifications
