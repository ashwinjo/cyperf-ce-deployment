terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}

provider "aws" {
  region = "us-west-2"
  alias  = "us-west-2"
}

##############################
# VPCs, Subnets, and IGWs
##############################

resource "aws_vpc" "east_vpc" {
  provider = aws.us-east-1
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "east-vpc"
  }
}

resource "aws_subnet" "east_subnet" {
  provider = aws.us-east-1
  vpc_id     = aws_vpc.east_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "east-subnet"
  }
}

resource "aws_internet_gateway" "east_igw" {
  provider = aws.us-east-1
  vpc_id = aws_vpc.east_vpc.id
  tags = {
    Name = "east-igw"
  }
}

resource "aws_route_table" "east_rt" {
  provider = aws.us-east-1
  vpc_id = aws_vpc.east_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.east_igw.id
  }
  tags = {
    Name = "east-rt"
  }
}

resource "aws_route_table_association" "east_rta" {
  provider       = aws.us-east-1
  subnet_id      = aws_subnet.east_subnet.id
  route_table_id = aws_route_table.east_rt.id
}

resource "aws_vpc" "west_vpc" {
  provider = aws.us-west-2
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "west-vpc"
  }
}

resource "aws_subnet" "west_subnet" {
  provider = aws.us-west-2
  vpc_id     = aws_vpc.west_vpc.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "us-west-2a"
  tags = {
    Name = "west-subnet"
  }
}

resource "aws_internet_gateway" "west_igw" {
  provider = aws.us-west-2
  vpc_id = aws_vpc.west_vpc.id
  tags = {
    Name = "west-igw"
  }
}

resource "aws_route_table" "west_rt" {
  provider = aws.us-west-2
  vpc_id = aws_vpc.west_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.west_igw.id
  }
  tags = {
    Name = "west-rt"
  }
}

resource "aws_route_table_association" "west_rta" {
  provider       = aws.us-west-2
  subnet_id      = aws_subnet.west_subnet.id
  route_table_id = aws_route_table.west_rt.id
}

##############################
# VPC Peering and Routing
##############################

resource "aws_vpc_peering_connection" "east_to_west" {
  provider      = aws.us-east-1
  vpc_id        = aws_vpc.east_vpc.id
  peer_vpc_id   = aws_vpc.west_vpc.id
  peer_region   = "us-west-2"
  auto_accept   = false
  tags = {
    Name = "east-to-west-peering"
  }
}

resource "aws_vpc_peering_connection_accepter" "west_accept" {
  provider                  = aws.us-west-2
  vpc_peering_connection_id = aws_vpc_peering_connection.east_to_west.id
  auto_accept               = true
  tags = {
    Name = "west-accept-peering"
  }
}

resource "aws_route" "east_to_west_route" {
  provider                  = aws.us-east-1
  route_table_id            = aws_route_table.east_rt.id
  destination_cidr_block    = aws_vpc.west_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.east_to_west.id
}

resource "aws_route" "west_to_east_route" {
  provider                  = aws.us-west-2
  route_table_id            = aws_route_table.west_rt.id
  destination_cidr_block    = aws_vpc.east_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.east_to_west.id
}

##############################
# AMI Lookup
##############################

data "aws_ami" "ubuntu_server" {
  provider = aws.us-east-1
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
  provider = aws.us-west-2
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
  provider = aws.us-east-1
  name        = "cyperf-server-sg"
  vpc_id      = aws_vpc.east_vpc.id
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
  provider = aws.us-west-2
  name        = "cyperf-client-sg"
  vpc_id      = aws_vpc.west_vpc.id
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
  provider = aws.us-east-1
  ami           = data.aws_ami.ubuntu_server.id
  instance_type = "c5n.2xlarge"
  subnet_id     = aws_subnet.east_subnet.id
  key_name      = "vibecode"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.cyperf_server_sg.id]
  user_data = file("userdata.sh")
  tags = {
    Name = "Cyperf-Server"
  }
}

resource "aws_instance" "cyperf_client" {
  provider = aws.us-west-2
  ami           = data.aws_ami.ubuntu_client.id
  instance_type = "c5n.2xlarge"
  subnet_id     = aws_subnet.west_subnet.id
  key_name      = "vibecode"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.cyperf_client_sg.id]
  user_data = file("userdata.sh")

  tags = {
    Name = "Cyperf-Client"
  }
}

output "cyperf_server_ip" {
  value = aws_instance.cyperf_server.public_ip
}

output "cyperf_client_ip" {
  value = aws_instance.cyperf_client.public_ip
}
