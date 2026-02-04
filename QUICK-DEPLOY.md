# ⚡ Quick Deployment Reference

## Your Azure Resources
- **Web App**: `sample-api-hackathon-dev-g7hxepb4atexfvb5`
- **APIM**: `apim-hackathon-dev`
- **Resource Group**: `rg-hackathon`
- **Subscription**: `d9a1f276-029e-4843-afe6-f5580c5d2519`

## 🔐 GitHub Secrets Required

Add at: https://github.com/ravitejapanjala8/hackathon/settings/secrets/actions

| Secret Name | Value |
|-------------|-------|
| `AZURE_CREDENTIALS` | _(Create service principal - see command below)_ |
| `AZURE_SUBSCRIPTION_ID` | `d9a1f276-029e-4843-afe6-f5580c5d2519` |
| `AZURE_WEBAPP_NAME` | `sample-api-hackathon-dev-g7hxepb4atexfvb5` |
| `AZURE_RESOURCE_GROUP` | `rg-hackathon` |
| `APIM_SERVICE_NAME` | `apim-hackathon-dev` |
| `APIM_RESOURCE_GROUP` | `rg-hackathon` |

### Create Service Principal:
```bash
az ad sp create-for-rbac \
  --name "github-hackathon-deploy" \
  --role contributor \
  --scopes /subscriptions/d9a1f276-029e-4843-afe6-f5580c5d2519/resourceGroups/rg-hackathon \
  --sdk-auth
```
Copy the entire JSON output → add as `AZURE_CREDENTIALS` secret

## 🚀 Deploy

### Option 1: Push Code (Automatic)
```bash
git push origin copilot/build-sample-api-onboard-apim
```

### Option 2: Manual Trigger
1. Go to: https://github.com/ravitejapanjala8/hackathon/actions
2. Click "Deploy API to Azure Web App"
3. Click "Run workflow"

## 📍 Your URLs (After Deployment)

### Web App Direct:
```
https://sample-api-hackathon-dev-g7hxepb4atexfvb5.canadacentral-01.azurewebsites.net/api/health
https://sample-api-hackathon-dev-g7hxepb4atexfvb5.canadacentral-01.azurewebsites.net/swagger
```

### Through APIM (Recommended):
```
https://apim-hackathon-dev.azure-api.net/sample-api/api/health
https://apim-hackathon-dev.azure-api.net/sample-api/api/users
```

## ✅ Verify

```bash
# Test Web App
curl https://sample-api-hackathon-dev-g7hxepb4atexfvb5.canadacentral-01.azurewebsites.net/api/health

# Test APIM
curl https://apim-hackathon-dev.azure-api.net/sample-api/api/health
```

## 📚 Full Documentation
- **DEPLOYMENT-GUIDE-CURRENT.md** - Complete deployment instructions
- **AZURE-RESOURCES.md** - Your Azure resource details
- **API-TESTING.md** - How to test the API

---

**Status**: ✅ Ready to deploy (after GitHub Secrets are configured)
