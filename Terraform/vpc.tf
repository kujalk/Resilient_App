#VPC creation
resource "aws_vpc" "main" {
  cidr_block           = var.VPC_CIDR
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}_VPC"
  }
}

#Creating a subnet-1
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.PublicSubnet_CIDR1
  availability_zone       = var.Public_AZ1
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}_Public_Subnet1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.PublicSubnet_CIDR2
  availability_zone       = var.Public_AZ2
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}_Public_Subnet2"
  }
}

resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.PrivateSubnet_CIDR1
  availability_zone = var.Private_AZ1

  tags = {
    Name = "${var.project_name}_Private_Subnet1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.PrivateSubnet_CIDR2
  availability_zone = var.Private_AZ2

  tags = {
    Name = "${var.project_name}_Private_Subnet1"
  }
}

#Create IWG
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}_IGW"
  }
}

#Route Table creation - Public
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}_Public_RT"
  }
}

#Associate the Route table with Public Subnet
resource "aws_route_table_association" "public-route1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "public-route2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.main.id
}

resource "aws_eip" "ngw" {
}

#Create NGW
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "${var.project_name}_NGW"
  }

  depends_on = [aws_internet_gateway.main]
}

#Route Table creation - Private
resource "aws_route_table" "main2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "${var.project_name}_Private_RT"
  }
}

resource "aws_route_table_association" "private-route1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.main2.id
}

resource "aws_route_table_association" "private-route2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.main2.id
}
