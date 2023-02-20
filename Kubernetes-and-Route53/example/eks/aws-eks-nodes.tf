
# ==================================================
# IAM Roles & Policies for Node Group (worker nodes)
# ==================================================
resource "aws_iam_role" "node_group" {
  name = "eks-node-group"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "node_group_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "node_group_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "node_group_ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = aws_iam_role.node_group.name
}


# SSH Public Key for Node Group instances
resource "aws_key_pair" "ssh_pub_key" {
  key_name   = "eks-ssh-public-key"
  public_key = "${file(var.ssh_pub_key)}"
}


# ===============
# EKS NodeGroup-1
# ===============
resource "aws_eks_node_group" "eks_ng1" {
  cluster_name = "${aws_eks_cluster.cluster.name}"
  node_group_name = "${var.cluster_name}-ng1"
  node_role_arn = "${aws_iam_role.node_group.arn}"
  disk_size = 20
  subnet_ids = ["${var.cluster_subnet_ids[0]}"]

  scaling_config {
    desired_size = 1
    min_size = 1
    max_size = 5
  }

  instance_types = ["${var.eks_instance_type}"]

  remote_access {
    ec2_ssh_key = "${aws_key_pair.ssh_pub_key.key_name}"
  }
  
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [
    kubernetes_config_map.k8s_auth,
    aws_iam_role_policy_attachment.node_group_eks_worker_node_policy,
    aws_iam_role_policy_attachment.node_group_eks_cni_policy,
    aws_iam_role_policy_attachment.node_group_ec2_container_registry_read_only,
  ]
}


# ===============
# EKS NodeGroup-2
# ===============
resource "aws_eks_node_group" "eks_ng2" {
  cluster_name = "${aws_eks_cluster.cluster.name}"
  node_group_name = "${var.cluster_name}-ng2"
  node_role_arn = "${aws_iam_role.node_group.arn}"
  subnet_ids = ["${var.cluster_subnet_ids[1]}"]

  scaling_config {
    desired_size = 1
    min_size = 1
    max_size = 5
  }

  instance_types = ["${var.eks_instance_type}"]

  remote_access {
    ec2_ssh_key = "${aws_key_pair.ssh_pub_key.key_name}"
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
  
  depends_on = [
    kubernetes_config_map.k8s_auth,
    aws_iam_role_policy_attachment.node_group_eks_worker_node_policy,
    aws_iam_role_policy_attachment.node_group_eks_cni_policy,
    aws_iam_role_policy_attachment.node_group_ec2_container_registry_read_only,
  ]
}
