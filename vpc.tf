resource "aws_vpc" "eks_test_vpc" {
  cidr_block = "192.168.0.0/16"

  tags = {
    Name = "eks-test-vpc"
  }
}

# gateways
resource "aws_internet_gateway" "eks_test_vpc_igw" {
  vpc_id = aws_vpc.eks_test_vpc.id

  tags = {
    Name = "eks-test-vpc-igw"
  }
}

resource "aws_nat_gateway" "eks_test_nat_gw" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.eks_test_nat_gw_eip[count.index].id
  subnet_id     = aws_subnet.eks_test_public_subnet[count.index].id
  depends_on    = [aws_internet_gateway.eks_test_vpc_igw]

  tags = {
    Name = "eks-test-nat-gw"
  }
}

# subnets
resource "aws_subnet" "eks_test_public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.eks_test_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zones[count.index]

  tags = {
    Name                     = "eks-test-public-subnet"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_subnet" "eks_test_private_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.eks_test_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]


  tags = {
    Name                              = "eks-test-private-subnet"
    "kubernetes.io/role/internal-elb" = 1
  }
}

# EIPs
resource "aws_eip" "eks_test_nat_gw_eip" {
  count            = length(var.public_subnet_cidrs)
  public_ipv4_pool = "amazon"
  vpc              = true
}

# Route tables
resource "aws_route_table" "eks_test_public_subnet_rt" {
  vpc_id = aws_vpc.eks_test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_test_vpc_igw.id
  }

  tags = {
    Name    = "eks-test-public-subnet-rt"
    Network = "public"
  }
}

resource "aws_route_table_association" "eks_test_public_subnet" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.eks_test_public_subnet[count.index].id
  route_table_id = aws_route_table.eks_test_public_subnet_rt.id
}

resource "aws_route_table" "eks_test_private_subnet_rt" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.eks_test_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_test_nat_gw[count.index].id
  }

  tags = {
    Name    = "eks-test-private-subnet-rt"
    Network = "private"
  }
}

resource "aws_route_table_association" "eks_test_private_subnet" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.eks_test_private_subnet[count.index].id
  route_table_id = aws_route_table.eks_test_private_subnet_rt[count.index].id
}

# security groups
resource "aws_security_group" "eks_test_control_plane_security_group" {
  name        = "eks_test_control_plane_security_groupsts:AssumeRole"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.eks_test_vpc.id
  tags = {
    Name = "eks-test-control-plane-security-group"
  }
}