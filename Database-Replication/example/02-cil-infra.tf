# =================
# CloudIL Resources
# =================

# ==================
# PostgreSQL Cluster
# ==================
resource "yandex_mdb_postgresql_cluster" "pg" {
  name = "demo-pg"
  environment = "PRESTABLE"
  network_id  = "${data.yandex_vpc_network.pg_net.id}"
  security_group_ids = [ yandex_vpc_security_group.pg_sg.id ]

  config {
    version = 14
    resources {
      resource_preset_id = var.pg_cluster_flavor
      disk_type_id = "network-ssd"
      disk_size = 16
    }
    postgresql_config = {
      max_connections = 395
      enable_parallel_hash = true
      vacuum_cleanup_index_scale_factor = 0.2
      autovacuum_vacuum_scale_factor = 0.34
      default_transaction_isolation = "TRANSACTION_ISOLATION_READ_COMMITTED"
      shared_preload_libraries = "SHARED_PRELOAD_LIBRARIES_AUTO_EXPLAIN,SHARED_PRELOAD_LIBRARIES_PG_HINT_PLAN"
    }
  }

  host {
    zone = var.zone_id
    subnet_id = "${yandex_vpc_subnet.pg_subnet.id}"
    assign_public_ip = true
  }
}

# ===================
# PostgreSQL Database
# ===================
resource "yandex_mdb_postgresql_database" "pg_db" {
  cluster_id = "${yandex_mdb_postgresql_cluster.pg.id}"
  name = var.db_name
  owner = var.db_user
  lc_collate = "en_US.UTF-8"
  lc_type = "en_US.UTF-8"

  depends_on = [ yandex_mdb_postgresql_user.db_user ]
}

# ================================
# PostgreSQL Database User (admin)
# ================================
resource "yandex_mdb_postgresql_user" "db_user" {
  cluster_id = "${yandex_mdb_postgresql_cluster.pg.id}"
  name = var.db_user
  password = var.db_password
  conn_limit = 50
  settings = {
    default_transaction_isolation = "read committed"
    log_min_duration_statement = 5000
  }

  depends_on = [ yandex_mdb_postgresql_cluster.pg ]
}

# =============
# VPC Resources
# =============

data "yandex_vpc_network" "pg_net" {
  name = var.vpc_net_name
}

resource "yandex_vpc_subnet" "pg_subnet" {
  name = var.vpc_subnet_name
  zone = var.zone_id
  network_id = "${data.yandex_vpc_network.pg_net.id}"
  v4_cidr_blocks = [var.vpc_subnet_prefix]
}

resource "yandex_vpc_security_group" "pg_sg" {
  description = "Security group for PG cluster nodes"
  network_id  = "${data.yandex_vpc_network.pg_net.id}"

  egress {
    description    = "Permit ALL" 
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol          = "ANY"
    predefined_target = "self_security_group"
  }

  ingress {
    description    = "ICMP"
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "SSH"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "PostgreSQL"
    protocol       = "TCP"
    port           = var.db_port
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

}

## Yandex Data Transfer:
## AWS RDS PostgreSQL instance --> YC MDB PostgreSQL instance
## https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/datatransfer_transfer

resource "yandex_datatransfer_endpoint" "dt_source_aws_rds" {
  count = var.dt_enable == false ? 0 : 1
  name = "aws-rds-pg"
  settings {
    postgres_source {
      connection {
        on_premise {
          hosts = [ aws_db_instance.this.address ]
          port  = var.db_port
        }
      }
      slot_gigabyte_lag_limit = 100
      database = var.db_name
      user     = var.db_user
      password {
        raw = var.db_password
      }
    }
  }
}

resource "yandex_datatransfer_endpoint" "dt_target_yc_mdb" {
  count = var.dt_enable == false ? 0 : 1
  name = "cil-mdb-pg"
  settings {
    postgres_target {
      connection {
        mdb_cluster_id = "${yandex_mdb_postgresql_cluster.pg.id}"
      }
      database = var.db_name
      user     = var.db_user
      password {
        raw = var.db_password
      }
    }
  }
}

resource "yandex_datatransfer_transfer" "dt_transfer" {
  count = var.dt_enable == false ? 0 : 1
  name      = "awspg-cilpg"
  source_id = "${yandex_datatransfer_endpoint.dt_source_aws_rds[count.index].id}"
  target_id = "${yandex_datatransfer_endpoint.dt_target_yc_mdb[count.index].id}"
  type      = "SNAPSHOT_AND_INCREMENT"
}
