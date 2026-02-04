# Azure Resource Configuration

This file contains the actual Azure resource details for deployment.

## Azure Subscription & Tenant
- **Subscription ID**: `d9a1f276-029e-4843-afe6-f5580c5d2519`
- **Tenant ID**: `cd1ccae1-8ae4-44bd-8872-50d073143c26`

## Resource Group
- **Name**: `rg-hackathon`
- **Region**: `Canada Central`

## Azure Web App (Backend API)
- **Name**: `sample-api-hackathon-dev-g7hxepb4atexfvb5`
- **Full URL**: `https://sample-api-hackathon-dev-g7hxepb4atexfvb5.canadacentral-01.azurewebsites.net`
- **Runtime**: `.NET 8.0`
- **Region**: `Canada Central`

## Azure API Management (APIM)
- **Service Name**: `apim-hackathon-dev`
- **Gateway URL**: `https://apim-hackathon-dev.azure-api.net`
- **Region**: `Canada Central`
- **Default API Path**: `sample-api`

## GitHub Secrets Required

To deploy using GitHub Actions, configure these secrets in your repository:

### Required Secrets
```yaml
AZURE_CREDENTIALS: |
  {
    "clientId": "<service-principal-client-id>",
    "clientSecret": "<service-principal-secret>",
    "subscriptionId": "d9a1f276-029e-4843-afe6-f5580c5d2519",
    "tenantId": "cd1ccae1-8ae4-44bd-8872-50d073143c26"
  }

AZURE_SUBSCRIPTION_ID: "d9a1f276-029e-4843-afe6-f5580c5d2519"
AZURE_WEBAPP_NAME: "sample-api-hackathon-dev-g7hxepb4atexfvb5"
AZURE_RESOURCE_GROUP: "rg-hackathon"
APIM_SERVICE_NAME: "apim-hackathon-dev"
APIM_RESOURCE_GROUP: "rg-hackathon"
```

### Optional Secrets (with defaults)
```yaml
API_ID: "sample-api"        # Default: sample-api
API_PATH: "sample-api"      # Default: sample-api
```

## Deployment URLs

After deployment, your API will be accessible at:

### Direct Web App Access
- Health Check: `https://sample-api-hackathon-dev-g7hxepb4atexfvb5.canadacentral-01.azurewebsites.net/api/health`
- Users API: `https://sample-api-hackathon-dev-g7hxepb4atexfvb5.canadacentral-01.azurewebsites.net/api/users`
- Swagger UI: `https://sample-api-hackathon-dev-g7hxepb4atexfvb5.canadacentral-01.azurewebsites.net/swagger`

### Through APIM Gateway (Recommended)
- Health Check: `https://apim-hackathon-dev.azure-api.net/sample-api/api/health`
- Users API: `https://apim-hackathon-dev.azure-api.net/sample-api/api/users`

## Service Principal Setup

If you haven't created a service principal yet, run this command:

```bash
az ad sp create-for-rbac \
  --name "github-hackathon-deploy" \
  --role contributor \
  --scopes /subscriptions/d9a1f276-029e-4843-afe6-f5580c5d2519/resourceGroups/rg-hackathon \
  --sdk-auth
```

Save the JSON output and add it as the `AZURE_CREDENTIALS` secret in GitHub.

## Verification Commands

### Check Web App Status
```bash
az webapp show \
  --name sample-api-hackathon-dev-g7hxepb4atexfvb5 \
  --resource-group rg-hackathon \
  --query "{name:name,state:state,hostNames:defaultHostName}" \
  --output table
```

### Check APIM Status
```bash
az apim show \
  --name apim-hackathon-dev \
  --resource-group rg-hackathon \
  --query "{name:name,gatewayUrl:gatewayUrl,provisioningState:provisioningState}" \
  --output table
```

### Test Endpoints
```bash
# Test Web App directly
curl https://sample-api-hackathon-dev-g7hxepb4atexfvb5.canadacentral-01.azurewebsites.net/api/health

# Test through APIM
curl https://apim-hackathon-dev.azure-api.net/sample-api/api/health
```

## Deployment Steps

1. **Ensure GitHub Secrets are configured** (see above)
2. **Trigger Web App Deployment**: Push code or manually trigger "Deploy API to Azure Web App" workflow
3. **APIM Deployment**: Will auto-trigger after Web App deployment succeeds, or trigger manually
4. **Verify**: Test both Web App and APIM URLs

## Architecture

```
Client Request
     ↓
Azure APIM Gateway
(apim-hackathon-dev.azure-api.net)
     ↓
Azure Web App Backend
(sample-api-hackathon-dev-g7hxepb4atexfvb5.canadacentral-01.azurewebsites.net)
     ↓
ASP.NET Core API Response
```
