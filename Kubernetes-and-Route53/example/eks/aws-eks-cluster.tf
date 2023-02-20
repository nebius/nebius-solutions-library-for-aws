
# ====================================
# IAM Roles & Policies for EKS Cluster
# ====================================
resource "aws_iam_role" "cluster" {
  name = "eks-cluster"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "cluster_eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = "${aws_iam_role.cluster.name}"
}


# ====================
# Creating EKS Cluster
# ====================

resource "aws_eks_cluster" "cluster" {
  name = var.cluster_name
  version = var.k8s_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids = var.cluster_subnet_ids
    endpoint_private_access = true
    endpoint_public_access = true
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.k8s_svc_ipv4_subnet
    ip_family = "ipv4"
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_eks_cluster_policy
  ]
}

# =======
# Outputs
# =======

output "cluster_id" {
  value = aws_eks_cluster.cluster.id
}

output "eks_endpoint" {
  value = "${aws_eks_cluster.cluster.endpoint}"
}
