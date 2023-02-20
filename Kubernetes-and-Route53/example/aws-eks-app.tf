
# ====================================================
# Deploy Kubernetes Application (Nginx) to EKS cluster
# ====================================================

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  alias = "aws_eks"
  host = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token = data.aws_eks_cluster_auth.cluster.token
}

resource "kubernetes_config_map" "eks_nginx_cm" {
  provider = kubernetes.aws_eks

  metadata {
    name = "index-html"
    namespace = "default"
  }
  data = {
    "index.html" = <<INDEX
<html><h1>Welcome to AWS!</h1></br>
INDEX
  }

  depends_on = [module.eks.aws_eks_node_group]
}


resource "kubernetes_pod" "eks_nginx" {
  provider = kubernetes.aws_eks

  metadata {
    name = "nginx"
    labels = {
      App = "nginx"
    }
  }

  spec {
    container {
      image = "nginx:${var.nginx_version}"
      name  = "nginx"

      port {
        container_port = 80
      }

      volume_mount {
        name = "nginx-index-file"
        mount_path = "/usr/share/nginx/html/"
      }
    }

    volume {
      name = "nginx-index-file"
      config_map {
        name = kubernetes_config_map.eks_nginx_cm.metadata[0].name
      }
    }
  }

  depends_on = [
    module.eks.aws_eks_node_group,
    kubernetes_config_map.eks_nginx_cm
  ]
}

resource "kubernetes_service" "eks_nginx" {
  provider = kubernetes.aws_eks

  metadata {
    name = "nginx"
  }
  spec {
    selector = {
      App = "${kubernetes_pod.eks_nginx.metadata[0].labels.App}"
    }
    port {
      port = 80
      target_port = 80
    }
    
    type = "LoadBalancer"
  }

  depends_on = [kubernetes_pod.eks_nginx]
}

output "eks_lb_ip" {
  value = "${kubernetes_service.eks_nginx.status.0.load_balancer.0.ingress.0.hostname}"
}
