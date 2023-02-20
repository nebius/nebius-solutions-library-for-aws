
# ================================================================
# Create Managed Services for Kubernetes Node Group (Worker nodes)
# ================================================================

resource "yandex_kubernetes_node_group" "node_group" {

  cluster_id = "${yandex_kubernetes_cluster.cluster.id}"
  name = "${var.cluster_name}-ng1"
  version = var.k8s_version

  labels = {
    country = "il"
  }

  instance_template {
    platform_id = "standard-v3"
    network_interface {
      nat = true
      security_group_ids = [
        yandex_vpc_security_group.mk8s_sg.id, 
        yandex_vpc_security_group.mk8s_public_services_sg.id
      ]
      subnet_ids = [var.cluster_subnet_id]
    }

    resources {
      memory = 4
      cores  = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

    scheduling_policy {
      preemptible = false
    }
  }

  scale_policy {
    fixed_scale {
      size = 2
    }
  }

  allocation_policy {
    location {
      zone = var.zone_id
    }
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true

    maintenance_window {
      day        = "monday"
      start_time = "15:00"
      duration   = "3h"
    }

    maintenance_window {
      day        = "friday"
      start_time = "10:00"
      duration   = "4h30m"
    }
  }
}
