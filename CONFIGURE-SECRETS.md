# 🔐 GitHub Secrets Configuration Guide

## ⚠️ SECURITY NOTICE

**NEVER commit credentials to your repository!** The service principal details you provided contain sensitive information that must be stored securely in GitHub Secrets.

---

## ✅ Step-by-Step: Add Your Service Principal to GitHub Secrets

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

You need to add **6 secrets**. Click "New repository secret" for each one:

#### Secret 1: AZURE_CREDENTIALS

**Name:** `AZURE_CREDENTIALS`

**Value:** Copy and paste your service principal JSON (the one you already have). It should look like this:

```json
{
  "clientId": "fedc81fc-7f7a-44db-92c7-ab1dfeaa488d",
  "clientSecret": "<your-client-secret-here>",
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

**Use the complete JSON** that you received when creating the service principal (including your actual clientSecret value).

**Important**: Include the opening `{` and closing `}` braces!

---

#### Secret 2: AZURE_SUBSCRIPTION_ID

**Name:** `AZURE_SUBSCRIPTION_ID`

**Value:**
```
d9a1f276-029e-4843-afe6-f5580c5d2519
```

---

#### Secret 3: AZURE_WEBAPP_NAME

**Name:** `AZURE_WEBAPP_NAME`

**Value:**
```
sample-api-hackathon-dev-g7hxepb4atexfvb5
```

---

#### Secret 4: AZURE_RESOURCE_GROUP

**Name:** `AZURE_RESOURCE_GROUP`

**Value:**
```
rg-hackathon
```

---

#### Secret 5: APIM_SERVICE_NAME

**Name:** `APIM_SERVICE_NAME`

**Value:**
```
apim-hackathon-dev
```

---

#### Secret 6: APIM_RESOURCE_GROUP

**Name:** `APIM_RESOURCE_GROUP`

**Value:**
```
rg-hackathon
```

---

## ✅ Verification Checklist

After adding all secrets, verify you have:

- [ ] AZURE_CREDENTIALS (JSON with clientId, clientSecret, etc.)
- [ ] AZURE_SUBSCRIPTION_ID (d9a1f276-029e-4843-afe6-f5580c5d2519)
- [ ] AZURE_WEBAPP_NAME (sample-api-hackathon-dev-g7hxepb4atexfvb5)
- [ ] AZURE_RESOURCE_GROUP (rg-hackathon)
- [ ] APIM_SERVICE_NAME (apim-hackathon-dev)
- [ ] APIM_RESOURCE_GROUP (rg-hackathon)

**Total: 6 secrets**

---

## 🔍 How to Verify Secrets Are Added

1. Go to: https://github.com/ravitejapanjala8/hackathon/settings/secrets/actions
2. You should see all 6 secrets listed
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
1. All 6 secrets are added correctly
2. AZURE_CREDENTIALS contains valid JSON (with braces)
3. No extra spaces or characters in the values

### Issue: "Resource Not Found"

**Solution**: Verify:
1. Web App name is exactly: `sample-api-hackathon-dev-g7hxepb4atexfvb5`
2. APIM name is exactly: `apim-hackathon-dev`
3. Resource group is exactly: `rg-hackathon`

### Issue: "Insufficient Permissions"

**Solution**: Verify the service principal has permissions:
```bash
az role assignment list \
  --assignee fedc81fc-7f7a-44db-92c7-ab1dfeaa488d \
  --scope /subscriptions/d9a1f276-029e-4843-afe6-f5580c5d2519/resourceGroups/rg-hackathon \
  --output table
```

Should show "Contributor" role.

---

## 🔐 Security Best Practices

### ✅ DO:
- Store credentials in GitHub Secrets (you're doing this!)
- Use least-privilege permissions
- Rotate secrets periodically (every 1-2 years)
- Monitor access logs in Azure

### ❌ DON'T:
- Commit credentials to repository
- Share credentials in chat/email/docs
- Use the same credentials for multiple environments
- Give more permissions than needed

---

## 📚 Additional Resources

- **AZURE-AUTHENTICATION-GUIDE.md** - Understanding authentication methods
- **DEPLOYMENT-GUIDE-CURRENT.md** - Complete deployment guide
- **API-TESTING.md** - How to test your API
- **QUICK-DEPLOY.md** - Quick reference

---

## ✅ Summary

1. ✅ Service principal created (you've done this!)
2. ⏳ Add 6 secrets to GitHub (do this now)
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

**Security Reminder**: This document will be committed to the repository, but it only contains instructions. Your actual credentials are safely stored in GitHub Secrets and never appear in the code.
