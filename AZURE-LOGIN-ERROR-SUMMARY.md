# Azure Login Error - Quick Summary

## 🎯 The Issue

GitHub Actions workflows fail with:
```
Login failed with Error: Using auth-type: SERVICE_PRINCIPAL. Not all values are present.
```

## 🔍 Why This Happens

The Azure federated credential is configured for **one specific branch** only:
- Configured for: `copilot/build-sample-api-onboard-apim`
- Workflows run from: `main`, `master`, `copilot/fix-azure-login-error`, etc.
- Result: ❌ Authentication fails when branch doesn't match

## ✅ The Fix

Update the federated credential to allow **all branches** (or specific ones you need).

## 🚀 Two Ways to Fix

### Option 1: Automated Script (Easiest)
```bash
./fix-azure-oidc.sh
```

This script will:
1. ✅ List current credentials
2. ✅ Delete old credentials
3. ✅ Create new credentials for all branches
4. ✅ Create new credentials for pull requests
5. ✅ Verify the fix

### Option 2: Manual Commands (Azure CLI)
```bash
APP_ID="5efb8c81-5fd0-48b1-8235-5e835fe1143c"

# Delete old credential (get ID from list command)
az ad app federated-credential list --id $APP_ID
az ad app federated-credential delete --id $APP_ID --federated-credential-id <id>

# Create new credential for all branches
az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "github-hackathon-all-branches",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:ravitejapanjala8/hackathon:ref:refs/heads/*",
    "audiences": ["api://AzureADTokenExchange"]
  }'

# Create credential for pull requests
az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "github-hackathon-pull-requests",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:ravitejapanjala8/hackathon:pull_request",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

## 📚 Complete Documentation

For detailed instructions, troubleshooting, and Azure Portal method:
- **[FIX-AZURE-LOGIN-ERROR.md](FIX-AZURE-LOGIN-ERROR.md)** - Complete fix guide (recommended)
- **[AZURE-AUTHENTICATION-GUIDE.md](AZURE-AUTHENTICATION-GUIDE.md)** - Understanding OIDC authentication

## ✅ After the Fix

1. Go to: https://github.com/ravitejapanjala8/hackathon/actions
2. Select **"🚀 Manual Deployment"**
3. Click **"Run workflow"**
4. Choose your branch
5. Click **"Run workflow"**
6. ✅ Azure Login should now succeed!

## 🔐 What This Changes

**Before:**
```
Subject: repo:ravitejapanjala8/hackathon:ref:refs/heads/copilot/build-sample-api-onboard-apim
Result: ❌ Only that specific branch can authenticate
```

**After:**
```
Subject: repo:ravitejapanjala8/hackathon:ref:refs/heads/*
Result: ✅ All branches can authenticate
```

## ⚠️ Security Note

Using `*` (wildcard) allows deployments from any branch. For production environments, consider:
- Limiting to specific branches: `main`, `production`
- Using GitHub environments with protection rules
- Creating separate credentials per environment

## 🆘 Still Having Issues?

See the troubleshooting section in [FIX-AZURE-LOGIN-ERROR.md](FIX-AZURE-LOGIN-ERROR.md).

Common issues:
- ✅ Verify GitHub secrets are set correctly
- ✅ Wait a few minutes after updating credentials
- ✅ Ensure workflow has `id-token: write` permission
- ✅ Check that you have permissions to modify app registrations in Azure
