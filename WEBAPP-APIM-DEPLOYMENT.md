# Web App + APIM Deployment Guide

This guide walks you through deploying the API to Azure Web App first, then configuring APIM to use it as a backend.

## 📐 Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│                         Deployment Flow                               │
└──────────────────────────────────────────────────────────────────────┘

  GitHub Repository
        │
        │ (1) Code Push
        ▼
  GitHub Actions: Deploy to Web App
        │
        │ (2) Build & Deploy
        ▼
  Azure Web App (Backend API)
  https://{webapp-name}.azurewebsites.net
        │
        │ (3) Auto-trigger APIM deployment
        ▼
  GitHub Actions: Deploy to APIM
        │
        │ (4) Configure APIM with Web App URL
        ▼
  Azure APIM (API Gateway)
  https://{apim-name}.azure-api.net/{api-path}
        │
        │ (5) Client requests
        ▼
  ┌─────────────────────────────────────────────────────────┐
  │  Client → APIM Gateway → Web App Backend → Response   │
  └─────────────────────────────────────────────────────────┘
```

## 🚀 Deployment Steps

### Prerequisites

Before deploying, you need:
1. ✅ Azure subscription
2. ✅ Azure CLI installed (for setup commands)
3. ✅ GitHub repository access
4. ✅ Service principal created
5. ✅ All required secrets configured in GitHub

See [DEPLOYMENT-REQUIREMENTS.md](DEPLOYMENT-REQUIREMENTS.md) for detailed requirements.

---

## Step-by-Step Deployment

### Step 1: Create Azure Resources

#### 1.1 Create Resource Group

```bash
# Set your variables
RESOURCE_GROUP="rg-hackathon-dev"
LOCATION="eastus"

# Create resource group
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION
```

#### 1.2 Create App Service Plan

```bash
APP_SERVICE_PLAN="asp-hackathon-dev"

# Create App Service Plan (Linux with .NET 8.0)
az appservice plan create \
  --name $APP_SERVICE_PLAN \
  --resource-group $RESOURCE_GROUP \
  --sku B1 \
  --is-linux
```

**Pricing Tiers:**
- `F1` - Free (for testing)
- `B1` - Basic ($13/month)
- `S1` - Standard ($69/month)
- `P1V2` - Premium ($73/month)

#### 1.3 Create Web App

```bash
WEBAPP_NAME="sample-api-hackathon-dev"  # Must be globally unique!

# Create Web App
az webapp create \
  --name $WEBAPP_NAME \
  --resource-group $RESOURCE_GROUP \
  --plan $APP_SERVICE_PLAN \
  --runtime "DOTNET|8.0"

# Enable HTTPS only
az webapp update \
  --name $WEBAPP_NAME \
  --resource-group $RESOURCE_GROUP \
  --https-only true

# Get the Web App URL
az webapp show \
  --name $WEBAPP_NAME \
  --resource-group $RESOURCE_GROUP \
  --query defaultHostName \
  --output tsv
```

Your Web App will be available at: `https://{webapp-name}.azurewebsites.net`

#### 1.4 Create APIM Service (takes 30-45 minutes!)

```bash
APIM_NAME="apim-hackathon-dev"  # Must be globally unique!
PUBLISHER_NAME="Your Name or Company"
PUBLISHER_EMAIL="admin@yourcompany.com"

# Create APIM service
az apim create \
  --name $APIM_NAME \
  --resource-group $RESOURCE_GROUP \
  --publisher-name "$PUBLISHER_NAME" \
  --publisher-email "$PUBLISHER_EMAIL" \
  --sku-name Developer \
  --no-wait

# Check provisioning status
az apim show \
  --name $APIM_NAME \
  --resource-group $RESOURCE_GROUP \
  --query provisioningState \
  --output tsv
```

**Note:** APIM provisioning takes 30-45 minutes. You can continue with other steps while it provisions.

#### 1.5 Create Service Principal

```bash
# Get your subscription ID
SUBSCRIPTION_ID=$(az account show --query id --output tsv)

# Create service principal
az ad sp create-for-rbac \
  --name "github-hackathon-deploy" \
  --role contributor \
  --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP \
  --sdk-auth

# SAVE THE OUTPUT JSON! You'll need it for GitHub secrets
```

---

### Step 2: Configure GitHub Secrets

Go to your GitHub repository:
1. Click **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add each of these secrets:

| Secret Name | Value | Where to Get |
|-------------|-------|--------------|
| `AZURE_CREDENTIALS` | Service principal JSON | Output from service principal creation |
| `AZURE_SUBSCRIPTION_ID` | Your subscription ID | `az account show --query id -o tsv` |
| `AZURE_WEBAPP_NAME` | Web App name | The name you chose (e.g., `sample-api-hackathon-dev`) |
| `AZURE_RESOURCE_GROUP` | Resource group name | The name you chose (e.g., `rg-hackathon-dev`) |
| `APIM_SERVICE_NAME` | APIM service name | The name you chose (e.g., `apim-hackathon-dev`) |
| `APIM_RESOURCE_GROUP` | APIM resource group | Usually same as `AZURE_RESOURCE_GROUP` |
| `API_ID` | API identifier | Optional, defaults to `sample-api` |
| `API_PATH` | API path in APIM | Optional, defaults to `sample-api` |

---

### Step 3: Deploy to Web App

#### Option A: Automatic Deployment (Recommended)

Simply push code changes to the `main` or `master` branch:

```bash
git add .
git commit -m "Deploy API to Web App"
git push origin main
```

The GitHub Actions workflow will automatically:
1. Build the .NET application
2. Run tests
3. Publish the application
4. Deploy to Azure Web App
5. Test the deployed endpoints

#### Option B: Manual Trigger

1. Go to **Actions** tab in GitHub
2. Select **Deploy API to Azure Web App**
3. Click **Run workflow**
4. Select branch and environment
5. Click **Run workflow**

#### Verify Web App Deployment

After deployment completes:

```bash
# Get your Web App URL
WEBAPP_URL=$(az webapp show \
  --name $WEBAPP_NAME \
  --resource-group $RESOURCE_GROUP \
  --query defaultHostName \
  --output tsv)

# Test the health endpoint
curl https://$WEBAPP_URL/api/health

# Test the users endpoint
curl https://$WEBAPP_URL/api/users

# Open Swagger UI in browser
echo "Swagger UI: https://$WEBAPP_URL/swagger"
```

Expected response from health endpoint:
```json
{
  "status": "healthy",
  "timestamp": "2026-02-04T05:40:00.000Z",
  "service": "Sample API"
}
```

---

### Step 4: Deploy to APIM

#### Wait for APIM to Finish Provisioning

Check if APIM is ready:

```bash
az apim show \
  --name $APIM_NAME \
  --resource-group $RESOURCE_GROUP \
  --query provisioningState \
  --output tsv
```

Output should be: `Succeeded`

#### Deploy to APIM

The APIM deployment will automatically trigger after Web App deployment succeeds, OR you can trigger it manually:

**Manual Trigger:**
1. Go to **Actions** tab in GitHub
2. Select **Deploy API to Azure APIM**
3. Click **Run workflow**
4. Click **Run workflow**

The workflow will:
1. Get the Web App URL automatically
2. Import the OpenAPI specification to APIM
3. Configure APIM to use Web App as backend
4. Test the APIM endpoint

#### Verify APIM Deployment

```bash
# Get your APIM gateway URL
APIM_URL=$(az apim show \
  --name $APIM_NAME \
  --resource-group $RESOURCE_GROUP \
  --query gatewayUrl \
  --output tsv)

# Test through APIM
curl $APIM_URL/sample-api/api/health
curl $APIM_URL/sample-api/api/users
```

---

## 📊 Deployment Verification

### Check Both Endpoints

```bash
# Direct Web App access
curl https://{webapp-name}.azurewebsites.net/api/health

# Through APIM (recommended)
curl https://{apim-name}.azure-api.net/sample-api/api/health
```

Both should return the same response!

### View in Azure Portal

1. **Web App**:
   - Go to Azure Portal → App Services
   - Click your Web App
   - Check "Deployment Center" for deployment history
   - Check "Log stream" for real-time logs

2. **APIM**:
   - Go to Azure Portal → API Management services
   - Click your APIM service
   - Go to "APIs" → "Sample API"
   - Click "Test" to test operations
   - View "Analytics" for usage metrics

---

## 🔄 Deployment Workflow

### What Happens When You Push Code

1. **Trigger**: Push to main/master branch
   
2. **Workflow 1: Deploy to Web App** (3-5 minutes)
   - ✓ Checkout code
   - ✓ Setup .NET 8.0
   - ✓ Restore dependencies
   - ✓ Build application
   - ✓ Run tests
   - ✓ Publish artifacts
   - ✓ Deploy to Azure Web App
   - ✓ Test health endpoint

3. **Workflow 2: Deploy to APIM** (1-2 minutes)
   - ✓ Get Web App URL
   - ✓ Import OpenAPI specification
   - ✓ Configure backend to Web App
   - ✓ Test APIM endpoint

4. **Result**: API available through APIM!

---

## 🎯 URLs Summary

After successful deployment:

| Service | URL | Purpose |
|---------|-----|---------|
| Web App | `https://{webapp}.azurewebsites.net` | Backend API (direct access) |
| Web App Swagger | `https://{webapp}.azurewebsites.net/swagger` | API documentation |
| APIM Gateway | `https://{apim}.azure-api.net/sample-api` | API Gateway (public access) |
| APIM Developer Portal | `https://{apim}.developer.azure-api.net` | Developer portal |

**Recommended**: Use APIM Gateway URL for all client access.

---

## 🔍 Troubleshooting

### Web App Deployment Issues

**Issue**: Deployment fails with authentication error
```bash
# Solution: Verify service principal permissions
az role assignment list --assignee {service-principal-id} --output table
```

**Issue**: Web App not responding
```bash
# Check Web App logs
az webapp log tail --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP

# Restart Web App
az webapp restart --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP
```

**Issue**: Build fails
- Check .NET version matches (8.0)
- Verify all NuGet packages restore correctly
- Check for compilation errors in GitHub Actions logs

### APIM Deployment Issues

**Issue**: APIM not found
```bash
# Check APIM provisioning status
az apim show --name $APIM_NAME --resource-group $RESOURCE_GROUP --query provisioningState
```

**Issue**: APIM can't reach Web App
- Verify Web App is running
- Check APIM backend configuration
- Test Web App URL directly first

**Issue**: 404 on APIM endpoint
- Verify API path is correct (`sample-api`)
- Check API was imported successfully in Azure Portal
- Review APIM API settings

### Common Secrets Issues

**Missing Secrets**: Verify all required secrets are configured
```bash
# Required secrets checklist:
# - AZURE_CREDENTIALS
# - AZURE_SUBSCRIPTION_ID
# - AZURE_WEBAPP_NAME
# - AZURE_RESOURCE_GROUP
# - APIM_SERVICE_NAME
```

---

## 🔐 Security Best Practices

### Web App Security

1. **Enable HTTPS Only** (done in setup)
2. **Configure CORS** for production origins
3. **Enable Application Insights** for monitoring
4. **Set up Authentication** if needed

```bash
# Enable Application Insights
az webapp config appsettings set \
  --name $WEBAPP_NAME \
  --resource-group $RESOURCE_GROUP \
  --settings APPINSIGHTS_INSTRUMENTATIONKEY={key}
```

### APIM Security

1. **Enable Subscription Keys** for APIs
2. **Configure Rate Limiting** policies
3. **Set up OAuth/JWT validation** if needed
4. **Enable CORS** for web clients

---

## 📈 Monitoring

### Application Insights

Enable for both Web App and APIM:

```bash
# Create Application Insights
az monitor app-insights component create \
  --app insights-hackathon-dev \
  --location $LOCATION \
  --resource-group $RESOURCE_GROUP \
  --application-type web

# Get instrumentation key
AI_KEY=$(az monitor app-insights component show \
  --app insights-hackathon-dev \
  --resource-group $RESOURCE_GROUP \
  --query instrumentationKey \
  --output tsv)

# Configure Web App
az webapp config appsettings set \
  --name $WEBAPP_NAME \
  --resource-group $RESOURCE_GROUP \
  --settings APPLICATIONINSIGHTS_CONNECTION_STRING="InstrumentationKey=$AI_KEY"
```

### View Metrics

- **Web App**: Azure Portal → App Services → Metrics
- **APIM**: Azure Portal → API Management → Analytics
- **Application Insights**: Azure Portal → Application Insights → Dashboards

---

## 🎨 Next Steps

After successful deployment:

1. ✅ Test all API endpoints through APIM
2. ✅ Configure APIM policies (rate limiting, caching)
3. ✅ Set up custom domain for APIM
4. ✅ Enable Application Insights
5. ✅ Configure authentication
6. ✅ Set up multiple environments (dev, staging, prod)

---

## 💰 Cost Monitoring

Monitor your Azure costs:

```bash
# View cost analysis
az consumption usage list --output table

# Set budget alerts in Azure Portal
# Billing → Cost Management → Budgets
```

Estimated monthly costs:
- Web App (B1): $13
- APIM (Developer): $50
- **Total: ~$63/month**

---

## 📞 Support

If you encounter issues:

1. Check GitHub Actions logs
2. Review Azure Portal logs
3. Consult [DEPLOYMENT-REQUIREMENTS.md](DEPLOYMENT-REQUIREMENTS.md)
4. Check [SETUP-GUIDE.md](SETUP-GUIDE.md)

---

**Congratulations!** 🎉 Your API is now deployed to Azure Web App and accessible through APIM!
