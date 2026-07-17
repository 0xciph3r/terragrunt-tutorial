resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
    Tier       = "internet"
  }
}

resource "aws_subnet" "public" { 
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index] 
  map_public_ip_on_launch = true 

  tags = {
    Name        = "${var.environment}-public-subnet-${var.azs[count.index]}"
    Environment = var.environment
    Tier       = "public"
  }
}

resource "aws_subnet" "app" {
  count             = length(var.app_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.app_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.environment}-app-subnet-${var.azs[count.index]}"
    Environment = var.environment
    Tier       = "app"
  }
}

resource "aws_subnet" "data" {
  count             = length(var.data_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.data_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.environment}-data-subnet-${var.azs[count.index]}"
    Environment = var.environment
    Tier       = "data"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-public-rt"
    Environment = var.environment
    Tier       = "public"
  }

}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  count = length(var.azs)
  domain = "vpc"
  tags = {
    Name        = "${var.environment}-nat-eip-${var.azs[count.index]}"
    Environment = var.environment
    Tier       = "nat"
  }
}

resource "aws_nat_gateway" "main" {
  count = length(var.azs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name        = "${var.environment}-nat-gateway-${var.azs[count.index]}"
    Environment = var.environment
    Tier       = "nat"
  }
}


resource "aws_route_table" "app" {
  count  = length(var.azs)
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-app-rt-${var.azs[count.index]}"
    Environment = var.environment
    Tier       = "app"
  }
}

resource "aws_route" "app_nat_access" {
  count                  = length(var.azs)
  route_table_id         = aws_route_table.app[count.index].id
  destination_cidr_block = "0.0.0.0/0" 
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

resource "aws_route_table_association" "app" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.app[count.index].id
}

resource "aws_route_table" "data" {
  count  = length(var.azs)
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-data-rt-${var.azs[count.index]}"
    Environment = var.environment
    Tier       = "data"
  }
}

resource "aws_route_table_association" "data" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.data[count.index].id
  route_table_id = aws_route_table.data[count.index].id
}