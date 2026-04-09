# 🚀 GitHub Deployment Instructions

## 📋 Creating Repository on GitHub

### 1. Create Repository Manually:
1. Go to https://github.com/new
2. **Repository name**: `realtime-chat-app-sentiment`
3. **Description**: `Real-time Chat Application with Sentiment Analysis using ASP.NET Core 8 and Blazor WASM`
4. **Visibility**: Public
5. **Initialize with**: README (optional)
6. Click **Create repository**

### 2. Link Local Repository:
```powershell
# Replace YOUR_USERNAME with your GitHub username
git remote set-url origin https://github.com/YOUR_USERNAME/realtime-chat-app-sentiment.git

# Push code to GitHub
git push -u origin main
```

## 🔧 GitHub Actions Configuration

### 1. Repository Secrets:
Go to `Settings > Secrets and variables > Actions` and add:

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

### 2. Activate GitHub Actions:
- Workflow files are already created in `.github/workflows/`
- CI/CD will start automatically after first push

## 🚀 Automated Deployment

### What GitHub Actions Do:

1. **Build Workflow** (`.github/workflows/build.yml`):
   - ✅ Build Backend (.NET 8)
   - ✅ Build Frontend (Blazor WASM)
   - ✅ Run E2E tests
   - ✅ Create Docker images

2. **Deploy Backend** (`.github/workflows/deploy-backend.yml`):
   - ✅ Deploy Web API to Azure
   - ✅ Apply database migrations
   - ✅ Configure connection strings

3. **Deploy Frontend** (`.github/workflows/deploy-frontend.yml`):
   - ✅ Deploy Blazor WASM to Azure
   - ✅ Configure CORS
   - ✅ Optimize static files

## 📊 Repository Structure

```
realtime-chat-app-sentiment/
├── .github/workflows/          # CI/CD пайплайны
├── backend-wasm/               # ASP.NET Core Web API
│   ├── src/
│   │   ├── Domain/            # Entities and Enums
│   │   ├── Infrastructure/     # DbContext and Repositories  
│   │   ├── Application/       # Services and Interfaces
│   │   ├── WebApi/           # Controllers and SignalR Hub
│   │   └── Tests/            # E2E tests
│   └── Dockerfile
├── frontend/blazor-wasm/       # Blazor WebAssembly
│   ├── Pages/                # UI components
│   ├── Components/           # Reusable components
│   ├── Services/             # SignalR client
│   └── Dockerfile
├── cicd/scripts/              # Deployment scripts
├── docker-compose.yml         # Local development
├── deploy-azure-auto.ps1     # Azure deployment script
├── test-deployment.ps1       # Deployment validation
└── README.md                  # Documentation
```

## 🧪 Local Development

```powershell
# Run via Docker Compose
docker-compose up -d

# Or locally
cd backend-wasm
dotnet run

cd ../frontend/blazor-wasm  
dotnet run
```

## 🌐 Available URLs After Deployment

- **Frontend**: `https://chatapp-frontend-xxx.azurewebsites.net`
- **Backend API**: `https://chatapp-backend-xxx.azurewebsites.net`
- **Swagger**: `https://chatapp-backend-xxx.azurewebsites.net/swagger`
- **Health Check**: `https://chatapp-backend-xxx.azurewebsites.net/health`

## 📈 Monitoring

### GitHub Actions Status:
- Go to `Actions` tab in repository
- View build and deploy logs
- Check test status

### Azure Monitoring:
- Application Insights (if configured)
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
   - Check `.csproj` files
   - Ensure all NuGet packages are available
   - Verify C# code syntax

2. **Deploy Failures**:
   - Check Azure credentials in Secrets
   - Ensure Azure resources exist
   - Verify connection strings

3. **Test Failures**:
   - Check test data
   - Ensure all dependencies are available
   - View test logs in Actions

### Manual Recovery:

```powershell
# Rebuild and redeploy manually
./deploy-azure-auto.ps1

# Check status
./test-deployment.ps1 -FrontendUrl "https://..." -BackendUrl "https://..."
```

## 📝 Next Steps

1. ✅ Create repository on GitHub
2. ✅ Push code with instructions above
3. ✅ Configure Secrets in GitHub
4. ✅ Launch first deployment via Actions
5. ✅ Verify functionality
6. ✅ Configure monitoring and alerts

**Ready for production deployment!** 🚀
