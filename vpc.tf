resource "aws_vpc" "demoVPC" {
  cidr_block = "10.0.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    "Name" = "demoVPC"
  }
}

resource "aws_subnet" "demoPublicSubnet" {
  vpc_id     = aws_vpc.demoVPC.id
  cidr_block = "10.0.1.0/24"

  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.demoAvailableAZ.names[0]

  tags = {
    "Name" = "demoPublicSubnet"
  }
}

resource "aws_subnet" "demoPrivateSubnet" {
  vpc_id     = aws_vpc.demoVPC.id
  cidr_block = "10.0.11.0/24"

  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.demoAvailableAZ.names[1]

  tags = {
    "Name" = "demoPrivateSubnet"
  }
}

resource "aws_internet_gateway" "demoIG" {
  vpc_id = aws_vpc.demoVPC.id

  tags = {
    "Name" = "demoIG"
  }
}

resource "aws_route_table" "demoRT" {
  vpc_id = aws_vpc.demoVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demoIG.id
  }

  tags = {
    "Name" = "demoRT"
  }
}

resource "aws_route_table_association" "demoRTAssociation" {
  route_table_id = aws_route_table.demoRT.id
  subnet_id      = aws_subnet.demoPublicSubnet.id
}

resource "aws_default_security_group" "demoDefaultSG" {
  vpc_id = aws_vpc.demoVPC.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "demoDefaultSG"
  }
}
