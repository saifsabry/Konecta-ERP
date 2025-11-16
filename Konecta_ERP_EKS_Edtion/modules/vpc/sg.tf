####################################################################
# modules/vpc/sg.tf - Security Groups for EKS
####################################################################

####################################################################
# Bastion Host Security Group
####################################################################
resource "aws_security_group" "bastion_sg" {
  name        = var.bastion_sg_name
  description = "Allow SSH from trusted IPs"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH access from admin IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["154.182.122.37/32"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.bastion_sg_name
  }
}

####################################################################
# EKS Cluster Security Group
####################################################################
resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.eks_cluster_name}-cluster-sg"
  description = "Security group for EKS cluster control plane"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                            = "${var.eks_cluster_name}-cluster-sg"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
}

# Allow worker nodes to communicate with cluster API
resource "aws_security_group_rule" "cluster_ingress_workstation_https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  source_security_group_id = aws_security_group.eks_nodes_sg.id
  to_port                  = 443
  type                     = "ingress"
}

####################################################################
# EKS Worker Nodes Security Group
####################################################################
resource "aws_security_group" "eks_nodes_sg" {
  name        = "${var.eks_cluster_name}-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                            = "${var.eks_cluster_name}-nodes-sg"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
}

# Allow nodes to communicate with each other
resource "aws_security_group_rule" "nodes_internal" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_nodes_sg.id
  source_security_group_id = aws_security_group.eks_nodes_sg.id
  to_port                  = 65535
  type                     = "ingress"
}

# Allow worker Kubelets and pods to receive communication from the cluster control plane
resource "aws_security_group_rule" "nodes_cluster_inbound" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes_sg.id
  source_security_group_id = aws_security_group.eks_cluster_sg.id
  to_port                  = 65535
  type                     = "ingress"
}

# Allow pods running extension API servers on port 443 to receive communication from cluster control plane
resource "aws_security_group_rule" "cluster_https_worker_ingress" {
  description              = "Allow pods running extension API servers on port 443"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes_sg.id
  source_security_group_id = aws_security_group.eks_cluster_sg.id
  to_port                  = 443
  type                     = "ingress"
}

# Allow SSH from bastion
resource "aws_security_group_rule" "nodes_ssh_bastion" {
  description              = "Allow SSH from bastion"
  from_port                = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes_sg.id
  source_security_group_id = aws_security_group.bastion_sg.id
  to_port                  = 22
  type                     = "ingress"
}

####################################################################
# RDS Security Group
####################################################################
resource "aws_security_group" "rds_sg" {
  name        = var.rds_sg_name
  description = "Allow PostgreSQL from EKS nodes only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL from EKS nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes_sg.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.rds_sg_name
  }
}