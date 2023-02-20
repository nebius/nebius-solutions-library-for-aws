
# ============================
# CloudIL Environment Settings
# ============================

variable "cloud_id" {
  description = "Taken from the environment variable"
}

variable "folder_id" {
  description = "Taken from the environment variable"
}

variable "token" {
  description = "Taken from the environment variable"
}

variable "zone_id" {
  default = "il1-a"
}


# ========================
# AWS Environment Settings
# ========================

variable "aws_region" {
  default = "eu-central-1"
} 

variable "aws_profile" {
  default = "aws"
} 


# ===============
# Input Variables
# ===============

variable "pg_cluster_flavor" {
  default = "s3-c2-m8"
}

variable "vpc_net_name" {
  default = "default"
}

variable "vpc_subnet_name" {
  default = "pg-subnet"
}

variable "vpc_subnet_prefix" {
  default = "10.10.10.0/24"
}

variable "db_name" {
  description = "Database that will be created on both sides"
  default = "demo_db"
}

variable "db_user" {
  description = "Database owner that will be created on both sides"
  default = "demo_user"
}

variable "db_password" {
  sensitive = true
  description = "Database password for owner user that will be created on both sides"
  default = "suP87-dbPw"
}

variable "identifier" {
  description = "The name of the RDS instance, if omitted, Terraform will assign a random, unique identifier"
  default = "demodb-postgres"
}

variable "db_port" {
  description = "DB Instance TCP port"
  default = "6432"
}

variable "dt_enable" {
  description = "Yandex Data Transfer Enable flag"
  default = false
}
