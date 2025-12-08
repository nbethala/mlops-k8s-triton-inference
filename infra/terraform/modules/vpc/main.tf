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
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.gpu_e2e.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    project = var.project
    owner   = var.owner
    Name    = "${var.project}-public-a"
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
  }
}
