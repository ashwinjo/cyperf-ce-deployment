# Primary region for the server (REQUIRED - pass via -var="primary_region=us-east-1")
variable "primary_region" {
  description = "Primary AWS region for Cyperf server deployment. Must be specified via command line: -var=\"primary_region=us-east-1\""
  type        = string
  
  validation {
    condition = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.primary_region))
    error_message = "Region must be a valid AWS region format (e.g., us-east-1)."
  }
}

# Secondary region for the client (REQUIRED - pass via -var="secondary_region=us-west-2")
variable "secondary_region" {
  description = "Secondary AWS region for Cyperf client deployment. Must be specified via command line: -var=\"secondary_region=us-west-2\""
  type        = string
  
  validation {
    condition = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.secondary_region))
    error_message = "Region must be a valid AWS region format (e.g., us-west-2)."
  }
}

# Instance type for both server and client (REQUIRED - pass via -var="instance_type=c5n.2xlarge")
variable "instance_type" {
  description = "EC2 instance type for Cyperf instances. Must be specified via command line: -var=\"instance_type=c5n.2xlarge\""
  type        = string
  
  validation {
    condition = can(regex("^[a-z][0-9][a-z]?\\.[a-z0-9]+$", var.instance_type))
    error_message = "Instance type must be a valid EC2 instance type (e.g., c5n.2xlarge, m5.large)."
  }
}

# Key pair name (REQUIRED - pass via -var="key_name=your-key")
variable "key_name" {
  description = "Name of the AWS key pair to use for EC2 instances. Must be specified via command line: -var=\"key_name=your-key\""
  type        = string
}

# VPC CIDR blocks (Optional - will use defaults if not specified)
variable "primary_vpc_cidr" {
  description = "CIDR block for primary VPC. Optional: -var=\"primary_vpc_cidr=10.0.0.0/16\""
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition = can(cidrhost(var.primary_vpc_cidr, 0))
    error_message = "Primary VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "secondary_vpc_cidr" {
  description = "CIDR block for secondary VPC. Optional: -var=\"secondary_vpc_cidr=10.1.0.0/16\""
  type        = string
  default     = "10.1.0.0/16"
  
  validation {
    condition = can(cidrhost(var.secondary_vpc_cidr, 0))
    error_message = "Secondary VPC CIDR must be a valid IPv4 CIDR block."
  }
}

# Subnet CIDR blocks (Optional - will use defaults if not specified)
variable "primary_subnet_cidr" {
  description = "CIDR block for primary subnet. Optional: -var=\"primary_subnet_cidr=10.0.1.0/24\""
  type        = string
  default     = "10.0.1.0/24"
  
  validation {
    condition = can(cidrhost(var.primary_subnet_cidr, 0))
    error_message = "Primary subnet CIDR must be a valid IPv4 CIDR block."
  }
}

variable "secondary_subnet_cidr" {
  description = "CIDR block for secondary subnet. Optional: -var=\"secondary_subnet_cidr=10.1.1.0/24\""
  type        = string
  default     = "10.1.1.0/24"
  
  validation {
    condition = can(cidrhost(var.secondary_subnet_cidr, 0))
    error_message = "Secondary subnet CIDR must be a valid IPv4 CIDR block."
  }
}
