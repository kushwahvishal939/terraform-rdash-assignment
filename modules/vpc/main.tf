resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_subnet" "public" {
  #explain below
  for_each = { for idx, cidr in var.public_subnet_cidrs : idx => cidr }
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = var.availability_zones[each.key % length(var.availability_zones)]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${each.key + 1}"
  }
}

resource "aws_subnet" "private" {
  for_each = { for idx, cidr in var.private_subnet_cidrs : idx => cidr }
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = var.availability_zones[each.key % length(var.availability_zones)]

  tags = {
    Name = "${var.project_name}-private-subnet-${each.key + 1}"
  }
}

resource "aws_subnet" "database" {
  for_each = { for idx, cidr in var.database_subnet_cidrs : idx => cidr }
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = var.availability_zones[each.key % length(var.availability_zones)]

  tags = {
    Name = "${var.project_name}-db-subnet-${each.key + 1}"
  }
}

resource "aws_subnet" "cache" {
  for_each = { for idx, cidr in var.cache_subnet_cidrs : idx => cidr }
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = var.availability_zones[each.key % length(var.availability_zones)]

    tags = {
      Name = "${var.project_name}-cache-subnet-${each.key + 1}"
    }
  }

resource "aws_eip" "nat" {
  count = length(var.availability_zones)
  tags = {
    Name = "${var.project_name}-nat-eip-${count.index+1}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat[0].id   
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.project_name}-nat-gw"
  }
  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "private" {
  count  = 1
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  for_each      = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[0].id
  #route_table_id = one([for i, az in var.availability_zones : aws_route_table.private[i].id if az == each.value.availability_zone])
}

resource "aws_route_table_association" "database" {
  for_each      = aws_subnet.database
  subnet_id      = each.value.id
  route_table_id = one([for i, az in var.availability_zones : aws_route_table.private[i].id if az == each.value.availability_zone]) # Using private route table
}

resource "aws_route_table_association" "cache" {
  for_each      = aws_subnet.cache
  subnet_id      = each.value.id
  route_table_id = one([for i, az in var.availability_zones : aws_route_table.private[i].id if az == each.value.availability_zone]) # Using private route table
}