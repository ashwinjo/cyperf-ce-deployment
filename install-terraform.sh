#!/bin/bash

# =============================================================================
# Terraform Installation Script for Linux
# =============================================================================
# This script installs Terraform on various Linux distributions
# Supports: Ubuntu/Debian, CentOS/RHEL/Fedora, Amazon Linux, Arch Linux
# =============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Terraform version to install (latest stable)
TERRAFORM_VERSION="1.9.0"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to detect Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION=$VERSION_ID
    elif [ -f /etc/redhat-release ]; then
        DISTRO="rhel"
    elif [ -f /etc/debian_version ]; then
        DISTRO="debian"
    else
        DISTRO="unknown"
    fi
    
    print_status "Detected distribution: $DISTRO"
}

# Function to check if Terraform is already installed
check_terraform_installed() {
    if command -v terraform &> /dev/null; then
        CURRENT_VERSION=$(terraform version -json | jq -r '.terraform_version' 2>/dev/null || terraform version | head -n1 | cut -d' ' -f2 | cut -d'v' -f2)
        print_warning "Terraform is already installed: version $CURRENT_VERSION"
        
        if [ "$CURRENT_VERSION" = "$TERRAFORM_VERSION" ]; then
            print_success "Terraform $TERRAFORM_VERSION is already installed and up to date!"
            exit 0
        else
            print_warning "Current version ($CURRENT_VERSION) differs from target version ($TERRAFORM_VERSION)"
            read -p "Do you want to update to version $TERRAFORM_VERSION? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_status "Installation cancelled by user"
                exit 0
            fi
        fi
    fi
}

# Function to install dependencies
install_dependencies() {
    print_status "Installing dependencies..."
    
    case $DISTRO in
        ubuntu|debian)
            sudo apt-get update
            sudo apt-get install -y curl wget unzip jq
            ;;
        centos|rhel|fedora)
            if command -v dnf &> /dev/null; then
                sudo dnf install -y curl wget unzip jq
            else
                sudo yum install -y curl wget unzip jq
            fi
            ;;
        amazon)
            sudo yum update -y
            sudo yum install -y curl wget unzip jq
            ;;
        arch|manjaro)
            sudo pacman -S --noconfirm curl wget unzip jq
            ;;
        *)
            print_warning "Unknown distribution. Please install curl, wget, unzip, and jq manually"
            ;;
    esac
}

# Function to install Terraform
install_terraform() {
    print_status "Installing Terraform $TERRAFORM_VERSION..."
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Download Terraform
    TERRAFORM_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
    print_status "Downloading Terraform from: $TERRAFORM_URL"
    
    if ! wget -q "$TERRAFORM_URL" -O terraform.zip; then
        print_error "Failed to download Terraform. Please check your internet connection."
        exit 1
    fi
    
    # Verify download
    if [ ! -f terraform.zip ]; then
        print_error "Downloaded file not found"
        exit 1
    fi
    
    # Extract and install
    print_status "Extracting Terraform..."
    unzip -q terraform.zip
    
    # Install to /usr/local/bin
    print_status "Installing Terraform to /usr/local/bin..."
    sudo mv terraform /usr/local/bin/
    sudo chmod +x /usr/local/bin/terraform
    
    # Cleanup
    cd /
    rm -rf "$TEMP_DIR"
    
    print_success "Terraform $TERRAFORM_VERSION installed successfully!"
}

# Function to verify installation
verify_installation() {
    print_status "Verifying installation..."
    
    if command -v terraform &> /dev/null; then
        INSTALLED_VERSION=$(terraform version -json | jq -r '.terraform_version' 2>/dev/null || terraform version | head -n1 | cut -d' ' -f2 | cut -d'v' -f2)
        print_success "Terraform $INSTALLED_VERSION is installed and working!"
        
        # Show terraform version
        echo
        print_status "Terraform version information:"
        terraform version
    else
        print_error "Terraform installation failed or not found in PATH"
        exit 1
    fi
}

# Function to create terraform user directory
setup_terraform_user() {
    print_status "Setting up Terraform user directory..."
    
    # Create .terraform.d directory for plugins
    mkdir -p ~/.terraform.d/plugins
    
    # Create terraform working directory
    mkdir -p ~/terraform-projects
    
    print_success "Terraform user directory setup complete!"
    print_status "Terraform plugins will be stored in: ~/.terraform.d/plugins"
    print_status "Suggested working directory: ~/terraform-projects"
}

# Function to show next steps
show_next_steps() {
    echo
    print_success "🎉 Terraform installation complete!"
    echo
    print_status "Next steps:"
    echo "1. Configure AWS credentials:"
    echo "   export AWS_ACCESS_KEY_ID=\"your-access-key\""
    echo "   export AWS_SECRET_ACCESS_KEY=\"your-secret-key\""
    echo
    echo "2. Or use AWS CLI:"
    echo "   aws configure"
    echo
    echo "3. Clone and use this repository:"
    echo "   git clone https://github.com/ashwinjo/cyperf-ce-deployment.git"
    echo "   cd cyperf-ce-deployment"
    echo
    echo "4. Initialize Terraform:"
    echo "   terraform init"
    echo
    echo "5. Use the deployment script:"
    echo "   ./terraform-manager.sh --help"
    echo
    print_status "For more information, see the documentation in the repository."
}

# Function to show help
show_help() {
    echo "Terraform Installation Script for Linux"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -v, --version VERSION    Install specific Terraform version (default: $TERRAFORM_VERSION)"
    echo "  -h, --help              Show this help message"
    echo
    echo "Supported distributions:"
    echo "  - Ubuntu/Debian"
    echo "  - CentOS/RHEL/Fedora"
    echo "  - Amazon Linux"
    echo "  - Arch Linux/Manjaro"
    echo
    echo "Examples:"
    echo "  $0                      # Install latest version"
    echo "  $0 -v 1.8.0            # Install specific version"
    echo
}

# Main function
main() {
    echo "============================================================================="
    echo "                    Terraform Installation Script"
    echo "============================================================================="
    echo
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--version)
                TERRAFORM_VERSION="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    print_status "Installing Terraform version: $TERRAFORM_VERSION"
    
    # Check if running as root
    if [ "$EUID" -eq 0 ]; then
        print_warning "Running as root. This is not recommended for security reasons."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Installation cancelled"
            exit 0
        fi
    fi
    
    # Check if sudo is available
    if ! command -v sudo &> /dev/null; then
        print_error "sudo is required but not installed. Please install sudo first."
        exit 1
    fi
    
    # Run installation steps
    detect_distro
    check_terraform_installed
    install_dependencies
    install_terraform
    verify_installation
    setup_terraform_user
    show_next_steps
    
    print_success "Installation completed successfully! 🚀"
}

# Run main function
main "$@"
