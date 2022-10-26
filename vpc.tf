resource "aws_vpc" "eks_vpc" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "eks-vpc"
  }
}

# gateways
resource "aws_internet_gateway" "eks_vpc_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks-vpc-igw"
  }
}

resource "aws_nat_gateway" "eks_nat_gw" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.eks_nat_gw_eip[count.index].id
  subnet_id     = aws_subnet.eks_public_subnet[count.index].id
  depends_on    = [aws_internet_gateway.eks_vpc_igw]

  tags = {
    Name = "eks-nat-gw"
  }
}

# subnets
resource "aws_subnet" "eks_public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zones[count.index]

  tags = {
    Name                     = "eks-public-subnet"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_subnet" "eks_private_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]


  tags = {
    Name                              = "eks-private-subnet"
    "kubernetes.io/role/internal-elb" = 1
  }
}

# EIPs
resource "aws_eip" "eks_nat_gw_eip" {
  count            = length(var.public_subnet_cidrs)
  public_ipv4_pool = "amazon"
  vpc              = true
}

# Route tables
resource "aws_route_table" "eks_public_subnet_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_vpc_igw.id
  }

  tags = {
    Name    = "eks-public-subnet-rt"
    Network = "public"
  }
}

resource "aws_route_table_association" "eks_public_subnet" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.eks_public_subnet[count.index].id
  route_table_id = aws_route_table.eks_public_subnet_rt.id
}

resource "aws_route_table" "eks_private_subnet_rt" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_nat_gw[count.index].id
  }

  tags = {
    Name    = "eks-private-subnet-rt"
    Network = "private"
  }
}

resource "aws_route_table_association" "eks_private_subnet" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.eks_private_subnet[count.index].id
  route_table_id = aws_route_table.eks_private_subnet_rt[count.index].id
}

# security groups
resource "aws_security_group" "eks_control_plane_security_group" {
  name        = "eks_control_plane_security_groupsts:AssumeRole"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.eks_vpc.id
  tags = {
    Name = "eks-control-plane-security-group"
  }
}
# TODO: First see the output and then decide if we want to use this
# resource "aws_security_group_rule" "eks_control_plane_security_group" {
#   type      = "ingress"
#   from_port = 0
#   to_port   = 0
#   protocol  = "-1"
#   # source_security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
#   source_security_group_id = module.eks_cluster.vpc_config[0].cluster_security_group_id
#   security_group_id        = aws_security_group.eks_control_plane_security_group.id 
# }

#vpc endpoints


resource "aws_vpc_endpoint" "vpc-interface-endpoints" {
  count = length(var.vpce_services.interface)
  policy = jsonencode(
    {
      Statement = [
        {
          Action    = "*"
          Effect    = "Allow"
          Principal = "*"
          Resource  = "*"
        },
      ]
    }
  )
  private_dns_enabled = true
  security_group_ids = [
    # TODO: pass by ref maybe only applicable for customized managed nodes or self managed nodes
    # Some examples are launch template based customization
    #aws_security_group.allnodes-sg.id, 
    aws_security_group.eks_control_plane_security_group.id
  ]
  service_name      = format("com.amazonaws.%s.${var.vpce_services.interface[count.index]}", data.aws_region.current.name)
  subnet_ids        = aws_subnet.eks_private_subnet[*].id
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.eks_vpc.id

  tags = {}
}

resource "aws_vpc_endpoint" "vpc-gateway-endpoints" {
  count = length(var.vpce_services.gateway)
  policy = jsonencode(
    {
      Statement = [
        {
          Action    = "*"
          Effect    = "Allow"
          Principal = "*"
          Resource  = "*"
        },
      ]
    }
  )
  private_dns_enabled = false
  route_table_ids     = aws_route_table.eks_private_subnet_rt[*].id
  security_group_ids  = []
  service_name        = format("com.amazonaws.%s.${var.vpce_services.gateway[count.index]}", data.aws_region.current.name)
  subnet_ids          = []
  vpc_endpoint_type   = "Gateway"
  vpc_id              = aws_vpc.eks_vpc.id

  tags = {}
}