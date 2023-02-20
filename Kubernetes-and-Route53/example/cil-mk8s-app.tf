
# =====================================================
# Deploy Kubernetes Application (Nginx) to MK8S cluster
# =====================================================

provider "kubernetes" {
  alias = "cil_mk8s"
  host = "${module.mk8s.cluster_endpoint}"
  cluster_ca_certificate = "${module.mk8s.cluster_certificate}"
  token = var.token
}

resource "kubernetes_config_map" "mk8s_nginx_cm" {
  provider = kubernetes.cil_mk8s

  metadata {
    name = "index-html"
    namespace = "default"
  }
  data = {
    "index.html" = <<INDEX
<html><h1>Welcome to CloudIL!</h1></br>
INDEX
  }

  depends_on = [module.mk8s.yandex_kubernetes_node_group]
}

resource "kubernetes_pod" "mk8s_nginx" {
  provider = kubernetes.cil_mk8s

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
        name = kubernetes_config_map.mk8s_nginx_cm.metadata[0].name
      }
    }
  }
  depends_on = [
    module.mk8s.yandex_kubernetes_node_group,
    kubernetes_config_map.mk8s_nginx_cm
  ]
}

resource "kubernetes_service" "mk8s_nginx" {
  provider = kubernetes.cil_mk8s
  metadata {
    name = "nginx"
  }
  spec {
    selector = {
      App = "${kubernetes_pod.mk8s_nginx.metadata[0].labels.App}"
    }
    port {
      port = 80
      target_port = 80
    }
    type = "LoadBalancer"
  }

  depends_on = [
    kubernetes_pod.mk8s_nginx
  ]
}

output "cil_lb_ip" {
  value = "${kubernetes_service.mk8s_nginx.status.0.load_balancer.0.ingress.0.ip}"
}
