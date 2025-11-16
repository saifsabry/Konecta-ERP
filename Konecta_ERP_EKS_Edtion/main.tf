####################################################################
# main.tf - Single Region EKS Deployment
####################################################################

# ──────────────── VPC MODULE ────────────────
module "vpc" {
  source              = "./modules/vpc"
  region              = var.region
  vpc_name            = var.vpc_name
  vpc_cidr            = var.vpc_cidr
  public_subnets      = var.public_subnets
  private_subnets     = var.private_subnets
  bastion_sg_name     = var.bastion_sg_name
  rds_sg_name         = var.rds_sg_name
  instance_type       = var.instance_type
  instance_ami        = var.instance_ami
  bastion_host_name   = var.bastion_host_name
  key_name            = var.key_name
  eks_cluster_name    = var.eks_cluster_name
}

# ──────────────── EKS MODULE ────────────────
module "eks" {
  source            = "./modules/eks"
  cluster_name      = var.eks_cluster_name
  private_subnets   = module.vpc.private_subnets_1_2_ids
  eks_cluster_sg_id = module.vpc.eks_cluster_sg_id
  
  # ECR Repository names
  app1_repo_name    = var.app1_repo_name
  app2_repo_name    = var.app2_repo_name
  app3_repo_name    = var.app3_repo_name
  app4_repo_name    = var.app4_repo_name
  app5_repo_name    = var.app5_repo_name
  app6_repo_name    = var.app6_repo_name
  app7_repo_name    = var.app7_repo_name
  app8_repo_name    = var.app8_repo_name
  app9_repo_name    = var.app9_repo_name
  app10_repo_name   = var.app10_repo_name
  app11_repo_name   = var.app11_repo_name

  depends_on = [module.vpc]
}