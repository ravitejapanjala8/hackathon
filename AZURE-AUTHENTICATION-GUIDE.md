# Azure Authentication for GitHub Actions

This guide explains how GitHub Actions connects to Azure resources and the two authentication methods available.

## 🔐 Understanding Azure Authentication for GitHub Actions

When GitHub Actions needs to deploy resources to Azure, it requires authentication. There are **two primary methods**:

1. **Service Principal with Secret** (App Registration) - Traditional method
2. **Federated Identity with OIDC** (OpenID Connect) - Modern, more secure method

---

## 📊 Comparison: Which Method Should You Use?

| Feature | Service Principal + Secret | Federated Identity (OIDC) |
|---------|---------------------------|---------------------------|
| **Security** | ⚠️ Stores secrets in GitHub | ✅ No secrets stored |
| **Setup Complexity** | ✅ Simpler (one command) | ⚠️ More steps required |
| **Secret Rotation** | ⚠️ Must rotate manually | ✅ No secrets to rotate |
| **Expiration** | ⚠️ Secrets can expire | ✅ No expiration |
| **Azure Setup** | App Registration + Secret | App Registration + Federated Credential |
| **GitHub Workflow** | Use `creds` parameter | Use `client-id`, `tenant-id`, `subscription-id` |
| **Current Status** | ❌ Deprecated in this repo | ✅ **CURRENTLY IN USE** |
| **Recommended For** | Quick setup, testing | **Production, enhanced security** |

### 🎯 Recommendation
- **For Production**: Use Federated Identity with OIDC (✅ **CURRENTLY CONFIGURED**)
- **For Testing/Quick Setup**: Use Service Principal with Secret (legacy)

---

## Method 1: Service Principal with Secret (Legacy)

**⚠️ Note**: This repository has migrated to OIDC (Method 2). This section is kept for reference only.

This is the traditional method where you create an App Registration (Service Principal) and generate a client secret.

### What Happens:
1. You create an App Registration in Azure Entra ID (formerly Azure AD)
2. Azure generates a client secret (password)
3. You store the entire credential JSON in GitHub Secrets
4. GitHub Actions uses these credentials to authenticate

### Setup Steps:

#### Step 1: Create Service Principal

```bash
az ad sp create-for-rbac \
  --name "github-hackathon-deploy" \
  --role contributor \
  --scopes /subscriptions/d9a1f276-029e-4843-afe6-f5580c5d2519/resourceGroups/rg-hackathon \
  --sdk-auth
```

**Output** (save this entire JSON):
```json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "d9a1f276-029e-4843-afe6-f5580c5d2519",
  "tenantId": "cd1ccae1-8ae4-44bd-8872-50d073143c26",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  ...
}
```

#### Step 2: Add to GitHub Secrets

1. Go to: `https://github.com/ravitejapanjala8/hackathon/settings/secrets/actions`
2. Create secret: `AZURE_CREDENTIALS`
3. Paste the **entire JSON** from Step 1

#### Step 3: GitHub Workflow Configuration

```yaml
- name: Azure Login
  uses: azure/login@v1
  with:
    creds: ${{ secrets.AZURE_CREDENTIALS }}
```

### What Gets Created in Azure:

1. **App Registration** in Azure Entra ID
   - Location: Azure Portal → Azure Active Directory → App registrations
   - Name: `github-hackathon-deploy`
   - Has a Client ID (Application ID)

2. **Service Principal**
   - Linked to the App Registration
   - Has permissions assigned (Contributor role)
   - Located in: Azure Active Directory → Enterprise Applications

3. **Client Secret**
   - Generated password stored in the App Registration
   - Has an expiration date (default: 2 years)
   - Must be rotated before expiration

### ⚠️ Security Considerations:

- **Secret Management**: The client secret is stored in GitHub
- **Expiration**: Secrets expire (usually after 2 years)
- **Rotation**: You must manually rotate secrets before expiration
- **Access**: Anyone with access to GitHub secrets can see the credentials

---

## Method 2: Federated Identity with OIDC (✅ Currently Configured)

**✅ This repository uses OIDC authentication** - the newer, more secure method that doesn't require storing any secrets in GitHub.

### Current Configuration:
- **Client ID**: `5efb8c81-5fd0-48b1-8235-5e835fe1143c`
- **Tenant ID**: `cd1ccae1-8ae4-44bd-8872-50d073143c26`
- **Subscription ID**: `d9a1f276-029e-4843-afe6-f5580c5d2519`

This is the newer, more secure method that doesn't require storing any secrets in GitHub.

### What Happens:
1. You create an App Registration in Azure Entra ID
2. Instead of a secret, you configure a Federated Identity Credential
3. This establishes trust between GitHub and Azure using OIDC
4. GitHub Actions gets temporary tokens from Azure when needed
5. No secrets are stored anywhere

### How OIDC Works:

```
┌──────────────┐                           ┌─────────────────┐
│   GitHub     │  1. Request token         │  Azure Entra ID │
│   Actions    │ ────────────────────────> │    (formerly    │
│              │  (with GitHub identity)   │    Azure AD)    │
│              │                           │                 │
│              │  2. Validate request      │                 │
│              │     via Federated         │                 │
│              │     Credential            │                 │
│              │                           │                 │
│              │  3. Issue temp token      │                 │
│              │ <──────────────────────── │                 │
│              │  (short-lived, ~1 hour)   │                 │
└──────────────┘                           └─────────────────┘
        │
        │ 4. Use token to access Azure
        ▼
┌──────────────┐
│    Azure     │
│  Resources   │
│  (Web App,   │
│    APIM)     │
└──────────────┘
```

### Setup Steps:

#### Step 1: Create App Registration (No Secret)

```bash
# Create the App Registration
APP_ID=$(az ad app create \
  --display-name "github-hackathon-oidc" \
  --query appId \
  --output tsv)

echo "Application (Client) ID: $APP_ID"

# Create Service Principal for the App
SP_ID=$(az ad sp create --id $APP_ID --query id --output tsv)

echo "Service Principal Object ID: $SP_ID"
```

#### Step 2: Assign Permissions

```bash
# Assign Contributor role to the Service Principal
az role assignment create \
  --assignee $APP_ID \
  --role Contributor \
  --scope /subscriptions/d9a1f276-029e-4843-afe6-f5580c5d2519/resourceGroups/rg-hackathon
```

#### Step 3: Create Federated Identity Credential

**⚠️ Important**: To support deployments from **all branches** (recommended for flexibility), use a wildcard pattern:

```bash
# Create federated credential for all branches
az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "github-hackathon-all-branches",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:ravitejapanjala8/hackathon:ref:refs/heads/*",
    "audiences": ["api://AzureADTokenExchange"],
    "description": "GitHub Actions federation for all branches in hackathon repository"
  }'

# Also create one for pull requests
az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "github-hackathon-pull-requests",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:ravitejapanjala8/hackathon:pull_request",
    "audiences": ["api://AzureADTokenExchange"],
    "description": "GitHub Actions federation for pull requests"
  }'
```

**Alternative (More Restrictive)**: For a specific branch only:
```bash
az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "github-hackathon-main",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:ravitejapanjala8/hackathon:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"],
    "description": "GitHub Actions federation for main branch"
  }'
```

**⚠️ Common Issue**: If your federated credential is configured for a specific branch but your workflows run from different branches, you'll get an authentication error. See **[FIX-AZURE-LOGIN-ERROR.md](FIX-AZURE-LOGIN-ERROR.md)** for the complete fix.

**Subject Pattern Reference**:
- For all branches: `repo:OWNER/REPO:ref:refs/heads/*`
- For specific branch: `repo:OWNER/REPO:ref:refs/heads/BRANCH_NAME`
- For all PRs: `repo:OWNER/REPO:pull_request`
- For environment: `repo:OWNER/REPO:environment:ENVIRONMENT_NAME`

#### Step 4: Configure GitHub Secrets

Add these secrets to GitHub (NO client secret needed!):

1. `AZURE_CLIENT_ID`: `5efb8c81-5fd0-48b1-8235-5e835fe1143c` (✅ Already configured)
2. `AZURE_TENANT_ID`: `cd1ccae1-8ae4-44bd-8872-50d073143c26`
3. `AZURE_SUBSCRIPTION_ID`: `d9a1f276-029e-4843-afe6-f5580c5d2519`

**✅ The workflows in this repository are already configured to use these OIDC secrets.**

#### Step 5: GitHub Workflow Configuration

**✅ The workflows in this repository are already configured for OIDC.**

The Azure Login step in `.github/workflows/deploy-webapp.yml`, `.github/workflows/deploy-apim.yml`, and `.github/workflows/manual-deploy.yml` uses:

```yaml
- name: Azure Login
  uses: azure/login@v1
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

All jobs have the required `id-token: write` permission:
```yaml
permissions:
  contents: read
  id-token: write  # ✅ Required for OIDC!
```

### What Gets Created in Azure:

1. **App Registration** in Azure Entra ID
   - Location: Azure Portal → Azure Active Directory → App registrations
   - Name: `github-hackathon-oidc`
   - Has a Client ID but NO client secret

2. **Federated Identity Credential**
   - Location: App Registration → Certificates & secrets → Federated credentials
   - Establishes trust with GitHub's OIDC provider
   - Specifies which GitHub repo/branch can authenticate

3. **Service Principal**
   - Linked to the App Registration
   - Has permissions assigned (Contributor role)

### ✅ Security Benefits:

- **No Secrets**: Nothing sensitive stored in GitHub
- **Short-lived Tokens**: Temporary tokens (~1 hour) that can't be reused
- **No Rotation**: No secrets to rotate or manage
- **Audit Trail**: All authentication attempts logged in Azure
- **Fine-grained Control**: Can restrict to specific branches, environments, or PRs

---

## 🔍 Common Questions

### Q: What is an "App Registration" vs "Service Principal"?

**App Registration**: 
- The identity definition in Azure Entra ID
- Contains the client ID and authentication settings
- Think of it as the "blueprint" for the identity

**Service Principal**:
- The actual identity object that can be assigned permissions
- Automatically created when you create an App Registration
- Think of it as the "instance" that acts in Azure

They're closely related - when you create an App Registration, Azure automatically creates a corresponding Service Principal.

### Q: Do I need to use Azure Entra ID (formerly Azure AD)?

**Yes**. Both authentication methods require Azure Entra ID because:
- App Registrations live in Entra ID
- Service Principals are managed by Entra ID
- Authentication and authorization happen through Entra ID

Even if you're just deploying to a Web App or APIM, the **identity management** happens in Entra ID.

### Q: Can I use Managed Identity instead?

**No, not for GitHub Actions**. Managed Identity only works for Azure resources authenticating to other Azure resources (e.g., a VM accessing Key Vault). GitHub Actions runs outside Azure, so it needs either:
- Service Principal with Secret, or
- Service Principal with Federated Credential (OIDC)

### Q: Which method is the current setup using?

The current repository uses **Method 2: Federated Identity with OIDC** (✅ Currently configured). The workflows use:
```yaml
client-id: ${{ secrets.AZURE_CLIENT_ID }}
tenant-id: ${{ secrets.AZURE_TENANT_ID }}
subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

The configured client ID is: `5efb8c81-5fd0-48b1-8235-5e835fe1143c`

### Q: How do I migrate from Service Principal to OIDC?

**✅ Already completed!** This repository has already been migrated to OIDC authentication. The workflows now use OIDC instead of service principal secrets.

If you're migrating another repository, follow these steps:
1. Create new App Registration (without secret)
2. Set up Federated Credential
3. Update GitHub Secrets (replace AZURE_CREDENTIALS with CLIENT_ID, TENANT_ID, SUBSCRIPTION_ID)
4. Update workflow files (change login step)
5. Test the workflows
6. Delete the old service principal and secret

### Q: What permissions does the identity need?

**Minimum Required Permissions**:
- **Contributor** role on the Resource Group
- **API Management Service Contributor** role (if deploying to APIM)

You can assign these to either:
- The entire resource group (easier)
- Specific resources (more secure)

```bash
# Resource group level
az role assignment create \
  --assignee <CLIENT_ID> \
  --role Contributor \
  --scope /subscriptions/<SUB_ID>/resourceGroups/<RG_NAME>

# APIM specific
az role assignment create \
  --assignee <CLIENT_ID> \
  --role "API Management Service Contributor" \
  --scope /subscriptions/<SUB_ID>/resourceGroups/<RG_NAME>/providers/Microsoft.ApiManagement/service/<APIM_NAME>
```

---

## 🎯 Quick Decision Guide

**Use Service Principal with Secret if:**
- ✅ You're doing a quick proof-of-concept
- ✅ You're learning and want the simplest setup
- ✅ You need to deploy immediately
- ✅ Your organization hasn't adopted OIDC yet

**Use Federated Identity with OIDC if:** (✅ **Currently configured**)
- ✅ You're setting up production workloads
- ✅ Security is a primary concern
- ✅ You want to avoid secret management overhead
- ✅ You want to comply with security best practices
- ✅ Your team is comfortable with the setup complexity

---

## 📚 Additional Resources

### Official Documentation
- [Azure Service Principals](https://learn.microsoft.com/azure/active-directory/develop/app-objects-and-service-principals)
- [GitHub OIDC with Azure](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure)
- [Azure Login Action](https://github.com/Azure/login)

### Security Best Practices
- Assign minimum required permissions (least privilege)
- Use resource-specific roles when possible
- Regularly review and audit permissions
- For OIDC, restrict to specific branches/environments
- Monitor authentication attempts in Azure logs

### Troubleshooting
- Check App Registration permissions in Azure Portal
- Verify Federated Credential subject matches your repo/branch
- Ensure workflow has `id-token: write` permission for OIDC
- Check Azure Activity Log for failed authentication attempts

---

## 💡 Summary

**Current Setup**: This repository uses **Federated Identity with OIDC** (✅ Method 2)

**To Deploy with Current Setup**:
1. Ensure the OIDC app registration (client ID: 5efb8c81-5fd0-48b1-8235-5e835fe1143c) has contributor access to the resource group
2. Ensure a federated credential is configured for your GitHub repository
3. Add the required GitHub secrets (AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID)
4. Deploy!

**Security Benefits**:
- ✅ No secrets stored in GitHub
- ✅ Short-lived tokens (~1 hour)
- ✅ No rotation needed
- ✅ Better audit trail

Both methods use **App Registration** in **Azure Entra ID** - the difference is how authentication credentials are handled (secret vs. federated identity). This repository is configured to use the more secure federated identity approach.
