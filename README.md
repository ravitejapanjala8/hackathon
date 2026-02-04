# Azure APIM Hackathon - Sample API

This repository contains a **C# ASP.NET Core Web API** that deploys to **Azure Web App** and automatically onboards to **Azure API Management (APIM)** using GitHub Actions.

## 🏗️ Architecture

```
Client → Azure APIM (Gateway) → Azure Web App (Backend API)
```

The API is deployed in two stages:
1. **Deploy to Azure Web App** - Backend service hosting the API
2. **Deploy to APIM** - API Gateway that proxies requests to the Web App

## 🌐 Testing URLs

**Want to test the API?** See [URLS.md](URLS.md) for a quick reference or [API-TESTING.md](API-TESTING.md) for the complete testing guide.

- **Local**: `http://localhost:5000/api/health`
- **Web App**: `https://{your-webapp}.azurewebsites.net/api/health`
- **APIM**: `https://{your-apim-service}.azure-api.net/sample-api/api/health`
- **Swagger UI**: `http://localhost:5000/swagger` (when running locally)

## 📋 Deployment Requirements

**Ready to deploy?** You'll need:
- Azure subscription with Web App and APIM services
- GitHub repository secrets configured
- Service principal with appropriate permissions

See [DEPLOYMENT-REQUIREMENTS.md](DEPLOYMENT-REQUIREMENTS.md) for complete list of required information and [WEBAPP-APIM-DEPLOYMENT.md](WEBAPP-APIM-DEPLOYMENT.md) for step-by-step deployment guide.

## 🚀 Features

- **Sample REST API** built with ASP.NET Core 8.0
- **OpenAPI/Swagger specification** for API documentation
- **Automated deployment** to Azure APIM using GitHub Actions
- **PowerShell script** for APIM deployment using Azure CLI
- Supports **CI/CD pipeline** triggered on Swagger file commits

## 📋 Prerequisites

Before you begin, ensure you have:

1. **Azure Subscription** with an APIM service created
2. **GitHub Repository** with proper access
3. **Azure Service Principal** with permissions to deploy to APIM
4. **.NET 8.0 SDK** (for local development)

## 🏗️ Project Structure

```
hackathon/
├── Controllers/              # API controllers
│   ├── HealthController.cs  # Health check endpoint
│   └── UsersController.cs   # User management endpoints
├── Models/                   # Data models
│   └── Models.cs            # User, HealthResponse, etc.
├── Properties/               # Project properties
│   └── launchSettings.json  # Development launch settings
├── .github/
│   └── workflows/
│       └── deploy-apim.yml  # GitHub Actions workflow
├── swagger.yaml             # OpenAPI specification
├── deploy-to-apim.ps1       # PowerShell deployment script
├── Program.cs               # Application entry point
└── SampleApi.csproj         # Project file
```

## 🔧 Local Development

### Run the API locally

```bash
# Restore dependencies
dotnet restore

# Build the project
dotnet build

# Run the application
dotnet run
```

The API will be available at:
- HTTP: `http://localhost:5000`
- HTTPS: `https://localhost:5001`
- Swagger UI: `http://localhost:5000/swagger`

### Test the API endpoints

```bash
# Health check
curl http://localhost:5000/api/health

# Get all users
curl http://localhost:5000/api/users

# Get user by ID
curl http://localhost:5000/api/users/1

# Create a new user
curl -X POST http://localhost:5000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Alice Smith","email":"alice@example.com"}'

# Update a user
curl -X PUT http://localhost:5000/api/users/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"John Updated","email":"john.updated@example.com"}'

# Delete a user
curl -X DELETE http://localhost:5000/api/users/1
```

## 🔐 Setup Azure Credentials

### 1. Create Azure Service Principal

```bash
az ad sp create-for-rbac --name "github-apim-deploy" --role contributor \
    --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group-name} \
    --sdk-auth
```

This will output JSON credentials. Save this output.

### 2. Configure GitHub Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions, and add these secrets:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `AZURE_CREDENTIALS` | JSON output from service principal creation | `{"clientId":"...","clientSecret":"..."}` |
| `APIM_RESOURCE_GROUP` | Azure resource group name | `my-apim-rg` |
| `APIM_SERVICE_NAME` | APIM service name | `my-apim-service` |
| `API_ID` | Unique API identifier in APIM | `sample-api` |
| `API_PATH` | API path in APIM gateway | `sample-api` |
| `SERVICE_URL` | Backend service URL | `https://api.example.com` |

## 🚀 Automated Deployment

### How it works

1. **Developer commits** the `swagger.yaml` file to the repository
2. **GitHub Actions workflow** is triggered automatically
3. **Workflow validates** the Swagger file
4. **Azure Login** using service principal credentials
5. **PowerShell script** deploys the API to APIM using Azure CLI
6. **API is available** at the APIM gateway URL

### Trigger Deployment

The GitHub Actions workflow automatically triggers when:

- You push changes to `swagger.yaml` on `main` or `master` branch
- You push changes to `.github/workflows/deploy-apim.yml`
- You manually trigger the workflow (workflow_dispatch)

### Manual Deployment

You can also deploy manually using the PowerShell script:

```powershell
# Ensure you're logged in to Azure
az login

# Run the deployment script
./deploy-to-apim.ps1 `
    -ResourceGroupName "my-apim-rg" `
    -ApimServiceName "my-apim-service" `
    -ApiId "sample-api" `
    -SwaggerFilePath "swagger.yaml" `
    -ApiPath "sample-api" `
    -ServiceUrl "https://api.example.com"
```

## 📝 API Endpoints

Once deployed to APIM, your API will be available at:

```
https://{apim-service-name}.azure-api.net/{api-path}/
```

### Available Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/health` | Health check endpoint |
| GET | `/api/users` | Get all users |
| GET | `/api/users/{id}` | Get user by ID |
| POST | `/api/users` | Create a new user |
| PUT | `/api/users/{id}` | Update existing user |
| DELETE | `/api/users/{id}` | Delete a user |

## 🧪 Testing APIM Deployment

After deployment, test your APIM endpoints:

```bash
# Replace {apim-service} and {api-path} with your values
APIM_URL="https://{apim-service}.azure-api.net/{api-path}"

# Test health endpoint
curl $APIM_URL/api/health

# Test users endpoint
curl $APIM_URL/api/users
```

## 🔄 Updating the API

To update the API in APIM:

1. Modify the `swagger.yaml` file with your changes
2. Commit and push to the `main` or `master` branch
3. GitHub Actions will automatically deploy the updated API

## 📚 Additional Resources

- [Azure API Management Documentation](https://docs.microsoft.com/azure/api-management/)
- [Azure CLI Reference](https://docs.microsoft.com/cli/azure/)
- [OpenAPI Specification](https://swagger.io/specification/)
- [ASP.NET Core Web API](https://docs.microsoft.com/aspnet/core/web-api/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is licensed under the ISC License.

## 🐛 Troubleshooting

### Common Issues

**Issue: Azure login fails in GitHub Actions**
- Verify `AZURE_CREDENTIALS` secret is correctly formatted
- Ensure service principal has proper permissions

**Issue: APIM service not found**
- Verify `APIM_SERVICE_NAME` and `APIM_RESOURCE_GROUP` are correct
- Ensure the APIM service exists in Azure

**Issue: API import fails**
- Validate your `swagger.yaml` file is valid OpenAPI 3.0
- Check that the service principal has "API Management Service Contributor" role

**Issue: Build fails locally**
- Ensure .NET 8.0 SDK is installed: `dotnet --version`
- Run `dotnet restore` to restore dependencies

For more help, check the GitHub Actions logs or Azure APIM documentation.
