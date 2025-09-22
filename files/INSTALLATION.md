# 🚀 Installation Guide

This guide helps you install Terraform and set up the Cyperf CE deployment environment on your system.

## 📋 Prerequisites

- **Operating System**: Linux (Ubuntu, CentOS, RHEL, Fedora, Amazon Linux, Arch) or macOS
- **Internet Connection**: Required for downloading Terraform and AWS provider
- **AWS Account**: With appropriate permissions for EC2, VPC, and IAM operations
- **SSH Key Pair**: Created in AWS Console for EC2 access

## 🛠️ Quick Installation

### **Linux Systems**

```bash
# Download and run the installation script
curl -fsSL https://raw.githubusercontent.com/ashwinjo/cyperf-ce-deployment/main/install-terraform.sh | bash

# Or clone the repository first
git clone https://github.com/ashwinjo/cyperf-ce-deployment.git
cd cyperf-ce-deployment
./install-terraform.sh
```

### **macOS Systems**

```bash
# Download and run the installation script
curl -fsSL https://raw.githubusercontent.com/ashwinjo/cyperf-ce-deployment/main/install-terraform-macos.sh | bash

# Or clone the repository first
git clone https://github.com/ashwinjo/cyperf-ce-deployment.git
cd cyperf-ce-deployment
./install-terraform-macos.sh
```

## 🔧 Manual Installation

### **Linux (Ubuntu/Debian)**

```bash
# Update package list
sudo apt-get update

# Install dependencies
sudo apt-get install -y curl wget unzip jq

# Download and install Terraform
TERRAFORM_VERSION="1.9.0"
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
sudo mv terraform /usr/local/bin/
sudo chmod +x /usr/local/bin/terraform
rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Verify installation
terraform version
```

### **Linux (CentOS/RHEL/Fedora)**

```bash
# Install dependencies
sudo yum install -y curl wget unzip jq
# OR for newer systems:
sudo dnf install -y curl wget unzip jq

# Download and install Terraform
TERRAFORM_VERSION="1.9.0"
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
sudo mv terraform /usr/local/bin/
sudo chmod +x /usr/local/bin/terraform
rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Verify installation
terraform version
```

### **macOS (Homebrew)**

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Terraform
brew install terraform

# Verify installation
terraform version
```

### **macOS (Manual)**

```bash
# Install dependencies
brew install jq

# Download and install Terraform
TERRAFORM_VERSION="1.9.0"
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    TERRAFORM_ARCH="arm64"
else
    TERRAFORM_ARCH="amd64"
fi

curl -L -o terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_darwin_${TERRAFORM_ARCH}.zip
unzip terraform.zip
sudo mv terraform /usr/local/bin/
sudo chmod +x /usr/local/bin/terraform
rm terraform.zip

# Verify installation
terraform version
```

## 🔑 AWS Credentials Setup

### **Method 1: Environment Variables (Recommended)**

```bash
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### **Method 2: AWS CLI Configuration**

```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS credentials
aws configure
```

### **Method 3: AWS Credentials File**

```bash
# Create credentials file
mkdir -p ~/.aws
cat > ~/.aws/credentials << EOF
[default]
aws_access_key_id = your-access-key-id
aws_secret_access_key = your-secret-access-key
EOF

cat > ~/.aws/config << EOF
[default]
region = us-east-1
output = json
EOF
```

## 🧪 Verification

After installation, verify everything is working:

```bash
# Check Terraform installation
terraform version

# Check AWS credentials
aws sts get-caller-identity

# Test Terraform with AWS
terraform init
terraform plan
```

## 🚀 Quick Start

Once Terraform is installed:

```bash
# Clone the repository
git clone https://github.com/ashwinjo/cyperf-ce-deployment.git
cd cyperf-ce-deployment

# Set your AWS credentials
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"

# Initialize Terraform
terraform init

# Plan deployment
./terraform-manager.sh \
  --aws-access-key-id="your-access-key-id" \
  --aws-secret-access-key="your-secret-access-key" \
  --primary-region="us-east-1" \
  --secondary-region="us-west-2" \
  --instance-type="c5n.2xlarge" \
  --key-name="your-key-pair-name" \
  --operation="plan"
```

## 🔧 Installation Script Options

Both installation scripts support the following options:

```bash
# Install specific version
./install-terraform.sh -v 1.8.0

# Show help
./install-terraform.sh -h
```

## 🐛 Troubleshooting

### **Common Issues**

1. **Permission Denied**
   ```bash
   sudo chmod +x install-terraform.sh
   ```

2. **Terraform Not Found in PATH**
   ```bash
   echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

3. **AWS Credentials Not Working**
   ```bash
   aws sts get-caller-identity
   ```

4. **Network Issues**
   - Check firewall settings
   - Verify internet connectivity
   - Try using a VPN if behind corporate firewall

### **Supported Versions**

- **Terraform**: 1.5.0+ (tested with 1.9.0)
- **AWS Provider**: 5.0+ (automatically downloaded)
- **Operating Systems**:
  - Ubuntu 18.04+
  - CentOS 7+
  - RHEL 7+
  - Fedora 30+
  - Amazon Linux 2
  - Arch Linux
  - macOS 10.14+

## 📚 Additional Resources

- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/latest/userguide/)

## 🆘 Support

If you encounter issues:

1. Check the [troubleshooting section](#-troubleshooting)
2. Review the [API documentation](API_USAGE.md)
3. Check the [security guidelines](SECURITY.md)
4. Open an issue on GitHub

---

**Ready to deploy? Check out the [Quick Start Guide](QUICK_START.md)! 🚀**
