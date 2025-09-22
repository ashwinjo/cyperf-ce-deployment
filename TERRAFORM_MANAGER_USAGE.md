# Terraform Manager Script Usage

## Make Script Executable
```bash
chmod +x terraform-manager.sh
```

## Usage Examples

### 1. Plan Deployment (Safe - No Changes Made)
```bash
./terraform-manager.sh \
  --aws-access-key-id="YOUR_AWS_ACCESS_KEY_ID" \
  --aws-secret-access-key="YOUR_AWS_SECRET_ACCESS_KEY" \
  --primary-region="us-east-1" \
  --secondary-region="us-west-2" \
  --instance-type="c5n.2xlarge" \
  --key-name="vibecode" \
  --operation="plan"
```

### 2. Apply Deployment (Creates Infrastructure)
```bash
./terraform-manager.sh \
  --aws-access-key-id="YOUR_AWS_ACCESS_KEY_ID" \
  --aws-secret-access-key="YOUR_AWS_SECRET_ACCESS_KEY" \
  --primary-region="us-east-1" \
  --secondary-region="us-west-2" \
  --instance-type="c5n.2xlarge" \
  --key-name="vibecode" \
  --operation="apply"
```

### 3. Destroy Infrastructure (Requires Explicit Confirmation)
```bash
./terraform-manager.sh \
  --aws-access-key-id="YOUR_AWS_ACCESS_KEY_ID" \
  --aws-secret-access-key="YOUR_AWS_SECRET_ACCESS_KEY" \
  --primary-region="us-east-1" \
  --secondary-region="us-west-2" \
  --instance-type="c5n.2xlarge" \
  --key-name="vibecode" \
  --operation="destroy"
```

### 4. Default Operation (Apply - if no --operation specified)
```bash
./terraform-manager.sh \
  --aws-access-key-id="YOUR_AWS_ACCESS_KEY_ID" \
  --aws-secret-access-key="YOUR_AWS_SECRET_ACCESS_KEY" \
  --primary-region="us-east-1" \
  --secondary-region="us-west-2" \
  --instance-type="c5n.2xlarge" \
  --key-name="vibecode"
```



## What Each Operation Does

### Plan Operation
1. ✅ `terraform init` - Initialize Terraform
2. ✅ `terraform plan` - Show what will be created (no changes made)

### Apply Operation  
1. ✅ `terraform init` - Initialize Terraform
2. ✅ `terraform plan` - Show what will be created
3. ✅ `terraform apply -auto-approve` - Create infrastructure
4. ✅ `terraform output` - Show connection details

### Destroy Operation
1. ✅ `terraform init` - Initialize Terraform
2. ✅ Confirmation prompt - Requires typing "yes"
3. ✅ `terraform destroy -auto-approve` - Destroy infrastructure

## Security Features

- ✅ **Parameter validation** - Ensures all required parameters are provided
- ✅ **Destroy confirmation** - Requires explicit "yes" confirmation for destroy
- ✅ **Masked credentials** - Only shows first 10 characters of access key in summary
- ✅ **Error handling** - Stops on any error with `set -e`

## Quick Reference

```bash
# Make executable (run once)
chmod +x terraform-manager.sh

# Get help
./terraform-manager.sh --help

# Your typical workflow:
./terraform-manager.sh --aws-access-key-id="YOUR_KEY" --aws-secret-access-key="YOUR_SECRET" --primary-region="us-east-1" --secondary-region="us-west-2" --instance-type="c5n.2xlarge" --key-name="vibecode" --operation="plan"

./terraform-manager.sh --aws-access-key-id="YOUR_KEY" --aws-secret-access-key="YOUR_SECRET" --primary-region="us-east-1" --secondary-region="us-west-2" --instance-type="c5n.2xlarge" --key-name="vibecode" --operation="apply"

./terraform-manager.sh --aws-access-key-id="YOUR_KEY" --aws-secret-access-key="YOUR_SECRET" --primary-region="us-east-1" --secondary-region="us-west-2" --instance-type="c5n.2xlarge" --key-name="vibecode" --operation="destroy"
```
