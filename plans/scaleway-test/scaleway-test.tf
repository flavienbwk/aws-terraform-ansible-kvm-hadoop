# Instanciate Scaleway servers for the aws-terraform-ansible-kvm-hadoop project.
# "Test" version specificity is about using only instances instead of baremetal
# to validate this Terraform script without having to pay for baremetal servers.
# GitHub : https://github.com/flavienbwk/aws-terraform-ansible-kvm-hadoop

variable "SCW_PROJECT_ID" {
  type        = string
  description = "Your Scaleway project ID"
}
variable "SCW_ACCESS_KEY" {
  type        = string
  description = "Your Scaleway access key"
}
variable "SCW_SECRET_KEY" {
  type        = string
  description = "Your Scaleway secret key"
}

terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
  required_version = ">= 0.13"
}

provider "scaleway" {
  project_id = var.SCW_PROJECT_ID
  access_key = var.SCW_ACCESS_KEY
  secret_key = var.SCW_SECRET_KEY

  zone = "fr-par-2"
}


data "scaleway_account_ssh_key" "main" {
  name = "main"
}

data "scaleway_baremetal_offer" "machine_1_offer" {
  zone = "fr-par-2"
  name = "EM-A210R-HDD" # or EM-A410X-SSD if this one is not available
}


# --- MACHINES DEFINITION ---


resource "scaleway_instance_ip" "machine_1_ip" {}
resource "scaleway_instance_server" "machine_1" {
  name       = "machine-1"
  type       = "DEV1-S"
  image      = "ubuntu_jammy"
  ip_id      = scaleway_instance_ip.machine_1_ip.id

  root_volume {
    size_in_gb = 20
  }
}

resource "scaleway_instance_ip" "machine_2_ip" {}
resource "scaleway_instance_server" "machine_2" {
  name       = "machine-2"
  type       = "DEV1-S"
  image      = "ubuntu_jammy"
  ip_id      = scaleway_instance_ip.machine_2_ip.id

  root_volume {
    size_in_gb = 20
  }
}

resource "scaleway_instance_ip" "machine_3_ip" {}
resource "scaleway_instance_server" "machine_3" {
  name       = "machine-3"
  type       = "DEV1-S"
  image      = "ubuntu_jammy"
  ip_id      = scaleway_instance_ip.machine_3_ip.id

  root_volume {
    size_in_gb = 20
  }
}

resource "scaleway_instance_ip" "vpn_server_ip" {}
resource "scaleway_instance_server" "vpn_server" {
  name       = "vpn_server"
  type       = "DEV1-S"
  image      = "ubuntu_jammy"
  ip_id      = scaleway_instance_ip.vpn_server_ip.id

  root_volume {
    size_in_gb = 20
  }
}

resource "scaleway_instance_ip" "hdfs_client_ip" {}
resource "scaleway_instance_server" "hdfs_client" {
  name       = "hdfs_client"
  type       = "DEV1-S"
  image      = "ubuntu_jammy"
  ip_id      = scaleway_instance_ip.hdfs_client_ip.id

  root_volume {
    size_in_gb = 20
  }
}

# ---/ END MACHINES DEFINITION ---


# Create the global.ini file from IPs of our instances
resource "local_file" "ansible_inventory" {
  filename = "../../inventories/global.ini"
  content = templatefile("../../inventories/global.ini.tpl", {
    machine_1_ip = scaleway_instance_server.machine_1.public_ip
    machine_1_user = "ubuntu"
    machine_2_ip = scaleway_instance_server.machine_2.public_ip
    machine_2_user = "ubuntu"
    machine_3_ip = scaleway_instance_server.machine_3.public_ip
    machine_3_user = "ubuntu"
    vpn_server_ip = scaleway_instance_server.vpn_server.public_ip
    vpn_server_user = "root"
    hdfs_client_ip = scaleway_instance_server.hdfs_client.public_ip
    hdfs_client_user = "root"
  })
}
