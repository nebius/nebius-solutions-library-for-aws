
# ==========================
# IAM Roles for MK8S Cluster
# ==========================
resource "yandex_iam_service_account" "mk8s_sa" {
  name = var.mk8s_sa_name
  folder_id = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id = var.folder_id
  role = "editor"
  member = "serviceAccount:${yandex_iam_service_account.mk8s_sa.id}"
}

# =============================================================
# Create Managed Services for Kubernetes Cluster (Master nodes)
# =============================================================
resource "yandex_kubernetes_cluster" "cluster" {
  name = var.cluster_name
  network_id = var.cluster_net_id
  service_ipv4_range = var.k8s_svc_ipv4_subnet
  cluster_ipv4_range = var.mk8s_pod_ipv4_subnet

  master {
    version = var.k8s_version
    zonal {
      zone = var.zone_id
      subnet_id = var.cluster_subnet_id
    }

    public_ip = true
    
    security_group_ids = [
      yandex_vpc_security_group.mk8s_sg.id, 
      yandex_vpc_security_group.mk8s_master_whitelist_sg.id, 
      yandex_vpc_security_group.mk8s_public_services_sg.id
    ]

    maintenance_policy {
      auto_upgrade = true

      maintenance_window {
        start_time = "15:00"
        duration   = "3h"
      }
    }
  }

  service_account_id = "${yandex_iam_service_account.mk8s_sa.id}"
  node_service_account_id = "${yandex_iam_service_account.mk8s_sa.id}"

  labels = {
    country = "il"
  }

  release_channel = "RAPID"
  network_policy_provider = "CALICO"

  depends_on = [ yandex_resourcemanager_folder_iam_member.editor ]
}

# =======
# Outputs
# =======

output "cluster_name" {
  value = yandex_kubernetes_cluster.cluster.name
}

output "cluster_endpoint" {
  value = yandex_kubernetes_cluster.cluster.master.0.external_v4_endpoint
}

output "cluster_certificate" {
  value = yandex_kubernetes_cluster.cluster.master.0.cluster_ca_certificate
}
