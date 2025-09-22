# Cyperf CE Deployment

This Terraform configuration deploys Cyperf Community Edition infrastructure across two AWS regions with VPC peering for network performance testing.

## Architecture

- **Primary Region**: Cyperf Server (configurable region)
- **Secondary Region**: Cyperf Client (configurable region)
- **VPC Peering**: Cross-region connectivity between server and client
- **Security Groups**: Allow all traffic for performance testing
- **Public IPs**: Both instances have public IPs for management access

## Prerequisites

1. **AWS Access Key and Secret Key** (no AWS CLI configuration needed)
2. **Terraform installed** (version 1.0+) - [Installation Guide](INSTALLATION.md)
3. **AWS Key Pair** created in both regions you plan to deploy to
4. **Appropriate AWS permissions** for EC2, VPC, and networking resources

## 🚀 Quick Installation

### **Install Terraform (Linux/macOS)**

```bash
# Linux
curl -fsSL https://raw.githubusercontent.com/ashwinjo/cyperf-ce-deployment/main/install-terraform.sh | bash

# macOS
curl -fsSL https://raw.githubusercontent.com/ashwinjo/cyperf-ce-deployment/main/install-terraform-macos.sh | bash
```

### **Clone and Deploy**

```bash
git clone https://github.com/ashwinjo/cyperf-ce-deployment.git
cd cyperf-ce-deployment

# Set AWS credentials
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"

# Deploy infrastructure
./terraform-manager.sh \
  --aws-access-key-id="your-access-key-id" \
  --aws-secret-access-key="your-secret-access-key" \
  --primary-region="us-east-1" \
  --secondary-region="us-west-2" \
  --instance-type="c5n.2xlarge" \
  --key-name="your-key-pair-name" \
  --operation="apply"
```

## 📚 Documentation

- **[Installation Guide](INSTALLATION.md)** - Complete setup instructions for Linux and macOS
- **[API Usage](API_USAGE.md)** - Flask API endpoints and examples
- **[Terraform Manager](TERRAFORM_MANAGER_USAGE.md)** - Command-line script usage
- **[Docker n8n Setup](DOCKER_N8N_SETUP.md)** - n8n workflow automation
- **[Security Guidelines](SECURITY.md)** - Best practices and security measures
- **[Quick Start](QUICK_START.md)** - Get up and running quickly

## 🛠️ Installation Scripts

This repository includes automated installation scripts for Terraform:

### **Linux Installation Script**
```bash
# Features:
# - Supports Ubuntu, CentOS, RHEL, Fedora, Amazon Linux, Arch
# - Installs dependencies (curl, wget, unzip, jq)
# - Downloads and installs Terraform
# - Sets up user directories
# - Provides next steps guidance

./install-terraform.sh --help
```

### **macOS Installation Script**
```bash
# Features:
# - Uses Homebrew if available (preferred)
# - Falls back to direct download
# - Supports both Intel and Apple Silicon
# - Installs dependencies
# - Sets up user directories

./install-terraform-macos.sh --help
```

### **Script Options**
- `-v, --version VERSION` - Install specific Terraform version
- `-h, --help` - Show help message

