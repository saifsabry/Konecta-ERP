####################################################################
# modules/vpc/outputs.tf
####################################################################

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR Block"
  value       = aws_vpc.main.cidr_block
}

output "public_rt_id" {
  description = "Public Route Table ID"
  value       = aws_route_table.public_rt.id
}

output "private_rt_id" {
  description = "Private Route Table ID"
  value       = aws_route_table.private_rt.id
}

output "public_subnets_ids" {
  description = "Map of Public Subnet IDs"
  value       = { for k, s in aws_subnet.public_subnets : k => s.id }
}

# Private Subnet 1 & 2 for EKS Cluster
output "private_subnets_1_2_ids" {
  description = "List of Private Subnet IDs for EKS (subnets 1 & 2)"
  value       = [
    aws_subnet.private_subnets["subnet1"].id,
    aws_subnet.private_subnets["subnet2"].id
  ]
}

# Private Subnet 3 & 4 for Database
output "private_subnets_3_4_ids" {
  description = "List of Private Subnet IDs for RDS (subnets 3 & 4)"
  value       = [
    aws_subnet.private_subnets["subnet3"].id,
    aws_subnet.private_subnets["subnet4"].id
  ]
}

output "eks_cluster_sg_id" {
  description = "EKS Cluster Security Group ID"
  value       = aws_security_group.eks_cluster_sg.id
}

output "eks_nodes_sg_id" {
  description = "EKS Worker Nodes Security Group ID"
  value       = aws_security_group.eks_nodes_sg.id
}

output "rds_sg_id" {
  description = "RDS Security Group ID"
  value       = aws_security_group.rds_sg.id
}

output "bastion_public_ip" {
  description = "Bastion Host Public IP"
  value       = aws_instance.bastion.public_ip
}