# Deployment Instructions for Your Azure Resources

This guide provides step-by-step instructions to deploy using your specific Azure resources.

## ✅ Your Azure Resources (Already Created)

- **Subscription**: `d9a1f276-029e-4843-afe6-f5580c5d2519`
- **Resource Group**: `rg-hackathon`
- **Web App**: `sample-api-hackathon-dev-g7hxepb4atexfvb5.canadacentral-01.azurewebsites.net`
- **APIM**: `apim-hackathon-dev`
- **Region**: `Canada Central`

---

## 🔐 Step 1: Configure GitHub Secrets

You need to add the following secrets to your GitHub repository for automated deployment to work.

### How to Add Secrets:
1. Go to your GitHub repository: `https://github.com/ravitejapanjala8/hackathon`
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret below

### Required Secrets:

#### 1. AZURE_CREDENTIALS
Create a service principal first (if you haven't already):

```bash
az ad sp create-for-rbac \
  --name "github-hackathon-deploy" \
  --role contributor \
  --scopes /subscriptions/d9a1f276-029e-4843-afe6-f5580c5d2519/resourceGroups/rg-hackathon \
  --sdk-auth
```

This will output JSON. Copy the **entire JSON output** and add it as the `AZURE_CREDENTIALS` secret.

Example format:
```json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "d9a1f276-029e-4843-afe6-f5580c5d2519",
  "tenantId": "cd1ccae1-8ae4-44bd-8872-50d073143c26",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

#### 2. Other Required Secrets:

| Secret Name | Value |
|-------------|-------|
| `AZURE_SUBSCRIPTION_ID` | `d9a1f276-029e-4843-afe6-f5580c5d2519` |
| `AZURE_WEBAPP_NAME` | `sample-api-hackathon-dev-g7hxepb4atexfvb5` |
| `AZURE_RESOURCE_GROUP` | `rg-hackathon` |
| `APIM_SERVICE_NAME` | `apim-hackathon-dev` |
| `APIM_RESOURCE_GROUP` | `rg-hackathon` |

#### 3. Optional Secrets (will use defaults if not provided):

| Secret Name | Default Value | Description |
|-------------|---------------|-------------|
| `API_ID` | `sample-api` | API identifier in APIM |
| `API_PATH` | `sample-api` | API path in APIM gateway |

---

## 🚀 Step 2: Deploy to Azure Web App

### Option A: Automatic Deployment (Recommended)

Once secrets are configured, simply push code to trigger deployment:

```bash
# Make sure you're on the right branch
git checkout copilot/build-sample-api-onboard-apim

# Push to trigger deployment
git push origin copilot/build-sample-api-onboard-apim
```

The GitHub Actions workflow will automatically:
1. Build the .NET application
2. Run tests
3. Publish artifacts
4. Deploy to your Web App
5. Test the deployment

### Option B: Manual Deployment Trigger

1. Go to your GitHub repository
2. Click **Actions** tab
3. Select **Deploy API to Azure Web App** workflow
4. Click **Run workflow**
5. Select branch: `copilot/build-sample-api-onboard-apim`
6. Click **Run workflow**

### Monitor Progress:
- Go to **Actions** tab to see the workflow running
- Click on the running workflow to see detailed logs

---

## 🌐 Step 3: Verify Web App Deployment

After the workflow completes successfully, test your Web App:

```bash
# Test health endpoint
curl https://sample-api-hackathon-dev-g7hxepb4atexfvb5.canadacentral-01.azurewebsites.net/api/health

# Test users endpoint
curl https://sample-api-hackathon-dev-g7hxepb4atexfvb5.canadacentral-01.azurewebsites.net/api/users

# Open Swagger UI in browser
# https://sample-api-hackathon-dev-g7hxepb4atexfvb5.canadacentral-01.azurewebsites.net/swagger
```

Expected response from health endpoint:
```json
{
  "status": "healthy",
  "timestamp": "2026-02-04T06:32:00.000Z",
  "service": "Sample API"
}
```

---

## 🔗 Step 4: Deploy to APIM

### Automatic Trigger
The APIM deployment will automatically trigger after the Web App deployment succeeds.

### Manual Trigger (if needed)
1. Go to **Actions** tab
2. Select **Deploy API to Azure APIM** workflow
3. Click **Run workflow**
4. Select branch and click **Run workflow**

### What It Does:
1. Gets the Web App URL automatically
2. Imports OpenAPI specification to APIM
3. Configures APIM to proxy requests to your Web App
4. Tests the APIM endpoint

---

## 🧪 Step 5: Verify APIM Deployment

After APIM deployment completes:

```bash
# Test through APIM gateway
curl https://apim-hackathon-dev.azure-api.net/sample-api/api/health

# Test users endpoint through APIM
curl https://apim-hackathon-dev.azure-api.net/sample-api/api/users
```

### Verify in Azure Portal:
1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to **API Management services** → `apim-hackathon-dev`
3. Click **APIs** in the left menu
4. You should see "Sample API" listed
5. Click on it to see all imported operations
6. Use the **Test** tab to test operations directly

---

## 📊 Architecture After Deployment

```
┌─────────────┐
│   Client    │
│  (Browser)  │
└──────┬──────┘
       │
       ▼
┌──────────────────────────┐
│   Azure APIM Gateway     │
│   apim-hackathon-dev     │
│   (Rate limiting, Auth)  │
└──────┬───────────────────┘
       │
       ▼
┌────────────────────────────────────────┐
│   Azure Web App (Backend)              │
│   sample-api-hackathon-dev-...         │
│   (ASP.NET Core API)                   │
└────────────────────────────────────────┘
```

---

## 🔍 Troubleshooting

### Issue: GitHub Actions fails with authentication error

**Solution**: Verify service principal has permissions:
```bash
# List role assignments
az role assignment list \
  --scope /subscriptions/d9a1f276-029e-4843-afe6-f5580c5d2519/resourceGroups/rg-hackathon \
  --output table

# If needed, recreate service principal with correct permissions
az ad sp create-for-rbac \
  --name "github-hackathon-deploy-new" \
  --role contributor \
  --scopes /subscriptions/d9a1f276-029e-4843-afe6-f5580c5d2519/resourceGroups/rg-hackathon \
  --sdk-auth
```

### Issue: Web App deployment succeeds but app doesn't respond

**Solution**: Check Web App logs:
```bash
# Stream logs
az webapp log tail \
  --name sample-api-hackathon-dev-g7hxepb4atexfvb5 \
  --resource-group rg-hackathon

# Download logs
az webapp log download \
  --name sample-api-hackathon-dev-g7hxepb4atexfvb5 \
  --resource-group rg-hackathon \
  --log-file webapp-logs.zip
```

### Issue: APIM deployment fails

**Solution**: Check APIM status:
```bash
# Check if APIM is still provisioning
az apim show \
  --name apim-hackathon-dev \
  --resource-group rg-hackathon \
  --query provisioningState
```

If status is not "Succeeded", wait for APIM to finish provisioning (can take 30-45 minutes).

### Issue: APIM can't reach Web App

**Solution**: Verify Web App is running and accessible:
```bash
# Check Web App status
az webapp show \
  --name sample-api-hackathon-dev-g7hxepb4atexfvb5 \
  --resource-group rg-hackathon \
  --query state

# Restart if needed
az webapp restart \
  --name sample-api-hackathon-dev-g7hxepb4atexfvb5 \
  --resource-group rg-hackathon
```

---

## ✅ Deployment Checklist

- [ ] Service principal created
- [ ] All GitHub secrets configured
- [ ] Web App deployment workflow triggered
- [ ] Web App deployment successful
- [ ] Web App health endpoint responds
- [ ] APIM deployment workflow triggered
- [ ] APIM deployment successful
- [ ] APIM gateway responds to requests
- [ ] API tested through APIM gateway

---

## 📞 Next Steps

After successful deployment:

1. **Test All Endpoints**: Use the test URLs above
2. **Configure APIM Policies**: Add rate limiting, caching, etc. in Azure Portal
3. **Set Up Monitoring**: Enable Application Insights
4. **Configure Custom Domain** (optional): Add custom domain to APIM
5. **Set Up CI/CD**: Future code changes will auto-deploy

---

## 📚 Additional Resources

- [AZURE-RESOURCES.md](AZURE-RESOURCES.md) - Your Azure resource details
- [API-TESTING.md](API-TESTING.md) - Complete API testing guide
- [URLS.md](URLS.md) - Quick URL reference
- [WEBAPP-APIM-DEPLOYMENT.md](WEBAPP-APIM-DEPLOYMENT.md) - Detailed deployment guide

---

**Need Help?** Check the GitHub Actions logs for detailed error messages, or review the troubleshooting section above.
