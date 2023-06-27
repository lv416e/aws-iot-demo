#-------------------------------------------------------
# VPC
#-------------------------------------------------------
resource "aws_vpc" "iot_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = {
    Name = "iot-vpc"
  }
}

#-------------------------------------------------------
# Public Subnet
#-------------------------------------------------------
resource "aws_subnet" "iot_public_subnet" {
  vpc_id                  = aws_vpc.iot_vpc.id
  cidr_block              = "10.0.10.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
  tags                    = {
    Name = "iot-public-subnet"
  }
}

resource "aws_subnet" "iot_public_subnet_grafana_1" {
  vpc_id                  = aws_vpc.iot_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true
  tags                    = {
    Name = "iot-public-subnet-grafana-1"
  }
}

resource "aws_subnet" "iot_public_subnet_grafana_2" {
  vpc_id                  = aws_vpc.iot_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-2c"
  map_public_ip_on_launch = true
  tags                    = {
    Name = "iot-public-subnet-grafana-2"
  }
}

#-------------------------------------------------------
# Internet Gateway
#-------------------------------------------------------
resource "aws_internet_gateway" "iot_igw" {
  vpc_id = aws_vpc.iot_vpc.id
  tags   = {
    Name = "iot-igw"
  }
}

#-------------------------------------------------------
# Route Table
#-------------------------------------------------------
resource "aws_route_table" "iot_route_tbl" {
  vpc_id = aws_vpc.iot_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.iot_igw.id
  }
  tags = {
    Name = "iot-route-tbl"
  }
}

#-------------------------------------------------------
# Route Table Association
#-------------------------------------------------------
resource "aws_route_table_association" "iot_route_tbl_associate" {
  subnet_id      = aws_subnet.iot_public_subnet.id
  route_table_id = aws_route_table.iot_route_tbl.id
}

resource "aws_route_table_association" "iot_route_tbl_associate_grafana_1" {
  subnet_id      = aws_subnet.iot_public_subnet_grafana_1.id
  route_table_id = aws_route_table.iot_route_tbl.id
}

resource "aws_route_table_association" "iot_route_tbl_associate_grafana_2" {
  subnet_id      = aws_subnet.iot_public_subnet_grafana_2.id
  route_table_id = aws_route_table.iot_route_tbl.id
}
