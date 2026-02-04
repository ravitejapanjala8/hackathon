# 🔧 Fix Azure Login Error - OIDC Authentication

## ❌ Problem

When running GitHub Actions workflows, you may encounter this error:

```
Azure Login
Login failed with Error: Using auth-type: SERVICE_PRINCIPAL. Not all values are present. 
Ensure 'client-id' and 'tenant-id' are supplied.. Double check if the 'auth-type' is correct. 
Refer to https://github.com/Azure/login#readme for more information.
```

## 🔍 Root Cause

The Azure App Registration has a **Federated Identity Credential** configured for OIDC authentication, but the credential's **subject** field is restricted to a specific branch:

```
repo:ravitejapanjala8/hackathon:ref:refs/heads/copilot/build-sample-api-onboard-apim
```

When workflows run from different branches (e.g., `main`, `master`, `copilot/fix-azure-login-error`), the OIDC subject doesn't match, causing authentication to fail.

## ✅ Solution

Update the Federated Identity Credential to allow **all branches** in the repository by using a more flexible subject pattern.

---

## 🚀 Quick Fix (Option 1: Allow All Branches and PRs - Recommended)

This option allows workflows to run from any branch and pull request in the repository.

### Step 1: Get the Application ID

```bash
# Your application ID is:
APP_ID="5efb8c81-5fd0-48b1-8235-5e835fe1143c"
```

### Step 2: Delete the Old Federated Credential

```bash
# List existing federated credentials to find the ID
az ad app federated-credential list --id $APP_ID

# Delete the old credential (use the credential ID from the list above)
az ad app federated-credential delete \
  --id $APP_ID \
  --federated-credential-id <credential-id-from-list>
```

### Step 3: Create New Federated Credentials

Create **two** federated credentials - one for branches and one for pull requests:

#### For All Branches:
```bash
az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "github-hackathon-all-branches",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:ravitejapanjala8/hackathon:ref:refs/heads/*",
    "audiences": ["api://AzureADTokenExchange"],
    "description": "GitHub Actions federation for all branches in hackathon repository"
  }'
```

#### For Pull Requests:
```bash
az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "github-hackathon-pull-requests",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:ravitejapanjala8/hackathon:pull_request",
    "audiences": ["api://AzureADTokenExchange"],
    "description": "GitHub Actions federation for pull requests in hackathon repository"
  }'
```

**✅ Done!** Your workflows can now run from any branch and pull request.

---

## 🎯 Alternative Fix (Option 2: Specific Branches Only)

If you want to restrict deployments to specific branches only (more secure), create credentials for each branch:

### For Main Branch:
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

### For Master Branch:
```bash
az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "github-hackathon-master",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:ravitejapanjala8/hackathon:ref:refs/heads/master",
    "audiences": ["api://AzureADTokenExchange"],
    "description": "GitHub Actions federation for master branch"
  }'
```

### For Current Working Branch:
```bash
az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "github-hackathon-fix-branch",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:ravitejapanjala8/hackathon:ref:refs/heads/copilot/fix-azure-login-error",
    "audiences": ["api://AzureADTokenExchange"],
    "description": "GitHub Actions federation for fix branch"
  }'
```

---

## 🔐 Using Azure Portal (Alternative Method)

If you prefer using the Azure Portal GUI:

### Step 1: Navigate to App Registration

1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to **Azure Active Directory** (or **Microsoft Entra ID**)
3. Click **App registrations**
4. Find and click: **github-hackathon-oidc** (Client ID: 5efb8c81-5fd0-48b1-8235-5e835fe1143c)

### Step 2: Update Federated Credentials

1. In the left menu, click **Certificates & secrets**
2. Click the **Federated credentials** tab
3. Click on the existing credential (likely named "github-hackathon-federation" or similar)
4. Click **Delete** to remove it
5. Click **Add credential**
6. Select **GitHub Actions deploying Azure resources**
7. Fill in the form:
   - **Organization**: `ravitejapanjala8`
   - **Repository**: `hackathon`
   - **Entity type**: 
     - Select **Branch** and enter `*` for all branches (if supported), OR
     - Select **Pull request** for PR-based deployments, OR
     - Select **Branch** and enter specific branch names one by one
   - **Name**: `github-hackathon-all-branches`
8. Click **Add**

**Note**: The Azure Portal may not support wildcards. If that's the case, you'll need to:
- Create multiple credentials (one for each branch: `main`, `master`, etc.), OR
- Use the Azure CLI method (Option 1 above) which supports wildcards

### Step 3: Repeat for Pull Requests (Optional)

If you want workflows to work in pull requests:
1. Click **Add credential** again
2. Select **GitHub Actions deploying Azure resources**
3. Fill in:
   - **Organization**: `ravitejapanjala8`
   - **Repository**: `hackathon`
   - **Entity type**: **Pull request**
   - **Name**: `github-hackathon-pull-requests`
4. Click **Add**

---

## ✅ Verify the Fix

After updating the federated credentials, test the fix:

### Method 1: Trigger a Manual Workflow

1. Go to: https://github.com/ravitejapanjala8/hackathon/actions
2. Select **"🚀 Manual Deployment"** workflow
3. Click **"Run workflow"**
4. Select your current branch
5. Choose deployment options
6. Click **"Run workflow"**
7. Monitor the logs - the Azure Login step should now succeed

### Method 2: Check Federated Credentials

```bash
# List all federated credentials for the app
az ad app federated-credential list --id $APP_ID --output table
```

You should see output like:
```
Name                               Issuer                                    Subject
---------------------------------  ----------------------------------------  ------------------------------------------
github-hackathon-all-branches      https://token.actions.githubusercontent.com  repo:ravitejapanjala8/hackathon:ref:refs/heads/*
github-hackathon-pull-requests     https://token.actions.githubusercontent.com  repo:ravitejapanjala8/hackathon:pull_request
```

---

## 📊 Understanding the Subject Pattern

The `subject` field in the federated credential determines which GitHub Actions runs can authenticate:

| Subject Pattern | What It Allows | Use Case |
|-----------------|----------------|----------|
| `repo:OWNER/REPO:ref:refs/heads/*` | All branches | Development/testing |
| `repo:OWNER/REPO:ref:refs/heads/main` | Only main branch | Production deployments |
| `repo:OWNER/REPO:ref:refs/heads/BRANCH` | Specific branch | Isolated environments |
| `repo:OWNER/REPO:pull_request` | All pull requests | PR validation |
| `repo:OWNER/REPO:environment:ENV` | Specific environment | Environment-based control |

**⚠️ Security Note**: Using wildcards (`*`) is convenient but less secure. For production, consider:
- Limiting to specific branches (e.g., `main`, `production`)
- Using GitHub environments with protection rules
- Creating separate credentials for different environments

---

## 🆘 Troubleshooting

### Still Getting Authentication Errors?

1. **Verify the credentials are created**:
   ```bash
   az ad app federated-credential list --id $APP_ID
   ```

2. **Check the subject matches your repository**:
   - Ensure the org/owner is correct: `ravitejapanjala8`
   - Ensure the repo name is correct: `hackathon`
   - Ensure the subject pattern includes your branch

3. **Verify GitHub Secrets are set**:
   - Go to: https://github.com/ravitejapanjala8/hackathon/settings/secrets/actions
   - Ensure these exist:
     - `AZURE_CLIENT_ID`: `5efb8c81-5fd0-48b1-8235-5e835fe1143c`
     - `AZURE_TENANT_ID`: `cd1ccae1-8ae4-44bd-8872-50d073143c26`
     - `AZURE_SUBSCRIPTION_ID`: `d9a1f276-029e-4843-afe6-f5580c5d2519`

4. **Check workflow has correct permissions**:
   ```yaml
   permissions:
     contents: read
     id-token: write  # ← This is REQUIRED for OIDC!
   ```

5. **Wait a few minutes**: Sometimes Azure takes a minute to propagate credential changes.

### Error: "Credential name already exists"

If you get this error when creating a credential:
```bash
# List existing credentials
az ad app federated-credential list --id $APP_ID

# Delete the conflicting one
az ad app federated-credential delete \
  --id $APP_ID \
  --federated-credential-id <id-of-conflicting-credential>

# Try creating again
```

### Error: "Insufficient permissions"

You need one of these roles to modify app registrations:
- **Application Administrator**
- **Cloud Application Administrator**
- **Global Administrator**
- **Owner** of the specific app registration

Contact your Azure admin if you don't have these permissions.

---

## 📚 Related Documentation

- **AZURE-AUTHENTICATION-GUIDE.md** - Complete guide to Azure authentication methods
- **CONFIGURE-SECRETS.md** - How to set up GitHub Secrets
- **HOW-TO-DEPLOY.md** - How to trigger deployments
- [Azure OIDC Documentation](https://learn.microsoft.com/azure/active-directory/workload-identities/workload-identity-federation)
- [GitHub Actions OIDC with Azure](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure)

---

## 🎯 Summary

**Problem**: Federated credential restricted to one branch
**Solution**: Update credential to allow all branches (or specific ones you need)
**Result**: GitHub Actions can deploy from any branch 🚀

Choose **Option 1** (allow all branches) for the quickest fix, or **Option 2** (specific branches) for better security.
