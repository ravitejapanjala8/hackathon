# ✅ Deployment Checklist - Ready to Deploy!

## Your Service Principal is Ready! 🎉

You've successfully created the service principal. Now let's get your API deployed!

---

## 📋 Quick Deployment Steps

### Step 1: Add GitHub Secrets (5 minutes)

Go to: **https://github.com/ravitejapanjala8/hackathon/settings/secrets/actions**

Add these 6 secrets (see **CONFIGURE-SECRETS.md** for detailed instructions):

- [ ] `AZURE_CREDENTIALS` - The full JSON you provided
- [ ] `AZURE_SUBSCRIPTION_ID` - `d9a1f276-029e-4843-afe6-f5580c5d2519`
- [ ] `AZURE_WEBAPP_NAME` - `sample-api-hackathon-dev-g7hxepb4atexfvb5`
- [ ] `AZURE_RESOURCE_GROUP` - `rg-hackathon`
- [ ] `APIM_SERVICE_NAME` - `apim-hackathon-dev`
- [ ] `APIM_RESOURCE_GROUP` - `rg-hackathon`

**📖 Detailed Guide**: [CONFIGURE-SECRETS.md](CONFIGURE-SECRETS.md)

---

### Step 2: Trigger Deployment (1 minute)

**Option A - Automatic (Recommended):**
```bash
# Make any small change to trigger deployment
git commit --allow-empty -m "Trigger deployment with configured secrets"
git push origin copilot/build-sample-api-onboard-apim
```

**Option B - Manual:**
1. Go to: https://github.com/ravitejapanjala8/hackathon/actions
2. Click "Deploy API to Azure Web App"
3. Click "Run workflow"
4. Select branch: `copilot/build-sample-api-onboard-apim`
5. Click "Run workflow"

---

### Step 3: Monitor Deployment (5-7 minutes)

Watch the progress:
- **GitHub Actions**: https://github.com/ravitejapanjala8/hackathon/actions

**Timeline:**
- Web App deployment: 3-5 minutes ⏱️
- APIM deployment: 1-2 minutes ⏱️
- Total: ~5-7 minutes ⏱️

---

### Step 4: Test Your API ✨

After successful deployment, test these URLs:

**Web App (Direct):**
```bash
curl https://sample-api-hackathon-dev-g7hxepb4atexfvb5.canadacentral-01.azurewebsites.net/api/health
```

**APIM (Gateway):**
```bash
curl https://apim-hackathon-dev.azure-api.net/sample-api/api/health
```

**Swagger UI:**
```
https://sample-api-hackathon-dev-g7hxepb4atexfvb5.canadacentral-01.azurewebsites.net/swagger
```

---

## 🔧 Optional: Verify Azure Setup First

Run this script to verify all Azure resources are ready:

```bash
./verify-azure-setup.sh
```

This checks:
- ✅ Azure CLI installed
- ✅ Logged in to Azure
- ✅ Resource group exists
- ✅ Web App exists and is running
- ✅ APIM exists and is provisioned
- ✅ Service principal has permissions

---

## 📊 What Happens During Deployment

### Stage 1: Web App Deployment

```
1. Checkout code from GitHub
2. Setup .NET 8.0
3. Restore dependencies
4. Build application
5. Run tests
6. Publish artifacts
7. Login to Azure (using your service principal)
8. Deploy to Web App
9. Test endpoints
```

### Stage 2: APIM Deployment (Auto-triggered)

```
1. Get Web App URL
2. Login to Azure
3. Import swagger.yaml to APIM
4. Configure APIM backend to Web App
5. Test APIM endpoints
```

---

## 🎯 Expected Results

### After Web App Deployment:

✅ Your API running at:
- `https://sample-api-hackathon-dev-g7hxepb4atexfvb5.canadacentral-01.azurewebsites.net`

✅ Endpoints available:
- `/api/health` - Health check
- `/api/users` - User management
- `/swagger` - API documentation

### After APIM Deployment:

✅ Your API accessible through APIM at:
- `https://apim-hackathon-dev.azure-api.net/sample-api`

✅ Benefits:
- Rate limiting
- Authentication/Authorization
- Analytics and monitoring
- Caching
- API versioning

---

## ⚠️ Common Issues

### Issue: "Azure Login Failed"
**Cause**: Secrets not configured or incorrect JSON format

**Solution**:
1. Verify all 6 secrets are added in GitHub
2. Check AZURE_CREDENTIALS is valid JSON with braces `{ }`
3. No extra spaces or line breaks in values

### Issue: "Resource Not Found"
**Cause**: Resource names don't match

**Solution**:
1. Double-check Web App name matches exactly
2. Verify APIM name is correct
3. Confirm resource group name

### Issue: "Insufficient Permissions"
**Cause**: Service principal lacks permissions

**Solution**:
```bash
# Verify permissions
az role assignment list \
  --assignee fedc81fc-7f7a-44db-92c7-ab1dfeaa488d \
  --scope /subscriptions/d9a1f276-029e-4843-afe6-f5580c5d2519/resourceGroups/rg-hackathon
```

Should show "Contributor" role. If not, add it:
```bash
az role assignment create \
  --assignee fedc81fc-7f7a-44db-92c7-ab1dfeaa488d \
  --role Contributor \
  --scope /subscriptions/d9a1f276-029e-4843-afe6-f5580c5d2519/resourceGroups/rg-hackathon
```

### Issue: "APIM Deployment Failed"
**Cause**: APIM still provisioning

**Solution**:
```bash
# Check APIM status
az apim show \
  --name apim-hackathon-dev \
  --resource-group rg-hackathon \
  --query provisioningState
```

If not "Succeeded", wait for provisioning to complete (can take 30-45 minutes for new APIM).

---

## 📚 Documentation Reference

| Document | Purpose |
|----------|---------|
| **CONFIGURE-SECRETS.md** | Detailed steps to add GitHub Secrets |
| **verify-azure-setup.sh** | Verify Azure resources are ready |
| **DEPLOYMENT-GUIDE-CURRENT.md** | Complete deployment guide |
| **AZURE-AUTHENTICATION-GUIDE.md** | Understanding authentication |
| **API-TESTING.md** | How to test your API |
| **QUICK-DEPLOY.md** | Quick reference |

---

## 🚀 You're Almost There!

**Current Status**: ✅ Service Principal Created

**Next Step**: ⏳ Add GitHub Secrets (5 minutes)

**Then**: ⏳ Deploy! (5-7 minutes)

**Result**: 🎉 Your API live in Azure with APIM!

---

## 🆘 Need Help?

1. Check GitHub Actions logs for detailed error messages
2. Review troubleshooting section above
3. Run `./verify-azure-setup.sh` to diagnose issues
4. Check Azure Portal for resource status

---

**🔐 Security Reminder**: Your credentials are safe. We're storing them in GitHub Secrets, not in the repository code.

**Let's deploy! 🚀**
