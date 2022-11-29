resource "aws_vpc" "demoVPC" {
  cidr_block = "10.0.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    "name" = "demoVPC"
  }
}

resource "aws_subnet" "demoPublicSubnet" {
  vpc_id     = aws_vpc.demoVPC.id
  cidr_block = "10.0.1.0/24"

  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.demoAvailableAZ.names[0]

  tags = {
    "name" = "demoPublicSubnet"
  }
}

resource "aws_subnet" "demoPrivateSubnet" {
  vpc_id     = aws_vpc.demoVPC.id
  cidr_block = "10.0.11.0/24"

  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.demoAvailableAZ.names[1]

  tags = {
    "name" = "demoPrivateSubnet"
  }
}

resource "aws_internet_gateway" "demoIG" {
  vpc_id = aws_vpc.demoVPC.id

  tags = {
    "name" = "demoIG"
  }
}

resource "aws_route_table" "demoRT" {
  vpc_id = aws_vpc.demoVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demoIG.id
  }

  tags = {
    "name" = "demoRT"
  }
}

resource "aws_route_table_association" "demoRTAssociation" {
  route_table_id = aws_route_table.demoRT.id
  subnet_id      = aws_subnet.demoPublicSubnet.id
}
