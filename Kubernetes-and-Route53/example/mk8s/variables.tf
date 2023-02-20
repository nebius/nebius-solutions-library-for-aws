
variable "folder_id" {
  description = "CloudIL Folder Id"
}

variable "zone_id" {
  description = "CloudIL Availability Zone (AZ)"
}

variable "mk8s_sa_name" {
  description = "Service Account Name for the MK8S cluster"
}

variable "cluster_name" {
  description = "MK8S Cluster Name"
}

variable "cluster_net_id" {
  description = "VPC/Network Id where MK8S cluster is located"
}

variable "cluster_subnet_id" {
  description = "Subnet Id where cluster Node Group will be deployed"
}

variable "cluster_subnet_prefix" {
  description = "MK8S Cluster subnet IPv4 prefix"
}

variable "k8s_version" {
  description = "MK8S Cluster version"
}

variable "k8s_svc_ipv4_subnet" {
  description = "MK8S Cluster subnet for Kubernetes Services"
}

variable "mk8s_pod_ipv4_subnet" {
  description = "Subnet for addressing MK8S worker Nodes and Pods"
}

variable "ssh_pub_key" {
  description = "Path to the SSH public key file"
}

variable "k8s_whitelist" {
  description = "Range of ip addresses which can access MK8S Cluster API with kubectl etc"
}
