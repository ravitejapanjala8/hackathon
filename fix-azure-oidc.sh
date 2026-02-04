#!/bin/bash

# ============================================================================
# Fix Azure Login OIDC Authentication Error
# ============================================================================
# This script updates the Federated Identity Credential in Azure to allow
# GitHub Actions workflows to authenticate from any branch in the repository.
#
# Usage:
#   ./fix-azure-oidc.sh [APP_ID] [TENANT_ID] [REPO_OWNER] [REPO_NAME]
#
# Example:
#   ./fix-azure-oidc.sh 5efb8c81-5fd0-48b1-8235-5e835fe1143c cd1ccae1-8ae4-44bd-8872-50d073143c26 ravitejapanjala8 hackathon
#
# Requirements:
#   - Azure CLI (az) installed and authenticated
#   - Permissions to modify App Registrations in Azure AD
# ============================================================================

# Don't exit on error for interactive prompts
set +e

# Configuration - can be overridden by command-line arguments or environment variables
APP_ID="${1:-${AZURE_APP_ID:-5efb8c81-5fd0-48b1-8235-5e835fe1143c}}"
TENANT_ID="${2:-${AZURE_TENANT_ID:-cd1ccae1-8ae4-44bd-8872-50d073143c26}}"
REPO_OWNER="${3:-${GITHUB_REPO_OWNER:-ravitejapanjala8}}"
REPO_NAME="${4:-${GITHUB_REPO_NAME:-hackathon}}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}============================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check if Azure CLI is installed
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI is not installed"
        echo "Please install it from: https://docs.microsoft.com/cli/azure/install-azure-cli"
        exit 1
    fi
    print_success "Azure CLI is installed"
    
    # Check if logged in to Azure
    if ! az account show &> /dev/null; then
        print_error "Not logged in to Azure"
        echo "Please run: az login"
        exit 1
    fi
    print_success "Logged in to Azure"
    
    # Show current account
    CURRENT_TENANT=$(az account show --query tenantId -o tsv)
    print_info "Current tenant: $CURRENT_TENANT"
    
    if [ "$CURRENT_TENANT" != "$TENANT_ID" ]; then
        print_warning "Current tenant ($CURRENT_TENANT) differs from expected ($TENANT_ID)"
        read -p "Do you want to continue? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    echo
}

# List existing federated credentials
list_existing_credentials() {
    print_header "Current Federated Credentials"
    
    echo "Listing existing federated credentials for app: $APP_ID"
    echo
    
    if ! CREDS=$(az ad app federated-credential list --id $APP_ID 2>&1); then
        print_error "Failed to list federated credentials"
        echo "$CREDS"
        return 1
    fi
    
    if [ "$CREDS" == "[]" ]; then
        print_warning "No existing federated credentials found"
    else
        echo "$CREDS" | jq -r '.[] | "Name: \(.name)\nSubject: \(.subject)\nIssuer: \(.issuer)\n"'
    fi
    
    echo
}

# Delete old credentials
delete_old_credentials() {
    print_header "Deleting Old Federated Credentials"
    
    print_info "Fetching existing credentials..."
    
    if ! CREDS=$(az ad app federated-credential list --id $APP_ID 2>&1); then
        print_error "Failed to list federated credentials"
        echo "$CREDS"
        return 1
    fi
    
    CRED_IDS=$(echo "$CREDS" | jq -r '.[].id' 2>/dev/null)
    
    if [ -z "$CRED_IDS" ]; then
        print_info "No existing credentials to delete"
    else
        echo "Found credentials to delete:"
        echo "$CRED_IDS"
        echo
        
        read -p "Do you want to delete these credentials? (y/n) " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            while IFS= read -r cred_id; do
                if [ -n "$cred_id" ]; then
                    print_info "Deleting credential: $cred_id"
                    az ad app federated-credential delete --id $APP_ID --federated-credential-id "$cred_id"
                    print_success "Deleted credential: $cred_id"
                fi
            done <<< "$CRED_IDS"
        else
            print_warning "Keeping existing credentials (this may cause conflicts)"
        fi
    fi
    
    echo
}

# Create new federated credentials
create_new_credentials() {
    print_header "Creating New Federated Credentials"
    
    # Credential 1: All branches
    print_info "Creating credential for all branches..."
    
    RESULT=$(az ad app federated-credential create \
      --id $APP_ID \
      --parameters "{
        \"name\": \"github-hackathon-all-branches\",
        \"issuer\": \"https://token.actions.githubusercontent.com\",
        \"subject\": \"repo:${REPO_OWNER}/${REPO_NAME}:ref:refs/heads/*\",
        \"audiences\": [\"api://AzureADTokenExchange\"],
        \"description\": \"GitHub Actions federation for all branches in hackathon repository\"
      }" 2>&1)
    
    if [ $? -eq 0 ]; then
        print_success "Created credential for all branches"
    else
        print_error "Failed to create credential for all branches"
        echo "$RESULT"
        if echo "$RESULT" | grep -q "already exists"; then
            print_warning "Credential might already exist, continuing..."
        else
            exit 1
        fi
    fi
    
    echo
    
    # Credential 2: Pull requests
    print_info "Creating credential for pull requests..."
    
    RESULT=$(az ad app federated-credential create \
      --id $APP_ID \
      --parameters "{
        \"name\": \"github-hackathon-pull-requests\",
        \"issuer\": \"https://token.actions.githubusercontent.com\",
        \"subject\": \"repo:${REPO_OWNER}/${REPO_NAME}:pull_request\",
        \"audiences\": [\"api://AzureADTokenExchange\"],
        \"description\": \"GitHub Actions federation for pull requests in hackathon repository\"
      }" 2>&1)
    
    if [ $? -eq 0 ]; then
        print_success "Created credential for pull requests"
    else
        print_error "Failed to create credential for pull requests"
        echo "$RESULT"
        if echo "$RESULT" | grep -q "already exists"; then
            print_warning "Credential might already exist, continuing..."
        else
            exit 1
        fi
    fi
    
    echo
}

# Verify the fix
verify_credentials() {
    print_header "Verifying New Credentials"
    
    echo "Current federated credentials:"
    echo
    
    az ad app federated-credential list --id $APP_ID --query "[].{Name:name, Subject:subject}" -o table
    
    echo
    print_success "Federated credentials are now configured!"
    echo
}

# Main execution
main() {
    clear
    print_header "Azure OIDC Federated Credential Fix Script"
    echo
    echo "This script will update the Federated Identity Credentials for:"
    echo "  App ID: $APP_ID"
    echo "  Repository: $REPO_OWNER/$REPO_NAME"
    echo
    print_warning "This will delete existing federated credentials and create new ones"
    echo
    read -p "Do you want to continue? (y/n) " -n 1 -r
    echo
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Operation cancelled"
        exit 0
    fi
    
    check_prerequisites
    list_existing_credentials
    delete_old_credentials
    create_new_credentials
    verify_credentials
    
    print_header "✅ SUCCESS!"
    echo
    print_success "Federated credentials have been updated successfully!"
    echo
    echo "Your GitHub Actions workflows can now authenticate from:"
    echo "  ✅ Any branch (refs/heads/*)"
    echo "  ✅ Any pull request"
    echo
    print_info "Next steps:"
    echo "  1. Go to https://github.com/${REPO_OWNER}/${REPO_NAME}/actions"
    echo "  2. Run the '🚀 Manual Deployment' workflow"
    echo "  3. The Azure Login step should now succeed!"
    echo
}

# Run the script
main
