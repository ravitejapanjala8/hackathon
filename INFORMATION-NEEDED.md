# Information Needed from You

Hi! To deploy your API to Azure Web App and APIM, I need the following information from you. Please provide these details:

## 🎯 Quick Checklist

### 1. Azure Subscription Information
- [ ] **Subscription ID**: _________________________________
- [ ] **Tenant ID**: _________________________________

### 2. Resource Naming (Must be globally unique!)
- [ ] **Resource Group Name**: _________________________________
      (Example: `rg-hackathon-dev`)

- [ ] **Web App Name**: _________________________________
      (Example: `sample-api-hackathon-dev`)
      Will be: `https://{this-name}.azurewebsites.net`

- [ ] **APIM Service Name**: _________________________________
      (Example: `apim-hackathon-dev`)
      Will be: `https://{this-name}.azure-api.net`

### 3. Pricing Tiers (Choose one for each)

**App Service Plan:**
- [ ] F1 (Free - for testing only)
- [ ] B1 (Basic - $13/month - **recommended for dev**)
- [ ] S1 (Standard - $69/month)
- [ ] P1V2 (Premium - $73/month)

**APIM:**
- [ ] Developer ($50/month - **recommended for dev/test**)
- [ ] Basic ($140/month)
- [ ] Standard ($678/month)
- [ ] Premium ($2,740/month)

### 4. Location/Region
- [ ] **Azure Region**: _________________________________
      (Example: `eastus`, `westus2`, `westeurope`)

---

## ✅ What I've Already Done

I've created the following for you:

1. ✅ **GitHub Actions Workflows**:
   - `deploy-webapp.yml` - Deploys API to Azure Web App
   - `deploy-apim.yml` - Configures APIM to use Web App as backend

2. ✅ **Documentation**:
   - `DEPLOYMENT-REQUIREMENTS.md` - Complete list of requirements
   - `WEBAPP-APIM-DEPLOYMENT.md` - Step-by-step deployment guide
   - Updated README with architecture overview

3. ✅ **Architecture**:
   - Client → APIM (Gateway) → Web App (Backend)
   - Sequential deployment: Web App first, then APIM

---

## 📋 What Happens Next

Once you provide the information above, here's what you'll need to do:

### Step 1: Create Azure Resources
I'll provide you with commands to run (or you can create via Azure Portal):
```bash
# Create resource group
az group create --name {your-rg} --location {your-region}

# Create App Service Plan
az appservice plan create --name {plan-name} --resource-group {your-rg} --sku B1 --is-linux

# Create Web App
az webapp create --name {your-webapp} --resource-group {your-rg} --plan {plan-name} --runtime "DOTNET|8.0"

# Create APIM (takes 30-45 minutes!)
az apim create --name {your-apim} --resource-group {your-rg} --publisher-name "Your Name" --publisher-email "your@email.com" --sku-name Developer
```

### Step 2: Create Service Principal
```bash
az ad sp create-for-rbac --name "github-hackathon-deploy" --role contributor --scopes /subscriptions/{sub-id}/resourceGroups/{your-rg} --sdk-auth
```
**Save the JSON output!**

### Step 3: Configure GitHub Secrets
Add these secrets to your GitHub repository:
- `AZURE_CREDENTIALS` (service principal JSON)
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_WEBAPP_NAME`
- `AZURE_RESOURCE_GROUP`
- `APIM_SERVICE_NAME`
- `APIM_RESOURCE_GROUP`

### Step 4: Deploy!
Push code to trigger deployment:
```bash
git push origin main
```

Or manually trigger in GitHub Actions.

---

## 💡 Recommendations

### For Development/Testing:
- Web App: B1 (Basic)
- APIM: Developer
- **Total Cost: ~$63/month**

### For Production:
- Web App: P1V2 (Premium)
- APIM: Standard or Premium
- **Total Cost: ~$751+/month**

### Region Selection:
- Choose a region close to your users
- Popular choices: `eastus`, `westus2`, `westeurope`, `southeastasia`
- Some regions may have lower costs

---

## 🆘 Need Help?

If you're not sure about any of these:
1. Start with the **Development/Testing** tier
2. Choose a region close to you
3. Use simple names (e.g., `my-api-dev`, `my-apim-dev`)
4. I can guide you through each step!

---

## ⚡ Quick Start (If You Want to Just Try It)

If you want to quickly test with minimal cost:

```bash
RESOURCE_GROUP="rg-hackathon-test"
WEBAPP_NAME="myapi-test-$(date +%s)"  # Unique name
APIM_NAME="myapim-test-$(date +%s)"   # Unique name
LOCATION="eastus"

# Create everything (takes ~45 minutes for APIM)
az group create --name $RESOURCE_GROUP --location $LOCATION
az appservice plan create --name asp-test --resource-group $RESOURCE_GROUP --sku F1 --is-linux
az webapp create --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP --plan asp-test --runtime "DOTNET|8.0"
az apim create --name $APIM_NAME --resource-group $RESOURCE_GROUP --publisher-name "Test" --publisher-email "test@test.com" --sku-name Developer --no-wait

echo "Your Web App: https://$WEBAPP_NAME.azurewebsites.net"
echo "Your APIM (when ready): https://$APIM_NAME.azure-api.net"
```

---

## 📝 Reply Format

You can reply with something like:

```
Subscription ID: 12345678-1234-1234-1234-123456789abc
Tenant ID: 87654321-4321-4321-4321-987654321cba
Resource Group: rg-my-hackathon
Web App Name: my-sample-api-dev
APIM Name: my-apim-dev
App Service Plan: B1
APIM Tier: Developer
Region: eastus
```

Or just answer the questions in the checklist above!

---

**Once I have this information, I'll provide you with the exact commands to run and help you get everything deployed!** 🚀
