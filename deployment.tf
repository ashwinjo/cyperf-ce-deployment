terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Data sources for availability zones
data "aws_availability_zones" "primary" {
  provider = aws.primary
  state    = "available"
}

data "aws_availability_zones" "secondary" {
  provider = aws.secondary
  state    = "available"
}

provider "aws" {
  region = var.primary_region
  alias  = "primary"
}

provider "aws" {
  region = var.secondary_region
  alias  = "secondary"
}

# Temporary providers for destroying orphaned resources
provider "aws" {
  region = var.primary_region
  alias  = "us-east-1"
}

provider "aws" {
  region = var.secondary_region
  alias  = "us-west-2"
}

##############################
# VPCs, Subnets, and IGWs
##############################

resource "aws_vpc" "primary_vpc" {
  provider   = aws.primary
  cidr_block = var.primary_vpc_cidr
  tags = {
    Name = "${var.primary_region}-vpc"
  }
}

resource "aws_subnet" "primary_subnet" {
  provider          = aws.primary
  vpc_id            = aws_vpc.primary_vpc.id
  cidr_block        = var.primary_subnet_cidr
  availability_zone = data.aws_availability_zones.primary.names[0]
  tags = {
    Name = "${var.primary_region}-subnet"
  }
}

resource "aws_internet_gateway" "primary_igw" {
  provider = aws.primary
  vpc_id = aws_vpc.primary_vpc.id
  tags = {
    Name = "${var.primary_region}-igw"
  }
}

resource "aws_route_table" "primary_rt" {
  provider = aws.primary
  vpc_id = aws_vpc.primary_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.primary_igw.id
  }
  tags = {
    Name = "${var.primary_region}-rt"
  }
}

resource "aws_route_table_association" "primary_rta" {
  provider       = aws.primary
  subnet_id      = aws_subnet.primary_subnet.id
  route_table_id = aws_route_table.primary_rt.id
}

resource "aws_vpc" "secondary_vpc" {
  provider   = aws.secondary
  cidr_block = var.secondary_vpc_cidr
  tags = {
    Name = "${var.secondary_region}-vpc"
  }
}

resource "aws_subnet" "secondary_subnet" {
  provider          = aws.secondary
  vpc_id            = aws_vpc.secondary_vpc.id
  cidr_block        = var.secondary_subnet_cidr
  availability_zone = data.aws_availability_zones.secondary.names[0]
  tags = {
    Name = "${var.secondary_region}-subnet"
  }
}

resource "aws_internet_gateway" "secondary_igw" {
  provider = aws.secondary
  vpc_id = aws_vpc.secondary_vpc.id
  tags = {
    Name = "${var.secondary_region}-igw"
  }
}

resource "aws_route_table" "secondary_rt" {
  provider = aws.secondary
  vpc_id = aws_vpc.secondary_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.secondary_igw.id
  }
  tags = {
    Name = "${var.secondary_region}-rt"
  }
}

resource "aws_route_table_association" "secondary_rta" {
  provider       = aws.secondary
  subnet_id      = aws_subnet.secondary_subnet.id
  route_table_id = aws_route_table.secondary_rt.id
}

##############################
# VPC Peering and Routing
##############################

resource "aws_vpc_peering_connection" "primary_to_secondary" {
  provider      = aws.primary
  vpc_id        = aws_vpc.primary_vpc.id
  peer_vpc_id   = aws_vpc.secondary_vpc.id
  peer_region   = var.secondary_region
  auto_accept   = false
  tags = {
    Name = "primary-to-secondary-peering"
  }
}

resource "aws_vpc_peering_connection_accepter" "secondary_accept" {
  provider                  = aws.secondary
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id
  auto_accept               = true
  tags = {
    Name = "secondary-accept-peering"
  }
}

resource "aws_route" "primary_to_secondary_route" {
  provider                  = aws.primary
  route_table_id            = aws_route_table.primary_rt.id
  destination_cidr_block    = aws_vpc.secondary_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id
}

resource "aws_route" "secondary_to_primary_route" {
  provider                  = aws.secondary
  route_table_id            = aws_route_table.secondary_rt.id
  destination_cidr_block    = aws_vpc.primary_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id
}

##############################
# AMI Lookup
##############################

data "aws_ami" "ubuntu_server" {
  provider = aws.primary
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "ubuntu_client" {
  provider = aws.secondary
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

##############################
# Security Groups
##############################

resource "aws_security_group" "cyperf_server_sg" {
  provider = aws.primary
  name        = "cyperf-server-sg"
  vpc_id      = aws_vpc.primary_vpc.id
  description = "SG for Cyperf Server"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "App traffic"
  }
  
  ingress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow all inbound IPv4 traffic"
}

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound"
  }
}

resource "aws_security_group" "cyperf_client_sg" {
  provider = aws.secondary
  name        = "cyperf-client-sg"
  vpc_id      = aws_vpc.secondary_vpc.id
  description = "SG for Cyperf Client"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  ingress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow all inbound IPv4 traffic"
}

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "App traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound"
  }
}

##############################
# EC2 Instances
##############################

resource "aws_instance" "cyperf_server" {
  provider                    = aws.primary
  ami                        = data.aws_ami.ubuntu_server.id
  instance_type              = var.instance_type
  subnet_id                  = aws_subnet.primary_subnet.id
  key_name                   = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids     = [aws_security_group.cyperf_server_sg.id]
  user_data                  = file("userdata.sh")
  tags = {
    Name = "Cyperf-Server-${var.primary_region}"
  }
}

resource "aws_instance" "cyperf_client" {
  provider                    = aws.secondary
  ami                        = data.aws_ami.ubuntu_client.id
  instance_type              = var.instance_type
  subnet_id                  = aws_subnet.secondary_subnet.id
  key_name                   = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids     = [aws_security_group.cyperf_client_sg.id]
  user_data                  = file("userdata.sh")
  tags = {
    Name = "Cyperf-Client-${var.secondary_region}"
  }
}

