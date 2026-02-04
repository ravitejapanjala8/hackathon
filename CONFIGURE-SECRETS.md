# 🔐 GitHub Secrets Configuration Guide

## ⚠️ SECURITY NOTICE

**This repository uses OIDC (OpenID Connect) authentication** - a modern, secure method that does NOT require storing secrets in GitHub. You only need to configure a few non-sensitive identifiers.

---

## ✅ Step-by-Step: Configure OIDC Authentication

### 1. Navigate to GitHub Secrets

Go to: **https://github.com/ravitejapanjala8/hackathon/settings/secrets/actions**

Or manually:
1. Go to your repository: https://github.com/ravitejapanjala8/hackathon
2. Click **Settings** (top menu)
3. Click **Secrets and variables** (left sidebar)
4. Click **Actions**
5. Click **New repository secret**

---

### 2. Add Required Secrets

You need to add **7 secrets**. Click "New repository secret" for each one:

#### Secret 1: AZURE_CLIENT_ID

**Name:** `AZURE_CLIENT_ID`

**Value:**
```
5efb8c81-5fd0-48b1-8235-5e835fe1143c
```

This is the Application (Client) ID of the OIDC App Registration that has been created with contributor access.

---

#### Secret 2: AZURE_TENANT_ID

**Name:** `AZURE_TENANT_ID`

**Value:**
```
cd1ccae1-8ae4-44bd-8872-50d073143c26
```

---

#### Secret 3: AZURE_SUBSCRIPTION_ID

**Name:** `AZURE_SUBSCRIPTION_ID`

**Value:**
```
d9a1f276-029e-4843-afe6-f5580c5d2519
```

---

#### Secret 4: AZURE_WEBAPP_NAME

**Name:** `AZURE_WEBAPP_NAME`

**Value:**
```
sample-api-hackathon-dev-g7hxepb4atexfvb5
```

---

#### Secret 5: AZURE_RESOURCE_GROUP

**Name:** `AZURE_RESOURCE_GROUP`

**Value:**
```
rg-hackathon
```

---

#### Secret 6: APIM_SERVICE_NAME

**Name:** `APIM_SERVICE_NAME`

**Value:**
```
apim-hackathon-dev
```

---

#### Secret 7: APIM_RESOURCE_GROUP

**Name:** `APIM_RESOURCE_GROUP`

**Value:**
```
rg-hackathon
```

---

## ✅ Verification Checklist

After adding all secrets, verify you have:

- [ ] AZURE_CLIENT_ID (5efb8c81-5fd0-48b1-8235-5e835fe1143c)
- [ ] AZURE_TENANT_ID (cd1ccae1-8ae4-44bd-8872-50d073143c26)
- [ ] AZURE_SUBSCRIPTION_ID (d9a1f276-029e-4843-afe6-f5580c5d2519)
- [ ] AZURE_WEBAPP_NAME (sample-api-hackathon-dev-g7hxepb4atexfvb5)
- [ ] AZURE_RESOURCE_GROUP (rg-hackathon)
- [ ] APIM_SERVICE_NAME (apim-hackathon-dev)
- [ ] APIM_RESOURCE_GROUP (rg-hackathon)

**Total: 7 secrets**

---

## 🔍 How to Verify Secrets Are Added

1. Go to: https://github.com/ravitejapanjala8/hackathon/settings/secrets/actions
2. You should see all 7 secrets listed
3. You won't be able to view the values (GitHub hides them for security)
4. You'll see when each was last updated

---

## 🚀 Next Steps: Deploy Your API

Once all secrets are configured:

### Option 1: Automatic Deployment (Recommended)

The workflows will automatically trigger on the next code change. To trigger manually:

1. Make a small change (e.g., update README)
2. Commit and push:
   ```bash
   git add .
   git commit -m "Trigger deployment"
   git push origin copilot/build-sample-api-onboard-apim
   ```

### Option 2: Manual Trigger

1. Go to: https://github.com/ravitejapanjala8/hackathon/actions
2. Select "Deploy API to Azure Web App" workflow
3. Click "Run workflow" button
4. Select branch: `copilot/build-sample-api-onboard-apim`
5. Click "Run workflow"

---

## 📊 What Happens Next

### Stage 1: Web App Deployment (3-5 minutes)
- Workflow builds the .NET application
- Runs tests
- Publishes to Azure Web App
- Tests the deployed endpoints

### Stage 2: APIM Deployment (1-2 minutes)
- Automatically triggers after Web App succeeds
- Imports OpenAPI specification
- Configures APIM to proxy to Web App
- Tests APIM endpoints

---

## 🌐 Your API Endpoints

After successful deployment, your API will be available at:

### Direct Web App Access:
```
https://sample-api-hackathon-dev-g7hxepb4atexfvb5.canadacentral-01.azurewebsites.net/api/health
https://sample-api-hackathon-dev-g7hxepb4atexfvb5.canadacentral-01.azurewebsites.net/swagger
```

### Through APIM Gateway (Recommended):
```
https://apim-hackathon-dev.azure-api.net/sample-api/api/health
https://apim-hackathon-dev.azure-api.net/sample-api/api/users
```

---

## 🔍 Monitor Deployment

Watch the deployment progress:
- GitHub Actions: https://github.com/ravitejapanjala8/hackathon/actions
- Click on the running workflow to see live logs

---

## ⚠️ Troubleshooting

### Issue: Workflow Fails with "Azure Login Failed"

**Solution**: Check that:
1. All 7 secrets are added correctly
2. AZURE_CLIENT_ID, AZURE_TENANT_ID, and AZURE_SUBSCRIPTION_ID match the OIDC app registration values
3. The OIDC app registration has a federated credential configured for your GitHub repository
4. No extra spaces or characters in the values

### Issue: "Resource Not Found"

**Solution**: Verify:
1. Web App name is exactly: `sample-api-hackathon-dev-g7hxepb4atexfvb5`
2. APIM name is exactly: `apim-hackathon-dev`
3. Resource group is exactly: `rg-hackathon`

### Issue: "Insufficient Permissions"

**Solution**: Verify the OIDC app registration (client ID: 5efb8c81-5fd0-48b1-8235-5e835fe1143c) has Contributor permissions:
```bash
az role assignment list \
  --assignee 5efb8c81-5fd0-48b1-8235-5e835fe1143c \
  --scope /subscriptions/d9a1f276-029e-4843-afe6-f5580c5d2519/resourceGroups/rg-hackathon \
  --output table
```

Should show "Contributor" role.

### Issue: "Federated Credential Not Found"

**Solution**: Ensure the OIDC app registration has a federated credential configured for your GitHub repository. The credential should specify:
- **Issuer**: `https://token.actions.githubusercontent.com`
- **Subject**: `repo:ravitejapanjala8/hackathon:ref:refs/heads/main` (or your branch name)
- **Audiences**: `["api://AzureADTokenExchange"]`

---

## 🔐 Security Best Practices

### ✅ DO:
- Use OIDC authentication (you're doing this!) - no secrets to manage
- Store identifiers in GitHub Secrets for convenience
- Use least-privilege permissions
- Monitor access logs in Azure

### ❌ DON'T:
- Commit credentials to repository
- Share credentials in chat/email/docs
- Use the same credentials for multiple environments
- Give more permissions than needed

### 🎉 Benefits of OIDC:
- **No Secrets**: Nothing sensitive stored in GitHub
- **No Rotation**: No secrets to rotate or manage
- **Short-lived Tokens**: Temporary tokens (~1 hour) that can't be reused
- **Better Security**: Modern authentication standard

---

## 📚 Additional Resources

- **AZURE-AUTHENTICATION-GUIDE.md** - Understanding authentication methods
- **DEPLOYMENT-GUIDE-CURRENT.md** - Complete deployment guide
- **API-TESTING.md** - How to test your API
- **QUICK-DEPLOY.md** - Quick reference

---

## ✅ Summary

1. ✅ OIDC app registration created with client ID: 5efb8c81-5fd0-48b1-8235-5e835fe1143c
2. ⏳ Add 7 secrets to GitHub (do this now)
3. ⏳ Trigger deployment
4. ⏳ Verify endpoints work

**You're almost there!** Just add the secrets and you can deploy! 🚀

---

## 🆘 Need Help?

If you encounter issues:
1. Check GitHub Actions logs for error messages
2. Review the troubleshooting section above
3. Verify all secrets are added correctly
4. Check Azure Portal that resources exist

---

**Security Reminder**: This repository uses OIDC authentication - no secrets are stored! The client ID and other identifiers in GitHub Secrets are non-sensitive and only used to establish trusted connections.
