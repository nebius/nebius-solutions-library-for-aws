
# ==============================================
# Create ConfigMap on Kubernetes cluster
# for the successfull worker nodes Authenticaion
# ==============================================

data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.cluster.id
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.cluster.id
}

provider "kubernetes" {
  alias = "aws_eks"
  host = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token = data.aws_eks_cluster_auth.cluster.token
}


locals {
  configmap_roles = flatten([
    {
      rolearn  = aws_iam_role.node_group.arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes",
      ]
    }
  ])
}

resource "kubernetes_config_map" "k8s_auth" {
  provider = kubernetes.aws_eks
  
  metadata {
    name = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode(local.configmap_roles)
    #mapUsers = yamlencode(local.kubeconfig_users)
  }

  depends_on = [aws_eks_cluster.cluster]
}
