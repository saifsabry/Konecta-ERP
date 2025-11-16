####################################################################
# variables.tf - Single Region Variables
####################################################################

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_name" {
  description = "VPC Name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR Block"
  type        = string
}

# Public subnets
variable "public_subnets" {
  description = "Public subnet definitions with CIDRs, AZs and names"
  type = map(object({
    cidr     = string
    az       = string
    tag_name = string
  }))
}

# Private subnets 
variable "private_subnets" {
  description = "Private subnet definitions with CIDRs, AZs and names"
  type = map(object({
    cidr     = string
    az       = string
    tag_name = string
  }))
}

# Security Groups
variable "bastion_sg_name" {
  description = "Bastion Security Group Name"
  type        = string
}

variable "rds_sg_name" {
  description = "RDS Security Group Name"
  type        = string
}

# Bastion Host
variable "instance_type" {
  description = "Bastion Instance Type"
  type        = string
}

variable "instance_ami" {
  description = "Bastion AMI ID"
  type        = string
}

variable "bastion_host_name" {
  description = "Bastion Host Name"
  type        = string
}

variable "key_name" {
  description = "SSH Key Pair Name"
  type        = string
}

# EKS Cluster
variable "eks_cluster_name" {
  description = "EKS Cluster Name"
  type        = string
}

# ECR Repositories
variable "app1_repo_name" {
  type = string
}

variable "app2_repo_name" {
  type = string
}

variable "app3_repo_name" {
  type = string
}

variable "app4_repo_name" {
  type = string
}

variable "app5_repo_name" {
  type = string
}

variable "app6_repo_name" {
  type = string
}

variable "app7_repo_name" {
  type = string
}

variable "app8_repo_name" {
  type = string
}

variable "app9_repo_name" {
  type = string
}

variable "app10_repo_name" {
  type = string
}

variable "app11_repo_name" {
  type = string
}