#!/bin/bash

# Cyperf CE Deployment Script
# This script provides an easy way to deploy Cyperf infrastructure with command-line arguments

set -e

# Default values
ACTION="plan"
PRIMARY_REGION=""
SECONDARY_REGION=""
INSTANCE_TYPE=""
KEY_NAME=""
PRIMARY_VPC_CIDR="10.0.0.0/16"
SECONDARY_VPC_CIDR="10.1.0.0/16"
PRIMARY_SUBNET_CIDR="10.0.1.0/24"
SECONDARY_SUBNET_CIDR="10.1.1.0/24"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo -e "${BLUE}Cyperf CE Deployment Script${NC}"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Required Options:"
    echo "  -p, --primary-region REGION     Primary AWS region (e.g., us-east-1)"
    echo "  -s, --secondary-region REGION   Secondary AWS region (e.g., us-west-2)"
    echo "  -i, --instance-type TYPE        EC2 instance type (e.g., c5n.2xlarge)"
    echo "  -k, --key-name NAME             AWS key pair name"
    echo ""
    echo "Optional Options:"
    echo "  -a, --action ACTION             Action to perform: plan|apply|destroy (default: plan)"
    echo "  --primary-vpc-cidr CIDR         Primary VPC CIDR (default: 10.0.0.0/16)"
    echo "  --secondary-vpc-cidr CIDR       Secondary VPC CIDR (default: 10.1.0.0/16)"
    echo "  --primary-subnet-cidr CIDR      Primary subnet CIDR (default: 10.0.1.0/24)"
    echo "  --secondary-subnet-cidr CIDR    Secondary subnet CIDR (default: 10.1.1.0/24)"
    echo "  -h, --help                      Show this help message"
    echo ""
    echo "Examples:"
    echo "  # Plan deployment in US regions"
    echo "  $0 -p us-east-1 -s us-west-2 -i c5n.2xlarge -k my-key"
    echo ""
    echo "  # Deploy to European regions"
    echo "  $0 -a apply -p eu-west-1 -s eu-central-1 -i c5n.xlarge -k eu-key"
    echo ""
    echo "  # Destroy infrastructure"
    echo "  $0 -a destroy -p us-east-1 -s us-west-2 -i c5n.2xlarge -k my-key"
    echo ""
    echo "  # Plan with custom VPC CIDRs"
    echo "  $0 -p ap-southeast-1 -s ap-northeast-1 -i c5n.2xlarge -k apac-key \\"
    echo "     --primary-vpc-cidr 172.16.0.0/16 --secondary-vpc-cidr 172.17.0.0/16"
}

# Function to validate required parameters
validate_params() {
    local missing_params=()
    
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

# Function to display deployment summary
show_summary() {
    echo -e "${BLUE}=== Deployment Summary ===${NC}"
    echo -e "Action:           ${GREEN}${ACTION}${NC}"
    echo -e "Primary Region:   ${GREEN}${PRIMARY_REGION}${NC}"
    echo -e "Secondary Region: ${GREEN}${SECONDARY_REGION}${NC}"
    echo -e "Instance Type:    ${GREEN}${INSTANCE_TYPE}${NC}"
    echo -e "Key Name:         ${GREEN}${KEY_NAME}${NC}"
    echo -e "Primary VPC:      ${GREEN}${PRIMARY_VPC_CIDR}${NC}"
    echo -e "Secondary VPC:    ${GREEN}${SECONDARY_VPC_CIDR}${NC}"
    echo ""
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--primary-region)
            PRIMARY_REGION="$2"
            shift 2
            ;;
        -s|--secondary-region)
            SECONDARY_REGION="$2"
            shift 2
            ;;
        -i|--instance-type)
            INSTANCE_TYPE="$2"
            shift 2
            ;;
        -k|--key-name)
            KEY_NAME="$2"
            shift 2
            ;;
        -a|--action)
            ACTION="$2"
            shift 2
            ;;
        --primary-vpc-cidr)
            PRIMARY_VPC_CIDR="$2"
            shift 2
            ;;
        --secondary-vpc-cidr)
            SECONDARY_VPC_CIDR="$2"
            shift 2
            ;;
        --primary-subnet-cidr)
            PRIMARY_SUBNET_CIDR="$2"
            shift 2
            ;;
        --secondary-subnet-cidr)
            SECONDARY_SUBNET_CIDR="$2"
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

# Validate action parameter
case $ACTION in
    plan|apply|destroy)
        ;;
    *)
        echo -e "${RED}Error: Invalid action '$ACTION'. Must be: plan, apply, or destroy${NC}"
        exit 1
        ;;
esac

# Validate required parameters
validate_params

# Show deployment summary
show_summary

# Confirm action for apply/destroy
if [[ "$ACTION" == "apply" || "$ACTION" == "destroy" ]]; then
    echo -e "${YELLOW}Warning: This will $ACTION infrastructure in AWS.${NC}"
    read -p "Are you sure you want to continue? (yes/no): " confirm
    if [[ "$confirm" != "yes" ]]; then
        echo "Operation cancelled."
        exit 0
    fi
fi

# Initialize Terraform if .terraform directory doesn't exist
if [[ ! -d ".terraform" ]]; then
    echo -e "${BLUE}Initializing Terraform...${NC}"
    terraform init
fi

# Build Terraform command with variables
TERRAFORM_CMD="terraform $ACTION"
TERRAFORM_CMD+=" -var=\"primary_region=$PRIMARY_REGION\""
TERRAFORM_CMD+=" -var=\"secondary_region=$SECONDARY_REGION\""
TERRAFORM_CMD+=" -var=\"instance_type=$INSTANCE_TYPE\""
TERRAFORM_CMD+=" -var=\"key_name=$KEY_NAME\""
TERRAFORM_CMD+=" -var=\"primary_vpc_cidr=$PRIMARY_VPC_CIDR\""
TERRAFORM_CMD+=" -var=\"secondary_vpc_cidr=$SECONDARY_VPC_CIDR\""
TERRAFORM_CMD+=" -var=\"primary_subnet_cidr=$PRIMARY_SUBNET_CIDR\""
TERRAFORM_CMD+=" -var=\"secondary_subnet_cidr=$SECONDARY_SUBNET_CIDR\""

# Add auto-approve for apply and destroy
if [[ "$ACTION" == "apply" || "$ACTION" == "destroy" ]]; then
    TERRAFORM_CMD+=" -auto-approve"
fi

# Execute Terraform command
echo -e "${BLUE}Executing: $TERRAFORM_CMD${NC}"
echo ""
eval $TERRAFORM_CMD

# Show success message
if [[ $? -eq 0 ]]; then
    case $ACTION in
        plan)
            echo -e "${GREEN}✓ Terraform plan completed successfully!${NC}"
            echo -e "Run with ${YELLOW}-a apply${NC} to deploy the infrastructure."
            ;;
        apply)
            echo -e "${GREEN}✓ Infrastructure deployed successfully!${NC}"
            echo ""
            echo -e "${BLUE}Getting deployment outputs...${NC}"
            terraform output
            ;;
        destroy)
            echo -e "${GREEN}✓ Infrastructure destroyed successfully!${NC}"
            ;;
    esac
else
    echo -e "${RED}✗ Terraform $ACTION failed!${NC}"
    exit 1
fi
