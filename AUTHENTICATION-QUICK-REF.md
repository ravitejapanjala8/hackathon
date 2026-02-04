# Azure Authentication Quick Reference

## 🎯 Quick Answer

**Yes, you need App Registration in Azure Entra ID!**

Both authentication methods require it. The difference is:
- **Method 1**: App Registration + Client Secret (current setup)
- **Method 2**: App Registration + Federated Credential (OIDC - more secure)

---

## 📊 Visual Comparison

### Method 1: Service Principal with Secret (Current)

```
┌─────────────────────────────────────────────────────────────────┐
│                     Azure Entra ID                              │
│                                                                 │
│  ┌──────────────────────────────────────────────────────┐     │
│  │  App Registration: github-hackathon-deploy           │     │
│  │  • Client ID: xxxx-xxxx-xxxx-xxxx                    │     │
│  │  • Client Secret: ************************           │     │
│  │  • Tenant ID: cd1ccae1-8ae4-...                      │     │
│  └──────────────────────────────────────────────────────┘     │
│                           ↓                                     │
│  ┌──────────────────────────────────────────────────────┐     │
│  │  Service Principal (automatically created)           │     │
│  │  • Has "Contributor" role                            │     │
│  │  • Can access rg-hackathon resources                 │     │
│  └──────────────────────────────────────────────────────┘     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                           ↓
                  Client Secret stored in
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│                   GitHub Secrets                                │
│                                                                 │
│  AZURE_CREDENTIALS = {                                          │
│    "clientId": "xxxx",                                          │
│    "clientSecret": "****",     ← Secret stored here            │
│    "subscriptionId": "...",                                     │
│    "tenantId": "..."                                            │
│  }                                                              │
└─────────────────────────────────────────────────────────────────┘
                           ↓
                  Used by GitHub Actions
                           ↓
                   Authenticates to Azure
```

**Setup Command:**
```bash
az ad sp create-for-rbac --name "github-hackathon-deploy" --role contributor --scopes /subscriptions/d9a1f276-029e-4843-afe6-f5580c5d2519/resourceGroups/rg-hackathon --sdk-auth
```

---

### Method 2: Federated Identity with OIDC (More Secure)

```
┌─────────────────────────────────────────────────────────────────┐
│                     Azure Entra ID                              │
│                                                                 │
│  ┌──────────────────────────────────────────────────────┐     │
│  │  App Registration: github-hackathon-oidc             │     │
│  │  • Client ID: xxxx-xxxx-xxxx-xxxx                    │     │
│  │  • NO Client Secret! ✅                              │     │
│  │  • Tenant ID: cd1ccae1-8ae4-...                      │     │
│  │                                                       │     │
│  │  ┌────────────────────────────────────────────┐     │     │
│  │  │ Federated Identity Credential              │     │     │
│  │  │ • Issuer: token.actions.githubusercontent.com  │ │     │
│  │  │ • Subject: repo:owner/repo:ref:...         │     │     │
│  │  │ • Audience: api://AzureADTokenExchange     │     │     │
│  │  └────────────────────────────────────────────┘     │     │
│  └──────────────────────────────────────────────────────┘     │
│                           ↓                                     │
│  ┌──────────────────────────────────────────────────────┐     │
│  │  Service Principal (automatically created)           │     │
│  │  • Has "Contributor" role                            │     │
│  │  • Can access rg-hackathon resources                 │     │
│  └──────────────────────────────────────────────────────┘     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                           ↑
                  Trust established via OIDC
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│                   GitHub Secrets                                │
│                                                                 │
│  AZURE_CLIENT_ID: "xxxx-xxxx-xxxx-xxxx"                        │
│  AZURE_TENANT_ID: "cd1ccae1-8ae4-..."                          │
│  AZURE_SUBSCRIPTION_ID: "d9a1f276-029e-..."                    │
│                                                                 │
│  NO secret stored! ✅                                           │
└─────────────────────────────────────────────────────────────────┘
                           ↓
                GitHub Actions requests token
                           ↓
         Azure Entra ID validates and issues temp token
                           ↓
                    GitHub uses token (~1 hour)
```

**Setup Commands:**
```bash
# 1. Create App Registration
APP_ID=$(az ad app create --display-name "github-hackathon-oidc" --query appId -o tsv)

# 2. Create Service Principal
az ad sp create --id $APP_ID

# 3. Assign permissions
az role assignment create --assignee $APP_ID --role Contributor --scope /subscriptions/d9a1f276-029e-4843-afe6-f5580c5d2519/resourceGroups/rg-hackathon

# 4. Create Federated Credential
az ad app federated-credential create --id $APP_ID --parameters '{
  "name": "github-federation",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:ravitejapanjala8/hackathon:ref:refs/heads/copilot/build-sample-api-onboard-apim",
  "audiences": ["api://AzureADTokenExchange"]
}'
```

---

## 🔑 Key Concepts

| Term | What It Is | Where to Find |
|------|-----------|---------------|
| **App Registration** | Identity definition in Entra ID | Azure Portal → Entra ID → App registrations |
| **Service Principal** | Identity instance that can act | Azure Portal → Entra ID → Enterprise Applications |
| **Client Secret** | Password for the identity | App Registration → Certificates & secrets |
| **Federated Credential** | OIDC trust configuration | App Registration → Certificates & secrets → Federated credentials |
| **Azure Entra ID** | Identity service (formerly Azure AD) | Azure Portal → Azure Active Directory |

---

## ✅ Both Methods Need:

1. ✅ Azure Entra ID (formerly Azure AD)
2. ✅ App Registration
3. ✅ Service Principal
4. ✅ Role Assignment (Contributor)

## ❌ Differences:

| Feature | Method 1 (Secret) | Method 2 (OIDC) |
|---------|------------------|-----------------|
| Client Secret | ✅ Created | ❌ Not needed |
| Federated Credential | ❌ Not used | ✅ Required |
| Secrets in GitHub | 1 (JSON) | 3 (IDs only) |
| Contains Password | ⚠️ Yes | ✅ No |

---

## 🎯 For This Repository

**Current Setup**: Method 1 (Service Principal with Secret)

**To Get Started Now**:
1. Run the `az ad sp create-for-rbac` command
2. Add AZURE_CREDENTIALS to GitHub Secrets
3. Deploy!

**To Upgrade to OIDC Later**: See [AZURE-AUTHENTICATION-GUIDE.md](AZURE-AUTHENTICATION-GUIDE.md) for migration steps

---

## 📚 Full Documentation

For complete details, see [AZURE-AUTHENTICATION-GUIDE.md](AZURE-AUTHENTICATION-GUIDE.md)
