#!/bin/bash

# =============================================================================
# Terraform Installation Script for macOS
# =============================================================================
# This script installs Terraform on macOS using Homebrew or direct download
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

# Function to check if Homebrew is installed
check_homebrew() {
    if command -v brew &> /dev/null; then
        print_status "Homebrew detected. Using Homebrew for installation..."
        return 0
    else
        print_warning "Homebrew not found. Will use direct download method."
        return 1
    fi
}

# Function to install via Homebrew
install_via_homebrew() {
    print_status "Installing Terraform via Homebrew..."
    
    # Update Homebrew
    print_status "Updating Homebrew..."
    brew update
    
    # Install Terraform
    if [ "$TERRAFORM_VERSION" = "latest" ]; then
        brew install terraform
    else
        # Install specific version via Homebrew
        brew install hashicorp/tap/terraform@$TERRAFORM_VERSION
    fi
    
    print_success "Terraform installed via Homebrew!"
}

# Function to install via direct download
install_via_download() {
    print_status "Installing Terraform via direct download..."
    
    # Detect architecture
    ARCH=$(uname -m)
    if [ "$ARCH" = "arm64" ]; then
        TERRAFORM_ARCH="arm64"
    else
        TERRAFORM_ARCH="amd64"
    fi
    
    print_status "Detected architecture: $TERRAFORM_ARCH"
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Download Terraform
    TERRAFORM_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_darwin_${TERRAFORM_ARCH}.zip"
    print_status "Downloading Terraform from: $TERRAFORM_URL"
    
    if ! curl -L -o terraform.zip "$TERRAFORM_URL"; then
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

# Function to install dependencies
install_dependencies() {
    print_status "Installing dependencies..."
    
    # Install jq if not present
    if ! command -v jq &> /dev/null; then
        if command -v brew &> /dev/null; then
            print_status "Installing jq via Homebrew..."
            brew install jq
        else
            print_warning "jq not found and Homebrew not available. Please install jq manually."
        fi
    fi
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
    echo "Terraform Installation Script for macOS"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -v, --version VERSION    Install specific Terraform version (default: $TERRAFORM_VERSION)"
    echo "  -h, --help              Show this help message"
    echo
    echo "Installation methods:"
    echo "  - Homebrew (preferred if available)"
    echo "  - Direct download (fallback)"
    echo
    echo "Examples:"
    echo "  $0                      # Install latest version"
    echo "  $0 -v 1.8.0            # Install specific version"
    echo
}

# Main function
main() {
    echo "============================================================================="
    echo "                    Terraform Installation Script for macOS"
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
    
    # Run installation steps
    check_terraform_installed
    install_dependencies
    
    # Choose installation method
    if check_homebrew; then
        install_via_homebrew
    else
        install_via_download
    fi
    
    verify_installation
    setup_terraform_user
    show_next_steps
    
    print_success "Installation completed successfully! 🚀"
}

# Run main function
main "$@"
