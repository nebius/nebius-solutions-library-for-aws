
data "yandex_compute_image" "vm_image" {
  family = "ubuntu-2004-lts"
}

data "template_file" "yc_vm_cloud_init" {
  template = file("cil-vm.tpl")
  vars = {
    ssh_key = file(var.ssh_public_key)
  }
}

resource "yandex_compute_instance" "vm_instance" {
  name = "vpn-vm-instance"
  platform_id = "standard-v3"
  zone = var.zone_id

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "${data.yandex_compute_image.vm_image.id}"
    }
  }

  network_interface {
    subnet_id = module.vpn.cil_subnet_id
    ip_address = cidrhost(var.cil_subnet_prefix, 10)
    security_group_ids = [yandex_vpc_security_group.vm_sg.id]
    nat = false
  }

  metadata = {
    user-data = "${data.template_file.yc_vm_cloud_init.rendered}"
  }
}

# =======
# Outputs
# =======

output "cil_vm_internal_ip" {
  value = "${yandex_compute_instance.vm_instance.network_interface.0.ip_address}"
}
