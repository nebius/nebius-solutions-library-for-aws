
# ========================================================
# OIDC provider. Needed to authenticate EKS cluster in IAM
# ========================================================

locals {
  cluster_oidc_cert_url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

data "tls_certificate" "cluster_oidc_certificate" {
  url = local.cluster_oidc_cert_url
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster_oidc_certificate.certificates[0].sha1_fingerprint]
  url = local.cluster_oidc_cert_url
}
