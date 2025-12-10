resource "aws_vpc" "gpu_e2e" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    project = var.project
    owner   = var.owner
    Name    = "${var.project}-vpc"
  }
}

# Example: one public + one private subnet per AZ
# ================================================
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.gpu_e2e.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    project = var.project
    owner   = var.owner
    Name    = "${var.project}-public-a"

    # REQUIRED BY EKS
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.gpu_e2e.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.region}a"

  tags = {
    project = var.project
    owner   = var.owner
    Name    = "${var.project}-private-a"

    # REQUIRED BY EKS
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.gpu_e2e.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.region}b"

  tags = {
    project = var.project
    owner   = var.owner
    Name    = "${var.project}-private-b"

    # REQUIRED BY EKS
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

# Internet Gateway (IGW)
# ==============================================
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.gpu_e2e.id

  tags = {
    Name = "${var.project}-igw"
  }
}

# NAT Gateway (for private subnets to reach internet)
# ===================================================
resource "aws_eip" "nat" {
   tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "nat_gw_a" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id
}

# Route Tables
# ================================================
# Public Route Table 
# =================================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.gpu_e2e.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.project}-public-rt"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

# Private Route Table NAT
# ====================================
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.gpu_e2e.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_a.id
  }

  tags = {
    Name = "${var.project}-private-rt"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

