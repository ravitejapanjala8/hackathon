# 🚀 How to Deploy - Quick Guide

This guide shows you how to manually trigger deployments using GitHub Actions.

## 📍 Available Deployment Workflows

Your repository now has **3 deployment workflows** available in the GitHub Actions tab:

1. **🚀 Manual Deployment** ⭐ **(RECOMMENDED)** - Deploy everything in one go
2. **Deploy API to Azure Web App** - Deploy just the Web App
3. **Deploy API to Azure APIM** - Deploy just the APIM configuration

## ✅ How to Deploy Using GitHub Actions UI

### Step 1: Navigate to Actions Tab

1. Go to your repository: https://github.com/ravitejapanjala8/hackathon
2. Click on the **"Actions"** tab at the top

### Step 2: Select a Workflow

You'll see a list of workflows on the left sidebar. Click on one:

- **🚀 Manual Deployment** (Recommended - deploys both Web App and APIM)
- **Deploy API to Azure Web App** (Web App only)
- **Deploy API to Azure APIM** (APIM only)

### Step 3: Run the Workflow

1. After selecting a workflow, you'll see a **"Run workflow"** button on the right side
2. Click the **"Run workflow"** dropdown button
3. Select options:
   - **Branch**: Choose your branch (e.g., `copilot/fix-deploy-option-in-actions`)
   - **Deploy target** (for Manual Deployment only):
     - `Both (Web App + APIM)` - Full deployment (recommended)
     - `Web App Only` - Just deploy the backend
     - `APIM Only` - Just configure APIM gateway
   - **Environment**: Choose `dev`, `staging`, or `production`
4. Click the green **"Run workflow"** button

### Step 4: Monitor Progress

1. The workflow will appear in the list below
2. Click on it to see real-time logs
3. Watch each step complete with ✅ checkmarks
4. View the deployment summary at the end

## 🎯 Which Workflow Should I Use?

### Use "🚀 Manual Deployment" when:
- ✅ You want to deploy everything at once
- ✅ You're doing a fresh deployment
- ✅ You want the simplest experience
- ✅ You're not sure what to deploy

### Use "Deploy API to Azure Web App" when:
- You only changed the C# code
- You only want to deploy the backend
- APIM is already configured correctly

### Use "Deploy API to Azure APIM" when:
- You only changed the Swagger/OpenAPI file
- Web App is already deployed
- You only want to update APIM configuration

## 📋 Prerequisites

Before deploying, ensure these GitHub Secrets are configured:

| Secret Name | Description |
|-------------|-------------|
| `AZURE_CREDENTIALS` | Service principal JSON for Azure authentication |
| `AZURE_WEBAPP_NAME` | Name of your Azure Web App |
| `AZURE_RESOURCE_GROUP` | Azure Resource Group name |
| `APIM_SERVICE_NAME` | Azure APIM service name |
| `APIM_RESOURCE_GROUP` | APIM Resource Group (usually same as above) |

**Need to configure secrets?** See [CONFIGURE-SECRETS.md](CONFIGURE-SECRETS.md)

## 🔗 What URLs Will I Get?

After successful deployment, you'll have these URLs:

### Web App Direct Access:
```
https://[your-webapp-name].azurewebsites.net/api/health
https://[your-webapp-name].azurewebsites.net/swagger
```

### APIM Gateway Access (Recommended):
```
https://[apim-name].azure-api.net/sample-api/api/health
https://[apim-name].azure-api.net/sample-api/api/users
```

## 🎬 Visual Guide

### Finding the "Run workflow" Button

```
GitHub Repository
└── Actions Tab (Top navigation)
    └── Workflows (Left sidebar)
        ├── 🚀 Manual Deployment ⭐
        ├── Deploy API to Azure Web App
        └── Deploy API to Azure APIM
            └── [Select one]
                └── "Run workflow" button (Right side, blue/green)
                    └── Dropdown appears
                        ├── Select branch
                        ├── Choose options
                        └── Click "Run workflow"
```

## 🔍 Troubleshooting

### "I don't see the 'Run workflow' button"

**Possible causes:**
1. **Not logged in** - Make sure you're logged into GitHub
2. **No permissions** - You need write access to the repository
3. **Wrong branch** - The workflows are configured but might need a push to be visible
4. **Browser cache** - Try refreshing the page (Ctrl+F5 / Cmd+Shift+R)

**Solutions:**
- Refresh the GitHub Actions page
- Make sure you're on the Actions tab
- Check that you have write permissions to the repository
- Try clicking on a specific workflow in the left sidebar

### "Workflow fails with authentication error"

**Solution:** Check that `AZURE_CREDENTIALS` secret is configured correctly.

See: [CONFIGURE-SECRETS.md](CONFIGURE-SECRETS.md)

### "Deployment succeeds but API doesn't respond"

**Solution:** Wait a few minutes for the deployment to fully propagate, then check Azure Portal to verify the Web App is running.

## 📊 Workflow Features

### 🚀 Manual Deployment Workflow Benefits:

✅ **Single-click deployment** - Deploy everything in one go  
✅ **Smart dependencies** - APIM waits for Web App to finish  
✅ **Rich summaries** - See deployment status and URLs at the end  
✅ **Flexible options** - Choose what to deploy  
✅ **Emoji indicators** - Easy to read logs  

### Automatic Deployments (Still Enabled)

The workflows will still automatically deploy when you push code:

- **Web App**: Auto-deploys on push to `main`/`master` with C# file changes
- **APIM**: Auto-deploys after Web App deployment or on Swagger file changes

## 🎓 Next Steps

After successful deployment:

1. **Test Your API** - Use the URLs from the deployment summary
2. **Check Azure Portal** - Verify resources are running
3. **Set Up Monitoring** - Enable Application Insights (optional)
4. **Configure APIM Policies** - Add rate limiting, authentication, etc.

## 📚 Additional Resources

- [QUICK-DEPLOY.md](QUICK-DEPLOY.md) - Quick reference for Azure resources
- [DEPLOYMENT-GUIDE-CURRENT.md](DEPLOYMENT-GUIDE-CURRENT.md) - Detailed deployment guide
- [API-TESTING.md](API-TESTING.md) - How to test your deployed API
- [CONFIGURE-SECRETS.md](CONFIGURE-SECRETS.md) - How to set up GitHub Secrets

---

**Need Help?** Check the GitHub Actions logs for detailed error messages, or review this guide again.

**Found this helpful?** The "🚀 Manual Deployment" workflow is specifically designed to make deployments easy and visible in the Actions UI!
