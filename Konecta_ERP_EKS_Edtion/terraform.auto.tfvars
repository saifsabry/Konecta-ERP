####################################################################
# terraform.auto.tfvars - Single Region Configuration
####################################################################

region   = "eu-west-1"
vpc_name = "konecta-erp"
vpc_cidr = "10.0.0.0/16"

# Public subnets (for ALB and NAT Gateway)
public_subnets = {
  subnet1 = {
    cidr     = "10.0.1.0/24"
    az       = "eu-west-1a"
    tag_name = "public-subnet-01"
  }
  subnet2 = {
    cidr     = "10.0.2.0/24"
    az       = "eu-west-1b"
    tag_name = "public-subnet-02"
  }
}

# Private subnets (for EKS nodes and RDS)
private_subnets = {
  subnet1 = {
    cidr     = "10.0.3.0/24"
    az       = "eu-west-1a"
    tag_name = "private-subnet-01-eks"
  }
  subnet2 = {
    cidr     = "10.0.4.0/24"
    az       = "eu-west-1b"
    tag_name = "private-subnet-02-eks"
  }
  subnet3 = {
    cidr     = "10.0.5.0/24"
    az       = "eu-west-1a"
    tag_name = "private-subnet-03-rds"
  }
  subnet4 = {
    cidr     = "10.0.6.0/24"
    az       = "eu-west-1b"
    tag_name = "private-subnet-04-rds"
  }
}

# Bastion Host Configuration
instance_type     = "t3.micro"
instance_ami      = "ami-02b4e72b1732a7af7"  # Amazon Linux 2023 in eu-west-1
key_name          = "bastion-key"
bastion_host_name = "konecta-bastion"


# Security Groups
bastion_sg_name = "Bastion_SG"
rds_sg_name     = "RDS_SG"

# EKS Cluster & ECR Repositories
eks_cluster_name = "konecta-erp-cluster"
app1_repo_name   = "app1_repo"
app2_repo_name   = "app2_repo"
app3_repo_name   = "app3_repo"
app4_repo_name   = "app4_repo"
app5_repo_name   = "app5_repo"
app6_repo_name   = "app6_repo"
app7_repo_name   = "app7_repo"
app8_repo_name   = "app8_repo"
app9_repo_name   = "app9_repo"
app10_repo_name  = "app10_repo"
app11_repo_name  = "app11_repo"