resource "aws_vpc" "hackaton" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "hackaton-vpc" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.hackaton.id

  tags = { Name = "hackaton-igw" }
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.hackaton.id
  cidr_block              = cidrsubnet(aws_vpc.hackaton.cidr_block, 8, count.index)
  availability_zone       = ["us-east-1a", "us-east-1b"][count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "hackaton-public-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.hackaton.id
  cidr_block        = cidrsubnet(aws_vpc.hackaton.cidr_block, 8, count.index + 10)
  availability_zone = ["us-east-1a", "us-east-1b"][count.index]

  tags = {
    Name = "hackaton-private-${count.index + 1}"
  }
}

resource "aws_eip" "nat" {
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "hackaton-nat"
  }

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.hackaton.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = { Name = "hackaton-public-rt" }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.hackaton.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = { Name = "hackaton-private-rt" }
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


locals {
  subnet_id_map = {
    public-1  = aws_subnet.public[0].id
    public-2  = aws_subnet.public[1].id
    private-1 = aws_subnet.private[0].id
    private-2 = aws_subnet.private[1].id
  }

  subnnet_id_map_public_only = {
    public-1 = aws_subnet.public[0].id
    public-2 = aws_subnet.public[1].id
  }
}
