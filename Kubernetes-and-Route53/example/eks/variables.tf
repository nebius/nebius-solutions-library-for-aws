# ========================
# AWS Environment settings
# ========================

variable "aws_region" {
  description = "AWS Region"
} 

variable "aws_profile" {
  description = "AWS CLI Profile name"
} 

# ===========================
# Kubernetes cluster settings
# ===========================

variable "cluster_name" {
  description = "AWS EKS Cluster Name"
}

variable "k8s_version" {
  description = "AWS EKS Cluster Version"
}

variable "cluster_subnet_ids" {
  type = list
  description = "EKS Cluster Subnets list"
}

variable "k8s_svc_ipv4_subnet" {
  description = "Subnet for k8s Services. Outside of VPC IPv4 range."
}

variable "eks_instance_type" {
  description = "EKS Node Group instance type"
}

variable "ssh_pub_key" {
  description = "Path to the SSH public key file"
}
