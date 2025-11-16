####################################################################
# outputs.tf - Root Level Outputs
####################################################################

# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR Block"
  value       = module.vpc.vpc_cidr
}

output "bastion_public_ip" {
  description = "Bastion Host Public IP"
  value       = module.vpc.bastion_public_ip
}

# EKS Outputs
output "eks_cluster_id" {
  description = "EKS Cluster ID"
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster Endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_certificate_authority_data" {
  description = "EKS Cluster Certificate Authority Data"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${var.eks_cluster_name}"
}

# ECR Outputs
output "ecr_repositories" {
  description = "Map of ECR repository URLs"
  value = {
    app1  = module.eks.repo1_url
    app2  = module.eks.repo2_url
    app3  = module.eks.repo3_url
    app4  = module.eks.repo4_url
    app5  = module.eks.repo5_url
    app6  = module.eks.repo6_url
    app7  = module.eks.repo7_url
    app8  = module.eks.repo8_url
    app9  = module.eks.repo9_url
    app10 = module.eks.repo10_url
    app11 = module.eks.repo11_url
  }
}

