#!/bin/bash

# Pre-commit Security Check Script
# Run this before pushing to GitHub

echo "🔍 Pre-Commit Security Check"
echo "=============================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ISSUES_FOUND=0

# Check for AWS Access Keys
echo -n "Checking for AWS Access Keys... "
if grep -r "AKIA[A-Z0-9]\{16\}" . --exclude-dir=.git --exclude-dir=.terraform > /dev/null 2>&1; then
    echo -e "${RED}FOUND!${NC}"
    echo "❌ AWS Access Keys detected:"
    grep -r "AKIA[A-Z0-9]\{16\}" . --exclude-dir=.git --exclude-dir=.terraform
    ISSUES_FOUND=1
else
    echo -e "${GREEN}OK${NC}"
fi

# Check for AWS Secret Keys (40 character base64-like strings)
echo -n "Checking for potential AWS Secret Keys... "
if grep -r "aws_secret_access_key.*[A-Za-z0-9/+]\{40\}" . --exclude-dir=.git --exclude-dir=.terraform > /dev/null 2>&1; then
    echo -e "${RED}FOUND!${NC}"
    echo "❌ Potential AWS Secret Keys detected:"
    grep -r "aws_secret_access_key.*[A-Za-z0-9/+]\{40\}" . --exclude-dir=.git --exclude-dir=.terraform
    ISSUES_FOUND=1
else
    echo -e "${GREEN}OK${NC}"
fi

# Check for .pem files in git
echo -n "Checking for .pem files in git... "
if git ls-files | grep "\.pem$" > /dev/null 2>&1; then
    echo -e "${RED}FOUND!${NC}"
    echo "❌ .pem files in git:"
    git ls-files | grep "\.pem$"
    ISSUES_FOUND=1
else
    echo -e "${GREEN}OK${NC}"
fi

# Check for terraform.tfvars files
echo -n "Checking for terraform.tfvars files... "
if git ls-files | grep "\.tfvars$" > /dev/null 2>&1; then
    echo -e "${YELLOW}FOUND!${NC}"
    echo "⚠️  .tfvars files in git (check they don't contain real credentials):"
    git ls-files | grep "\.tfvars$"
    echo "   Make sure these only contain example/placeholder values!"
else
    echo -e "${GREEN}OK${NC}"
fi

# Check for terraform state files
echo -n "Checking for terraform state files... "
if git ls-files | grep "terraform\.tfstate" > /dev/null 2>&1; then
    echo -e "${RED}FOUND!${NC}"
    echo "❌ Terraform state files in git:"
    git ls-files | grep "terraform\.tfstate"
    echo "   These should be in .gitignore!"
    ISSUES_FOUND=1
else
    echo -e "${GREEN}OK${NC}"
fi

# Check if .gitignore exists
echo -n "Checking for .gitignore... "
if [ -f ".gitignore" ]; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${YELLOW}MISSING${NC}"
    echo "⚠️  No .gitignore file found. Consider creating one."
fi

# Summary
echo ""
echo "=============================="
if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed! Safe to commit.${NC}"
    exit 0
else
    echo -e "${RED}❌ Security issues found! Fix before committing.${NC}"
    echo ""
    echo "Quick fixes:"
    echo "1. Remove or mask any exposed credentials"
    echo "2. Add sensitive files to .gitignore"
    echo "3. Remove committed sensitive files from git history"
    echo ""
    exit 1
fi
