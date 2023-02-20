
module "eks" {
  source = "./eks"

  aws_profile = var.aws_profile
  aws_region = var.aws_region
  cluster_name = var.eks_name
  cluster_subnet_ids = ["${aws_subnet.subnet1_priv.id}", "${aws_subnet.subnet2_priv.id}"]
  k8s_version = var.k8s_version
  k8s_svc_ipv4_subnet = var.k8s_svc_ipv4_subnet
  eks_instance_type = var.eks_instance_type
  ssh_pub_key = var.ssh_pub_key
}
