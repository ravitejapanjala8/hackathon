# Azure APIM Setup Guide

This guide walks you through setting up Azure API Management and configuring the GitHub Actions workflow for automated deployments.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Azure Setup](#azure-setup)
3. [GitHub Setup](#github-setup)
4. [Testing the Deployment](#testing-the-deployment)
5. [Troubleshooting](#troubleshooting)

## Prerequisites

- Azure subscription
- Azure CLI installed locally (optional for manual deployment)
- GitHub repository access
- Basic knowledge of PowerShell

## Azure Setup

### Step 1: Create Azure Resources

#### 1.1 Create Resource Group

```bash
az group create \
  --name my-apim-rg \
  --location eastus
```

#### 1.2 Create API Management Service

```bash
# Note: This can take 30-45 minutes to provision
az apim create \
  --name my-apim-service \
  --resource-group my-apim-rg \
  --publisher-name "Your Company" \
  --publisher-email "admin@yourcompany.com" \
  --sku-name Developer
```

**Available SKU tiers:**
- `Developer` - For development/testing (cheapest)
- `Basic` - Basic production workload
- `Standard` - Standard production workload
- `Premium` - Enterprise-grade with high availability

### Step 2: Create Service Principal

Create a service principal that GitHub Actions will use to authenticate with Azure:

```bash
az ad sp create-for-rbac \
  --name "github-apim-deploy" \
  --role contributor \
  --scopes /subscriptions/{subscription-id}/resourceGroups/my-apim-rg \
  --sdk-auth
```

**Important:** Save the JSON output! You'll need it for GitHub secrets.

Example output:
```json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

### Step 3: Assign Permissions

Ensure the service principal has the "API Management Service Contributor" role:

```bash
az role assignment create \
  --assignee {clientId-from-above} \
  --role "API Management Service Contributor" \
  --scope /subscriptions/{subscription-id}/resourceGroups/my-apim-rg/providers/Microsoft.ApiManagement/service/my-apim-service
```

## GitHub Setup

### Step 1: Configure Repository Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** and add each of the following:

#### Required Secrets

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `AZURE_CREDENTIALS` | Service principal JSON | Copy the entire JSON output from service principal creation |
| `APIM_RESOURCE_GROUP` | Resource group name | Use the name you created (e.g., `my-apim-rg`) |
| `APIM_SERVICE_NAME` | APIM service name | Use the name you created (e.g., `my-apim-service`) |

#### Optional Secrets (with defaults)

| Secret Name | Description | Default Value |
|-------------|-------------|---------------|
| `API_ID` | API identifier in APIM | `sample-api` |
| `API_PATH` | API path in gateway | `sample-api` |
| `SERVICE_URL` | Backend service URL | `https://api.example.com` |

### Step 2: Verify Workflow File

The workflow file is already created at `.github/workflows/deploy-apim.yml`. It will:

1. Trigger on commits to `swagger.yaml`
2. Validate the Swagger file
3. Login to Azure using the service principal
4. Deploy the API to APIM using the PowerShell script

## Testing the Deployment

### Option 1: Trigger Automatic Deployment

Make a change to `swagger.yaml` and commit:

```bash
# Make a small change to the swagger file
git add swagger.yaml
git commit -m "Update API documentation"
git push origin main
```

### Option 2: Manual Workflow Trigger

1. Go to **Actions** tab in GitHub
2. Select **Deploy to Azure APIM** workflow
3. Click **Run workflow**
4. Select the branch and click **Run workflow**

### Option 3: Local Manual Deployment

If you want to test locally before committing:

```bash
# Login to Azure
az login

# Run the deployment script
pwsh ./deploy-to-apim.ps1 `
  -ResourceGroupName "my-apim-rg" `
  -ApimServiceName "my-apim-service" `
  -ApiId "sample-api" `
  -SwaggerFilePath "swagger.yaml" `
  -ApiPath "sample-api" `
  -ServiceUrl "https://api.example.com"
```

### Verify Deployment

After deployment, verify the API is accessible:

```bash
# Test the health endpoint
curl https://my-apim-service.azure-api.net/sample-api/api/health

# Test the users endpoint
curl https://my-apim-service.azure-api.net/sample-api/api/users
```

You can also verify in the Azure Portal:

1. Go to Azure Portal
2. Navigate to your API Management service
3. Click on **APIs** in the left menu
4. You should see your "Sample API" listed
5. Click on it to see all operations imported from the Swagger file

## Monitoring and Management

### View API in Azure Portal

1. **Azure Portal** → **API Management services** → **Your APIM**
2. **APIs** → **Sample API**
3. Here you can:
   - Test operations
   - View analytics
   - Configure policies
   - Set up subscriptions
   - Configure rate limiting

### View Deployment Logs

1. Go to your GitHub repository
2. Click **Actions** tab
3. Click on the latest workflow run
4. Expand the steps to see detailed logs

### Test in APIM Portal

```bash
# Get the APIM gateway URL
az apim show \
  --name my-apim-service \
  --resource-group my-apim-rg \
  --query gatewayUrl \
  --output tsv
```

## Troubleshooting

### Issue: Service Principal Authentication Fails

**Symptoms:** GitHub Actions fails with authentication error

**Solution:**
1. Verify `AZURE_CREDENTIALS` secret is correctly formatted JSON
2. Check service principal hasn't expired
3. Recreate service principal if needed:
   ```bash
   az ad sp create-for-rbac --name "github-apim-deploy" --role contributor \
       --scopes /subscriptions/{subscription-id}/resourceGroups/my-apim-rg \
       --sdk-auth
   ```

### Issue: APIM Service Not Found

**Symptoms:** Error message about APIM service not existing

**Solution:**
1. Verify the APIM service name is correct
2. Ensure resource group name matches
3. Check if APIM provisioning completed:
   ```bash
   az apim show --name my-apim-service --resource-group my-apim-rg
   ```

### Issue: Permission Denied

**Symptoms:** Error about insufficient permissions

**Solution:**
1. Verify service principal has "API Management Service Contributor" role
2. Add the role if missing:
   ```bash
   az role assignment create \
     --assignee {clientId} \
     --role "API Management Service Contributor" \
     --scope /subscriptions/{subscription-id}/resourceGroups/my-apim-rg
   ```

### Issue: Invalid Swagger File

**Symptoms:** API import fails with validation errors

**Solution:**
1. Validate your Swagger file using online tools:
   - https://editor.swagger.io/
   - https://apitools.dev/swagger-parser/online/
2. Ensure it's valid OpenAPI 3.0 format
3. Check for syntax errors in YAML

### Issue: API Already Exists

**Symptoms:** Error about API ID already exists

**Solution:**
1. Either use a different API_ID
2. Or delete the existing API in APIM first:
   ```bash
   az apim api delete \
     --api-id sample-api \
     --service-name my-apim-service \
     --resource-group my-apim-rg
   ```

## Advanced Configuration

### Add Custom Policies

You can add policies to your API in APIM Portal:

1. Go to APIM → APIs → Sample API
2. Click on "All operations"
3. In Inbound/Outbound processing, click "</>  Code editor"
4. Add policies like rate limiting, CORS, authentication, etc.

Example policy for rate limiting:

```xml
<policies>
    <inbound>
        <rate-limit calls="100" renewal-period="60" />
        <cors>
            <allowed-origins>
                <origin>*</origin>
            </allowed-origins>
            <allowed-methods>
                <method>GET</method>
                <method>POST</method>
            </allowed-methods>
        </cors>
    </inbound>
</policies>
```

### Environment-Specific Deployments

Modify the GitHub Actions workflow to support multiple environments:

1. Create separate secrets for each environment (dev, staging, prod)
2. Use workflow inputs to select environment
3. Deploy to different APIM instances or use different API paths

### Enable API Subscriptions

To require subscriptions for API access:

1. In the deployment script, remove `--subscription-required false`
2. Or update it to `--subscription-required true`
3. Create subscriptions in APIM Portal
4. Clients will need to include subscription key in requests

## Best Practices

1. **Version Your APIs**: Use API versioning in APIM
2. **Use Products**: Group APIs into products for better management
3. **Enable Caching**: Configure response caching for better performance
4. **Set Rate Limits**: Protect your backend with rate limiting policies
5. **Monitor Usage**: Enable Application Insights for detailed analytics
6. **Secure APIs**: Use OAuth 2.0 or API keys for authentication
7. **Test Before Production**: Always test in a dev APIM instance first

## Cost Optimization

- Use **Developer** tier for non-production environments
- Consider **Consumption** tier for low-volume APIs
- Monitor usage to optimize pricing tier
- Delete unused APIs and operations

## Next Steps

1. ✅ Basic API deployment working
2. 🎯 Add authentication policies
3. 🎯 Configure custom domains
4. 🎯 Set up Application Insights
5. 🎯 Create API versions
6. 🎯 Configure products and subscriptions

## Additional Resources

- [Azure APIM Documentation](https://docs.microsoft.com/azure/api-management/)
- [Azure CLI APIM Commands](https://docs.microsoft.com/cli/azure/apim)
- [GitHub Actions Azure Login](https://github.com/Azure/login)
- [OpenAPI Specification](https://swagger.io/specification/)

## Support

For issues or questions:
- Check GitHub Actions logs
- Review Azure APIM diagnostics
- Consult Azure documentation
- Open an issue in this repository
