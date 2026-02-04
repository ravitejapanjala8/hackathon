# Quick Start Guide

## 🚀 Quick Start - Deploy in 5 Minutes

### 1. Prerequisites Check

```bash
# Check .NET installation
dotnet --version
# Should show 8.0 or higher

# Check Azure CLI (optional for local testing)
az --version
```

### 2. Run the API Locally

```bash
# Build and run
dotnet run

# Test endpoints (in another terminal)
curl http://localhost:5000/api/health
curl http://localhost:5000/api/users
```

### 3. Configure Azure (One-time Setup)

```bash
# 1. Create service principal and save the output
az ad sp create-for-rbac --name "github-apim-deploy" \
  --role contributor \
  --scopes /subscriptions/{YOUR_SUBSCRIPTION_ID}/resourceGroups/{YOUR_RESOURCE_GROUP} \
  --sdk-auth

# 2. Add secrets to GitHub:
# Go to: Settings → Secrets and variables → Actions
# Add these secrets:
#   - AZURE_CREDENTIALS (entire JSON output from above)
#   - APIM_RESOURCE_GROUP (your resource group name)
#   - APIM_SERVICE_NAME (your APIM service name)
```

### 4. Deploy to APIM

```bash
# Option A: Automatic deployment
# Just commit changes to swagger.yaml
git add swagger.yaml
git commit -m "Update API"
git push

# Option B: Manual workflow trigger
# Go to Actions tab → Deploy to Azure APIM → Run workflow

# Option C: Local deployment
pwsh ./deploy-to-apim.ps1 \
  -ResourceGroupName "my-apim-rg" \
  -ApimServiceName "my-apim-service" \
  -ApiId "sample-api"
```

### 5. Test Your Deployed API

```bash
# Replace with your APIM service name
curl https://{your-apim-service}.azure-api.net/sample-api/api/health
curl https://{your-apim-service}.azure-api.net/sample-api/api/users
```

## 📋 API Endpoints Summary

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/health` | Health check |
| GET | `/api/users` | List all users |
| GET | `/api/users/{id}` | Get user by ID |
| POST | `/api/users` | Create user |
| PUT | `/api/users/{id}` | Update user |
| DELETE | `/api/users/{id}` | Delete user |

## 🔑 Required GitHub Secrets

| Secret | Required | Default | Description |
|--------|----------|---------|-------------|
| `AZURE_CREDENTIALS` | ✅ Yes | - | Service principal JSON |
| `APIM_RESOURCE_GROUP` | ✅ Yes | - | Azure resource group |
| `APIM_SERVICE_NAME` | ✅ Yes | - | APIM service name |
| `API_ID` | ⚪ No | `sample-api` | API identifier |
| `API_PATH` | ⚪ No | `sample-api` | API URL path |
| `SERVICE_URL` | ⚪ No | `https://api.example.com` | Backend URL |

## 📁 Project Structure

```
hackathon/
├── Controllers/               # API Controllers
│   ├── HealthController.cs   # Health check endpoint
│   └── UsersController.cs    # User CRUD operations
├── Models/
│   └── Models.cs             # Data models
├── Properties/
│   └── launchSettings.json   # Launch configuration
├── .github/workflows/
│   └── deploy-apim.yml       # GitHub Actions workflow
├── swagger.yaml              # OpenAPI specification
├── deploy-to-apim.ps1        # Deployment script
├── Program.cs                # Application entry point
├── SampleApi.csproj          # Project file
├── README.md                 # Full documentation
└── SETUP-GUIDE.md            # Detailed setup guide
```

## 🛠️ Common Commands

### Development

```bash
# Restore dependencies
dotnet restore

# Build project
dotnet build

# Run application
dotnet run

# Run with specific port
dotnet run --urls "http://localhost:8080"
```

### Testing

```bash
# Test health endpoint
curl http://localhost:5000/api/health

# Create a user
curl -X POST http://localhost:5000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com"}'

# Get all users
curl http://localhost:5000/api/users

# Get specific user
curl http://localhost:5000/api/users/1

# Update user
curl -X PUT http://localhost:5000/api/users/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"Updated Name","email":"updated@example.com"}'

# Delete user
curl -X DELETE http://localhost:5000/api/users/1
```

### Azure Deployment

```bash
# Login to Azure
az login

# List APIM services
az apim list --resource-group my-apim-rg

# View APIM details
az apim show --name my-apim-service --resource-group my-apim-rg

# List APIs in APIM
az apim api list --service-name my-apim-service --resource-group my-apim-rg

# Delete an API
az apim api delete --api-id sample-api \
  --service-name my-apim-service \
  --resource-group my-apim-rg
```

## 🐛 Troubleshooting Quick Fixes

### Build Fails
```bash
# Clean and rebuild
dotnet clean
dotnet restore
dotnet build
```

### Azure Login Fails
```bash
# Check Azure credentials
az account show

# Re-login
az login

# Select subscription
az account set --subscription {subscription-id}
```

### APIM Not Found
```bash
# Verify APIM exists
az apim show --name {apim-name} --resource-group {rg-name}

# Check provisioning state
az apim show --name {apim-name} --resource-group {rg-name} \
  --query provisioningState
```

### Workflow Fails
1. Check GitHub Actions logs
2. Verify all secrets are set correctly
3. Ensure service principal has proper permissions
4. Validate swagger.yaml syntax

## 📚 Documentation

- **README.md** - Complete project documentation
- **SETUP-GUIDE.md** - Detailed Azure and GitHub setup
- **QUICKSTART.md** - This file - quick reference
- **swagger.yaml** - API specification

## 🎯 Next Steps

1. ✅ API running locally
2. ✅ GitHub Actions configured
3. ✅ First deployment successful
4. 🎯 Add authentication
5. 🎯 Configure rate limiting
6. 🎯 Add monitoring
7. 🎯 Set up multiple environments

## 💡 Tips

- **Local Testing**: Always test locally before deploying
- **Swagger First**: Update swagger.yaml before code
- **Version Control**: Use semantic versioning for API versions
- **Monitoring**: Enable Application Insights in APIM
- **Security**: Never commit secrets to the repository
- **Backup**: Keep previous versions of swagger.yaml

## 🔗 Useful Links

- [Full Documentation](README.md)
- [Setup Guide](SETUP-GUIDE.md)
- [Azure APIM Docs](https://docs.microsoft.com/azure/api-management/)
- [OpenAPI Spec](https://swagger.io/specification/)
- [ASP.NET Core Docs](https://docs.microsoft.com/aspnet/core/)

---

**Need Help?** Check the [SETUP-GUIDE.md](SETUP-GUIDE.md) for detailed troubleshooting steps.
