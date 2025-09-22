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
2. **Terraform installed** (version 1.0+)
3. **AWS Key Pair** created in both regions you plan to deploy to
4. **Appropriate AWS permissions** for EC2, VPC, and networking resources

