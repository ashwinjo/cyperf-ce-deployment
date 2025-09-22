#!/bin/bash

# Terraform Manager Script
# Handles init, plan, apply, and destroy operations with dynamic parameters

set -e

# Default values
OPERATION="apply"
PRIMARY_REGION=""
SECONDARY_REGION=""
INSTANCE_TYPE=""
KEY_NAME=""
AWS_ACCESS_KEY_ID=""
AWS_SECRET_ACCESS_KEY=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo -e "${BLUE}Terraform Manager Script${NC}"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Required Options:"
    echo "  --aws-access-key-id KEY         AWS Access Key ID"
    echo "  --aws-secret-access-key SECRET  AWS Secret Access Key"
    echo "  --primary-region REGION         Primary AWS region (e.g., us-east-1)"
    echo "  --secondary-region REGION       Secondary AWS region (e.g., us-west-2)"
    echo "  --instance-type TYPE            EC2 instance type (e.g., c5n.2xlarge)"
    echo "  --key-name NAME                 AWS key pair name"
    echo ""
    echo "Optional Options:"
    echo "  --operation OPERATION           Operation: plan|apply|destroy (default: apply)"
    echo "  -h, --help                      Show this help message"
    echo ""
    echo "Examples:"
    echo "  # Plan deployment"
    echo "  $0 --aws-access-key-id=\"AKIA...\" --aws-secret-access-key=\"xyz...\" \\"
    echo "     --primary-region=us-east-1 --secondary-region=us-west-2 \\"
    echo "     --instance-type=c5n.2xlarge --key-name=vibecode --operation=plan"
    echo ""
    echo "  # Apply deployment"
    echo "  $0 --aws-access-key-id=\"AKIA...\" --aws-secret-access-key=\"xyz...\" \\"
    echo "     --primary-region=us-east-1 --secondary-region=us-west-2 \\"
    echo "     --instance-type=c5n.2xlarge --key-name=vibecode"
    echo ""
    echo "  # Destroy infrastructure"
    echo "  $0 --aws-access-key-id=\"AKIA...\" --aws-secret-access-key=\"xyz...\" \\"
    echo "     --primary-region=us-east-1 --secondary-region=us-west-2 \\"
    echo "     --instance-type=c5n.2xlarge --key-name=vibecode --operation=destroy"
}

# Function to validate required parameters
validate_params() {
    local missing_params=()
    
    if [[ -z "$AWS_ACCESS_KEY_ID" ]]; then
        missing_params+=("aws-access-key-id")
    fi
    
    if [[ -z "$AWS_SECRET_ACCESS_KEY" ]]; then
        missing_params+=("aws-secret-access-key")
    fi
    
    if [[ -z "$PRIMARY_REGION" ]]; then
        missing_params+=("primary-region")
    fi
    
    if [[ -z "$SECONDARY_REGION" ]]; then
        missing_params+=("secondary-region")
    fi
    
    if [[ -z "$INSTANCE_TYPE" ]]; then
        missing_params+=("instance-type")
    fi
    
    if [[ -z "$KEY_NAME" ]]; then
        missing_params+=("key-name")
    fi
    
    if [[ ${#missing_params[@]} -gt 0 ]]; then
        echo -e "${RED}Error: Missing required parameters:${NC}"
        for param in "${missing_params[@]}"; do
            echo -e "  ${RED}• --${param}${NC}"
        done
        echo ""
        usage
        exit 1
    fi
}

# Function to display operation summary
show_summary() {
    echo -e "${BLUE}=== Terraform Operation Summary ===${NC}"
    echo -e "Operation:           ${GREEN}${OPERATION}${NC}"
    echo -e "Primary Region:      ${GREEN}${PRIMARY_REGION}${NC}"
    echo -e "Secondary Region:    ${GREEN}${SECONDARY_REGION}${NC}"
    echo -e "Instance Type:       ${GREEN}${INSTANCE_TYPE}${NC}"
    echo -e "Key Name:            ${GREEN}${KEY_NAME}${NC}"
    echo -e "AWS Access Key:      ${GREEN}${AWS_ACCESS_KEY_ID:0:10}...${NC}"
    echo ""
}

# Function to run terraform init
run_terraform_init() {
    echo -e "${CYAN}Step 1: Initializing Terraform...${NC}"
    terraform init
    echo -e "${GREEN}✓ Terraform initialization completed${NC}"
    echo ""
}

# Function to run terraform plan
run_terraform_plan() {
    echo -e "${CYAN}Step 2: Planning Terraform deployment...${NC}"
    
    AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
    AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
    terraform plan \
      -var="primary_region=$PRIMARY_REGION" \
      -var="secondary_region=$SECONDARY_REGION" \
      -var="instance_type=$INSTANCE_TYPE" \
      -var="key_name=$KEY_NAME"
    
    echo -e "${GREEN}✓ Terraform plan completed${NC}"
    echo ""
}

# Function to run terraform apply
run_terraform_apply() {
    echo -e "${CYAN}Step 3: Applying Terraform deployment...${NC}"
    
    AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
    AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
    terraform apply \
      -var="primary_region=$PRIMARY_REGION" \
      -var="secondary_region=$SECONDARY_REGION" \
      -var="instance_type=$INSTANCE_TYPE" \
      -var="key_name=$KEY_NAME" \
      -auto-approve
    
    echo -e "${GREEN}✓ Terraform apply completed successfully!${NC}"
    echo ""
    echo -e "${BLUE}Getting deployment outputs...${NC}"
    terraform output
}

# Function to run terraform destroy
run_terraform_destroy() {
    echo -e "${CYAN}Step 2: Destroying Terraform infrastructure...${NC}"
    echo -e "${YELLOW}WARNING: This will destroy all infrastructure!${NC}"
    
    AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
    AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
    terraform destroy \
      -var="primary_region=$PRIMARY_REGION" \
      -var="secondary_region=$SECONDARY_REGION" \
      -var="instance_type=$INSTANCE_TYPE" \
      -var="key_name=$KEY_NAME" \
      -auto-approve
    
    echo -e "${GREEN}✓ Infrastructure destroyed successfully!${NC}"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --aws-access-key-id=*)
            AWS_ACCESS_KEY_ID="${1#*=}"
            shift
            ;;
        --aws-access-key-id)
            AWS_ACCESS_KEY_ID="$2"
            shift 2
            ;;
        --aws-secret-access-key=*)
            AWS_SECRET_ACCESS_KEY="${1#*=}"
            shift
            ;;
        --aws-secret-access-key)
            AWS_SECRET_ACCESS_KEY="$2"
            shift 2
            ;;
        --primary-region=*)
            PRIMARY_REGION="${1#*=}"
            shift
            ;;
        --primary-region)
            PRIMARY_REGION="$2"
            shift 2
            ;;
        --secondary-region=*)
            SECONDARY_REGION="${1#*=}"
            shift
            ;;
        --secondary-region)
            SECONDARY_REGION="$2"
            shift 2
            ;;
        --instance-type=*)
            INSTANCE_TYPE="${1#*=}"
            shift
            ;;
        --instance-type)
            INSTANCE_TYPE="$2"
            shift 2
            ;;
        --key-name=*)
            KEY_NAME="${1#*=}"
            shift
            ;;
        --key-name)
            KEY_NAME="$2"
            shift 2
            ;;
        --operation=*)
            OPERATION="${1#*=}"
            shift
            ;;
        --operation)
            OPERATION="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            exit 1
            ;;
    esac
done

# Validate operation parameter
case $OPERATION in
    plan|apply|destroy)
        ;;
    *)
        echo -e "${RED}Error: Invalid operation '$OPERATION'. Must be: plan, apply, or destroy${NC}"
        exit 1
        ;;
esac

# Validate required parameters
validate_params

# Show operation summary
show_summary

# Confirm destroy operation
if [[ "$OPERATION" == "destroy" ]]; then
    echo -e "${YELLOW}You are about to DESTROY infrastructure in AWS.${NC}"
    echo -e "${YELLOW}This action cannot be undone!${NC}"
    read -p "Are you absolutely sure you want to continue? (type 'yes' to confirm): " confirm
    if [[ "$confirm" != "yes" ]]; then
        echo -e "${YELLOW}Operation cancelled.${NC}"
        exit 0
    fi
    echo ""
fi

# Execute operations based on the chosen operation
case $OPERATION in
    plan)
        run_terraform_init
        run_terraform_plan
        echo -e "${GREEN}✓ Plan operation completed!${NC}"
        echo -e "Run with ${YELLOW}--operation=apply${NC} to deploy the infrastructure."
        ;;
    apply)
        run_terraform_init
        run_terraform_plan
        run_terraform_apply
        echo -e "${GREEN}✓ Apply operation completed successfully!${NC}"
        ;;
    destroy)
        run_terraform_init
        run_terraform_destroy
        echo -e "${GREEN}✓ Destroy operation completed!${NC}"
        ;;
esac

echo -e "${BLUE}Operation '$OPERATION' finished successfully!${NC}"
