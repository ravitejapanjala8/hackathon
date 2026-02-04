#!/bin/bash

# Azure Connection Verification Script
# This script helps verify that your Azure service principal is configured correctly

set -e

echo "════════════════════════════════════════════════════════════════"
echo "  Azure Service Principal Verification"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Your Azure configuration
CLIENT_ID="fedc81fc-7f7a-44db-92c7-ab1dfeaa488d"
SUBSCRIPTION_ID="d9a1f276-029e-4843-afe6-f5580c5d2519"
TENANT_ID="cd1ccae1-8ae4-44bd-8872-50d073143c26"
RESOURCE_GROUP="rg-hackathon"
WEBAPP_NAME="sample-api-hackathon-dev-g7hxepb4atexfvb5"
APIM_NAME="apim-hackathon-dev"

echo "Configuration:"
echo "  Client ID: $CLIENT_ID"
echo "  Subscription: $SUBSCRIPTION_ID"
echo "  Tenant: $TENANT_ID"
echo "  Resource Group: $RESOURCE_GROUP"
echo ""

# Check if Azure CLI is installed
echo "1. Checking Azure CLI installation..."
if ! command -v az &> /dev/null; then
    echo -e "${RED}✗ Azure CLI is not installed${NC}"
    echo "  Install from: https://docs.microsoft.com/cli/azure/install-azure-cli"
    exit 1
fi
echo -e "${GREEN}✓ Azure CLI is installed${NC}"
AZ_VERSION=$(az version --query '"azure-cli"' -o tsv)
echo "  Version: $AZ_VERSION"
echo ""

# Check if logged in
echo "2. Checking Azure login status..."
ACCOUNT=$(az account show 2>&1)
if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Not logged in to Azure${NC}"
    echo "  Please run: az login"
    echo "  Or use service principal: az login --service-principal -u $CLIENT_ID -p <SECRET> --tenant $TENANT_ID"
    exit 1
fi
echo -e "${GREEN}✓ Logged in to Azure${NC}"

CURRENT_SUB=$(az account show --query id -o tsv)
CURRENT_TENANT=$(az account show --query tenantId -o tsv)
echo "  Current Subscription: $CURRENT_SUB"
echo "  Current Tenant: $CURRENT_TENANT"
echo ""

# Check if using correct subscription
echo "3. Verifying subscription..."
if [ "$CURRENT_SUB" != "$SUBSCRIPTION_ID" ]; then
    echo -e "${YELLOW}⚠ Different subscription detected${NC}"
    echo "  Setting to: $SUBSCRIPTION_ID"
    az account set --subscription $SUBSCRIPTION_ID
    echo -e "${GREEN}✓ Subscription set${NC}"
else
    echo -e "${GREEN}✓ Using correct subscription${NC}"
fi
echo ""

# Check if using correct tenant
echo "4. Verifying tenant..."
if [ "$CURRENT_TENANT" != "$TENANT_ID" ]; then
    echo -e "${RED}✗ Different tenant detected${NC}"
    echo "  Expected: $TENANT_ID"
    echo "  Current: $CURRENT_TENANT"
    echo "  You may need to switch tenants or re-login"
else
    echo -e "${GREEN}✓ Using correct tenant${NC}"
fi
echo ""

# Check resource group
echo "5. Checking resource group..."
RG_EXISTS=$(az group exists --name $RESOURCE_GROUP)
if [ "$RG_EXISTS" == "true" ]; then
    echo -e "${GREEN}✓ Resource group exists: $RESOURCE_GROUP${NC}"
    RG_LOCATION=$(az group show --name $RESOURCE_GROUP --query location -o tsv)
    echo "  Location: $RG_LOCATION"
else
    echo -e "${RED}✗ Resource group not found: $RESOURCE_GROUP${NC}"
    exit 1
fi
echo ""

# Check Web App
echo "6. Checking Web App..."
WEBAPP_EXISTS=$(az webapp show --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP --query name -o tsv 2>/dev/null || echo "")
if [ -n "$WEBAPP_EXISTS" ]; then
    echo -e "${GREEN}✓ Web App exists: $WEBAPP_NAME${NC}"
    WEBAPP_STATE=$(az webapp show --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP --query state -o tsv)
    WEBAPP_URL=$(az webapp show --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP --query defaultHostName -o tsv)
    echo "  State: $WEBAPP_STATE"
    echo "  URL: https://$WEBAPP_URL"
else
    echo -e "${RED}✗ Web App not found: $WEBAPP_NAME${NC}"
fi
echo ""

# Check APIM
echo "7. Checking API Management..."
APIM_EXISTS=$(az apim show --name $APIM_NAME --resource-group $RESOURCE_GROUP --query name -o tsv 2>/dev/null || echo "")
if [ -n "$APIM_EXISTS" ]; then
    echo -e "${GREEN}✓ APIM exists: $APIM_NAME${NC}"
    APIM_STATE=$(az apim show --name $APIM_NAME --resource-group $RESOURCE_GROUP --query provisioningState -o tsv)
    APIM_GATEWAY=$(az apim show --name $APIM_NAME --resource-group $RESOURCE_GROUP --query gatewayUrl -o tsv)
    echo "  Provisioning State: $APIM_STATE"
    echo "  Gateway URL: $APIM_GATEWAY"
    
    if [ "$APIM_STATE" != "Succeeded" ]; then
        echo -e "${YELLOW}⚠ APIM is not fully provisioned yet${NC}"
        echo "  This can take 30-45 minutes for new APIM services"
    fi
else
    echo -e "${RED}✗ APIM not found: $APIM_NAME${NC}"
fi
echo ""

# Check service principal permissions
echo "8. Checking service principal permissions..."
ROLE_ASSIGNMENTS=$(az role assignment list \
    --assignee $CLIENT_ID \
    --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP \
    --query "[].{Role:roleDefinitionName,Scope:scope}" \
    -o table 2>/dev/null || echo "")

if [ -n "$ROLE_ASSIGNMENTS" ]; then
    echo -e "${GREEN}✓ Service principal has role assignments${NC}"
    echo "$ROLE_ASSIGNMENTS"
else
    echo -e "${YELLOW}⚠ No role assignments found for service principal${NC}"
    echo "  The service principal may not have permissions"
    echo "  Expected: Contributor role on resource group"
fi
echo ""

# Test Web App endpoint (if exists)
if [ -n "$WEBAPP_EXISTS" ] && [ "$WEBAPP_STATE" == "Running" ]; then
    echo "9. Testing Web App endpoint..."
    HEALTH_URL="https://$WEBAPP_URL/api/health"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$HEALTH_URL" || echo "000")
    
    if [ "$HTTP_CODE" == "200" ]; then
        echo -e "${GREEN}✓ Web App is responding${NC}"
        echo "  URL: $HEALTH_URL"
        echo "  Status: $HTTP_CODE"
    elif [ "$HTTP_CODE" == "000" ]; then
        echo -e "${YELLOW}⚠ Could not reach Web App${NC}"
        echo "  This is normal if the app hasn't been deployed yet"
    else
        echo -e "${YELLOW}⚠ Web App returned status: $HTTP_CODE${NC}"
        echo "  URL: $HEALTH_URL"
    fi
    echo ""
fi

# Summary
echo "════════════════════════════════════════════════════════════════"
echo "  Verification Summary"
echo "════════════════════════════════════════════════════════════════"
echo ""

if [ -n "$WEBAPP_EXISTS" ] && [ -n "$APIM_EXISTS" ] && [ "$APIM_STATE" == "Succeeded" ]; then
    echo -e "${GREEN}✓ All resources verified successfully!${NC}"
    echo ""
    echo "You're ready to deploy! Follow these steps:"
    echo "1. Add secrets to GitHub (see CONFIGURE-SECRETS.md)"
    echo "2. Trigger the deployment workflow"
    echo "3. Monitor at: https://github.com/ravitejapanjala8/hackathon/actions"
elif [ -n "$WEBAPP_EXISTS" ] && [ -n "$APIM_EXISTS" ]; then
    echo -e "${YELLOW}⚠ Resources exist but APIM may still be provisioning${NC}"
    echo ""
    echo "Wait for APIM provisioning to complete, then:"
    echo "1. Add secrets to GitHub (see CONFIGURE-SECRETS.md)"
    echo "2. Trigger the deployment workflow"
else
    echo -e "${RED}✗ Some resources are missing${NC}"
    echo ""
    echo "Ensure all Azure resources are created:"
    echo "- Resource Group: $RESOURCE_GROUP"
    echo "- Web App: $WEBAPP_NAME"
    echo "- APIM: $APIM_NAME"
fi

echo ""
echo "════════════════════════════════════════════════════════════════"
