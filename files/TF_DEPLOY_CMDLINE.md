# Cyperf CE - Quick Start Guide

## Method 1: Environment Variables + Terraform (Recommended)

This is the **preferred method** for deploying Cyperf CE infrastructure.

### Step 1: Set AWS Credentials
```bash
# Set credentials for current terminal session
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### Step 2: Initialize Terraform
```bash
terraform init
```

### Step 3: Plan Deployment
```bash
terraform plan \
  -var="primary_region=us-east-1" \
  -var="secondary_region=us-west-2" \
  -var="instance_type=c5n.2xlarge" \
  -var="key_name=your-key-name"
```

### Step 4: Deploy Infrastructure
```bash
terraform apply \
  -var="primary_region=us-east-1" \
  -var="secondary_region=us-west-2" \
  -var="instance_type=c5n.2xlarge" \
  -var="key_name=your-key-name"
```

### Step 5: Get Connection Info
```bash
terraform output
```

### Step 6: Clean Up (when done)
```bash
terraform destroy \
  -var="primary_region=us-east-1" \
  -var="secondary_region=us-west-2" \
  -var="instance_type=c5n.2xlarge" \
  -var="key_name=your-key-name"
```

## One-Liner Alternative

Deploy everything in a single command:

```bash
AWS_ACCESS_KEY_ID="your-access-key" \
AWS_SECRET_ACCESS_KEY="your-secret-key" \
terraform apply \
  -var="primary_region=us-east-1" \
  -var="secondary_region=us-west-2" \
  -var="instance_type=c5n.2xlarge" \
  -var="key_name=your-key-name"
```

## Required Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `primary_region` | AWS region for Cyperf server | `us-east-1` |
| `secondary_region` | AWS region for Cyperf client | `us-west-2` |
| `instance_type` | EC2 instance type | `c5n.2xlarge` |
| `key_name` | AWS key pair name | `my-key` |

## Instance Type Recommendations

| Instance Type | vCPUs | Memory | Use Case |
|---------------|-------|--------|----------|
| `c5n.large` | 2 | 5.25 GB | Development/Testing |
| `c5n.xlarge` | 4 | 10.5 GB | Small Workloads |
| `c5n.2xlarge` | 8 | 21 GB | **Standard (Recommended)** |
| `c5n.4xlarge` | 16 | 42 GB | High Performance |
| `c5n.9xlarge` | 36 | 96 GB | Maximum Performance |

## Troubleshooting

**Invalid credentials:**
```bash
# Test credentials first
aws sts get-caller-identity
```

**Key pair not found:**
```bash
# List available key pairs
aws ec2 describe-key-pairs --region us-east-1
```

**Clear credentials after use:**
```bash
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
```