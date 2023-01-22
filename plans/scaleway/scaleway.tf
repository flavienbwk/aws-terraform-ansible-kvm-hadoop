# instantiate Scaleway servers for the aws-terraform-ansible-kvm-hadoop project
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

data "scaleway_baremetal_os" "ubuntu_22_04" {
  zone    = "fr-par-2"
  name    = "Ubuntu"
  version = "22.04 LTS (Jammy Jellyfish)"
}

data "scaleway_baremetal_offer" "machine_1_offer" {
  zone = "fr-par-2"
  name = "EM-A210R-HDD" # or EM-A410X-SSD if this one is not available
}


# --- MACHINES DEFINITION ---

resource "scaleway_baremetal_server" "machine_1" {
  name        = "machine-1"
  zone        = "fr-par-2"
  offer       = data.scaleway_baremetal_offer.machine_1_offer.offer_id
  os          = data.scaleway_baremetal_os.ubuntu_22_04.os_id
  ssh_key_ids = [data.scaleway_account_ssh_key.main.id]
}

resource "scaleway_baremetal_server" "machine_2" {
  name        = "machine-2"
  zone        = "fr-par-2"
  offer       = data.scaleway_baremetal_offer.machine_1_offer.offer_id
  os          = data.scaleway_baremetal_os.ubuntu_22_04.os_id
  ssh_key_ids = [data.scaleway_account_ssh_key.main.id]
}

resource "scaleway_baremetal_server" "machine_3" {
  name        = "machine-3"
  zone        = "fr-par-2"
  offer       = data.scaleway_baremetal_offer.machine_1_offer.offer_id
  os          = data.scaleway_baremetal_os.ubuntu_22_04.os_id
  ssh_key_ids = [data.scaleway_account_ssh_key.main.id]
}

resource "scaleway_instance_ip" "vpn_server_ip" {}
resource "scaleway_instance_server" "vpn_server" {
  name       = "vpn-server"
  type       = "DEV1-L"
  image      = "ubuntu_jammy"
  ip_id      = scaleway_instance_ip.vpn_server_ip.id

  root_volume {
    size_in_gb = 80
  }
}

resource "scaleway_instance_ip" "hdfs_client_ip" {}
resource "scaleway_instance_server" "hdfs_client" {
  name       = "hdfs-client"
  type       = "DEV1-M"
  image      = "ubuntu_jammy"
  ip_id      = scaleway_instance_ip.hdfs_client_ip.id

  root_volume {
    size_in_gb = 40
  }
}

# ---/ END MACHINES DEFINITION ---


# Create the global.ini file from IPs of our instances
resource "local_file" "ansible_inventory" {
  filename = "../../inventories/global.ini"
  content = templatefile("../../inventories/global.ini.tpl", {
    machine_1_ip = scaleway_baremetal_server.machine_1.ips[0].address
    machine_1_user = "ubuntu"
    machine_2_ip = scaleway_baremetal_server.machine_2.ips[0].address
    machine_2_user = "ubuntu"
    machine_3_ip = scaleway_baremetal_server.machine_3.ips[0].address
    machine_3_user = "ubuntu"
    vpn_server_ip = scaleway_instance_server.vpn_server.public_ip
    vpn_server_user = "root"
    hdfs_client_ip = scaleway_instance_server.hdfs_client.public_ip
    hdfs_client_user = "root"
  })
}
