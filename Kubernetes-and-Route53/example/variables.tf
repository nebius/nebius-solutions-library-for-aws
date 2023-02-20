
# ============================
# CloudIL Environment settings
# ============================

variable "cloud_id" {
  description = "Taken from the environment variable"
}

variable "folder_id" {
  description = "Taken from the environment variable"
}

variable "token" {
  description = "Taken from the environment variable"
}

variable "zone_id" {
  default = "il1-a"
}

# ========================
# AWS Environment settings
# ========================

variable "aws_region" {
  default = "eu-central-1"
} 

variable "aws_profile" {
  default = "aws"
} 

# ================
# Network settings
# ================

variable "net_name" {
  default = "kube-net"
}

variable "net_ipv4_prefix" {
  default = "10.10.0.0/16"
}

# Subnet1
variable "subnet1_priv_name" {
  default = "subnet1-priv"
}

variable "subnet1_priv_prefix" {
  default = "10.10.11.0/24"
}

variable "subnet1_pub_name" {
  default = "subnet1-pub"
}

variable "subnet1_pub_prefix" {
  default = "10.10.19.0/24"
}

# Subnet2
variable "subnet2_priv_name" {
  default = "subnet2-priv"
}

variable "subnet2_priv_prefix" {
  default = "10.10.21.0/24"
}

variable "subnet2_pub_name" {
  default = "subnet2-pub"
}

variable "subnet2_pub_prefix" {
  default = "10.10.29.0/24"
}


# ===========================
# Kubernetes cluster settings
# ===========================

variable "k8s_version" {
  default = "1.21"
}

variable "k8s_svc_ipv4_subnet" {
  description = "Subnet for k8s Services. Outside from VPC range."
  default = "172.16.10.0/24"
}

variable "ssh_pub_key" {
  description = "Path to the SSH public key file"
  default = "~/.ssh/id_rsa.pub"
}

variable "eks_name" {
  description = "AWS EKS Cluster Name"
  default = "eks"
}

variable "eks_instance_type" {
  description = "EKS Node Group Instance type"
  default = "t3.medium"
}

variable "mk8s_name" {
  description = "CloudIL Managed Service for Kubernetes Cluster Name"
  default = "mk8s"
}

variable "mk8s_sa_name" {
  description = "CloudIL Service Account name for MK8S Cluster"
  default = "mk8s-sa"
}

variable "mk8s_pod_ipv4_subnet" {
  description = "CloudIL MK8S subnet for Nodes and Pods"
  default = "10.100.0.0/16"
}

variable "k8s_whitelist" {
  type = list(any)
  default = ["0.0.0.0/0"]
  description = "Range of ip addresses which can access cluster API with kubectl etc"
}

# ====================
# Application settings
# ====================

variable "aws_domain_name" {
  default = "aws-cloudil-example.com"
  description = "Domain name for AWS Route53"
}

variable "nginx_version" {
  description = "Nginx version"
  default = "1.21.6"
}
