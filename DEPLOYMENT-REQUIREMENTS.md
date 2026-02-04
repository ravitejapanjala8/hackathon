# Required Details for Deployment

This document lists all the information needed for deploying the API to Azure Web App and then onboarding to APIM.

## Architecture Overview

```
┌─────────────┐      ┌──────────────────┐      ┌─────────────────────┐
│   Client    │ ───> │  Azure APIM      │ ───> │  Azure Web App      │
│  (Browser)  │      │  (API Gateway)   │      │  (Backend API)      │
└─────────────┘      └──────────────────┘      └─────────────────────┘
```

**Deployment Sequence:**
1. Deploy C# API to Azure Web App (backend service)
2. Configure APIM to use Web App URL as backend service
3. Test through APIM gateway URL

---

## 📋 Required Information

### 1. Azure Subscription Information

- [ ] **Azure Subscription ID**
  - Where to find: Azure Portal → Subscriptions
  - Example: `12345678-1234-1234-1234-123456789abc`
  - Used for: All Azure resource deployments

- [ ] **Tenant ID**
  - Where to find: Azure Portal → Azure Active Directory → Overview
  - Example: `87654321-4321-4321-4321-987654321cba`
  - Used for: Authentication

### 2. Azure Resource Group

- [ ] **Resource Group Name**
  - Create one or use existing
  - Example: `rg-hackathon-dev`
  - Location: (e.g., `East US`, `West Europe`)
  - Used for: Organizing all resources

### 3. Azure Web App Details

- [ ] **Web App Name** (Must be globally unique)
  - Pattern: `{your-app-name}`
  - Example: `sample-api-hackathon-dev`
  - Full URL will be: `https://{your-app-name}.azurewebsites.net`
  - Rules:
    - Must be unique across all Azure
    - 2-60 characters
    - Alphanumeric and hyphens only
    - Cannot start or end with hyphen

- [ ] **App Service Plan Name**
  - Example: `asp-hackathon-dev`
  - SKU/Pricing Tier: (Recommend `B1` for dev, `P1V2` or higher for production)
    - `F1` - Free (limited, good for testing)
    - `B1` - Basic ($13/month, good for dev)
    - `S1` - Standard ($69/month, for staging)
    - `P1V2` - Premium ($73/month, for production)

### 4. Azure API Management (APIM) Details

- [ ] **APIM Service Name** (Must be globally unique)
  - Example: `apim-hackathon-dev`
  - Full gateway URL: `https://{apim-service-name}.azure-api.net`
  - Rules:
    - Must be unique across all Azure
    - Alphanumeric and hyphens only

- [ ] **APIM SKU/Tier**
  - `Developer` - $50/month (recommended for dev/test, has all features)
  - `Basic` - $140/month
  - `Standard` - $678/month
  - `Premium` - $2,740/month
  
  Note: APIM provisioning takes 30-45 minutes

- [ ] **API Path in APIM**
  - Example: `sample-api` or `v1/users`
  - Default: `sample-api`
  - This will be part of the URL: `https://{apim}.azure-api.net/{api-path}`

### 5. Service Principal (for GitHub Actions)

You'll need to create a Service Principal with contributor access:

```bash
az ad sp create-for-rbac \
  --name "github-hackathon-deploy" \
  --role contributor \
  --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group-name} \
  --sdk-auth
```

This will output JSON that you'll use for GitHub secrets.

### 6. GitHub Repository Secrets

You'll need to configure these secrets in your GitHub repository:

#### Required Secrets:

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `AZURE_CREDENTIALS` | Service principal JSON output | `{"clientId":"...","clientSecret":"..."}` |
| `AZURE_SUBSCRIPTION_ID` | Your Azure subscription ID | `12345678-...` |
| `AZURE_WEBAPP_NAME` | Web App name (globally unique) | `sample-api-hackathon-dev` |
| `AZURE_RESOURCE_GROUP` | Resource group name | `rg-hackathon-dev` |
| `APIM_SERVICE_NAME` | APIM service name | `apim-hackathon-dev` |
| `APIM_RESOURCE_GROUP` | APIM resource group (can be same as above) | `rg-hackathon-dev` |

#### Optional Secrets (with defaults):

| Secret Name | Description | Default Value |
|-------------|-------------|---------------|
| `API_ID` | API identifier in APIM | `sample-api` |
| `API_PATH` | API path in APIM | `sample-api` |

---

## 🚀 Quick Setup Commands

### Step 1: Create Resource Group (if new)

```bash
az group create \
  --name rg-hackathon-dev \
  --location eastus
```

### Step 2: Create App Service Plan

```bash
az appservice plan create \
  --name asp-hackathon-dev \
  --resource-group rg-hackathon-dev \
  --sku B1 \
  --is-linux
```

### Step 3: Create Web App

```bash
az webapp create \
  --name sample-api-hackathon-dev \
  --resource-group rg-hackathon-dev \
  --plan asp-hackathon-dev \
  --runtime "DOTNET|8.0"
```

### Step 4: Create APIM Service (30-45 min to provision)

```bash
az apim create \
  --name apim-hackathon-dev \
  --resource-group rg-hackathon-dev \
  --publisher-name "Your Name or Company" \
  --publisher-email "admin@yourcompany.com" \
  --sku-name Developer
```

### Step 5: Create Service Principal

```bash
az ad sp create-for-rbac \
  --name "github-hackathon-deploy" \
  --role contributor \
  --scopes /subscriptions/{subscription-id}/resourceGroups/rg-hackathon-dev \
  --sdk-auth
```

**Save the JSON output!** You'll need it for GitHub secrets.

### Step 6: Configure GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret from the table above

---

## 📊 Cost Estimate (Monthly)

### Development Environment
- App Service Plan (B1): ~$13/month
- APIM (Developer): ~$50/month
- **Total: ~$63/month**

### Production Environment
- App Service Plan (P1V2): ~$73/month
- APIM (Standard): ~$678/month
- **Total: ~$751/month**

Note: Can use F1 (Free) tier for App Service during testing, but has limitations.

---

## 🔐 Security Notes

1. **Service Principal Permissions**: Grant minimum required permissions
2. **Keep Secrets Secure**: Never commit secrets to the repository
3. **APIM Subscriptions**: Enable subscription keys for production
4. **HTTPS Only**: Web App and APIM both support HTTPS by default
5. **CORS**: Configure allowed origins in production

---

## ✅ Pre-Deployment Checklist

Before running the deployment:

- [ ] Azure subscription is active
- [ ] Resource group created
- [ ] Web App name decided (check availability)
- [ ] APIM service name decided (check availability)
- [ ] Service principal created with correct permissions
- [ ] All GitHub secrets configured
- [ ] APIM service has finished provisioning (if pre-created)

---

## 🎯 What Happens During Deployment

### Workflow 1: Deploy to Web App
1. Checkout code from repository
2. Build the .NET application
3. Run tests (if any)
4. Publish build artifacts
5. Deploy to Azure Web App
6. Web App URL: `https://{webapp-name}.azurewebsites.net`

### Workflow 2: Update APIM
1. Use Web App URL as backend service
2. Import OpenAPI specification to APIM
3. Configure API in APIM to proxy to Web App
4. APIM URL: `https://{apim-name}.azure-api.net/{api-path}`

### Result
- Clients access: `https://{apim}.azure-api.net/sample-api/api/users`
- APIM forwards to: `https://{webapp}.azurewebsites.net/api/users`
- API runs on: Azure Web App

---

## 🔍 How to Find Resource Names

### Check if a Web App name is available:
```bash
az webapp list --query "[?name=='sample-api-hackathon-dev'].name" --output tsv
```

### Check if an APIM name is available:
```bash
az apim check-name --name apim-hackathon-dev
```

### List your subscriptions:
```bash
az account list --output table
```

### Get your current subscription:
```bash
az account show --query "{SubscriptionId:id, TenantId:tenantId}" --output json
```

---

## 📞 Need Help?

**Common Issues:**

1. **Name already taken**: Try a different name with your initials or a unique suffix
2. **Insufficient permissions**: Ensure service principal has Contributor role
3. **APIM still provisioning**: Wait until status shows "Succeeded"
4. **Quota limits**: Check your subscription limits in Azure Portal

**Next Steps:**
Once you provide the required information, the deployment workflows will be configured and you can deploy with a single GitHub Actions trigger.

---

## 📝 Template Values

Fill in these values and share them:

```yaml
Subscription ID: _________________________________
Tenant ID: _______________________________________
Resource Group: __________________________________
Web App Name: ____________________________________
APIM Service Name: _______________________________
App Service Plan SKU: ____________________________
APIM SKU: ________________________________________
Location/Region: _________________________________
```

Once you provide these details, I'll configure the workflows with the appropriate values.
