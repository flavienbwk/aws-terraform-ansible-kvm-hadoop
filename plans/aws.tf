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
  access_key = var.SCW_ACCESS_KEY
  secret_key = var.SCW_SECRET_KEY

  zone   = "fr-par-1"
  region = "fr-par"
}

resource "scaleway_instance_ip" "k8s_master_public_ip" {
  project_id = var.SCW_PROJECT_ID
}
resource "scaleway_instance_ip" "k8s_node_1_public_ip" {
  project_id = var.SCW_PROJECT_ID
}
resource "scaleway_instance_ip" "k8s_node_2_public_ip" {
  project_id = var.SCW_PROJECT_ID
}

resource "scaleway_instance_server" "k8s_master" {
  project_id = var.SCW_PROJECT_ID
  name       = "todevops-k8s-master"
  type       = "DEV1-L"
  image      = "ubuntu_jammy"

  tags = ["k8s-master"]

  ip_id = scaleway_instance_ip.k8s_master_public_ip.id

  root_volume {
    size_in_gb = 80
  }

}

resource "scaleway_instance_server" "k8s_node_1" {
  project_id = var.SCW_PROJECT_ID
  type       = "DEV1-L"
  image      = "ubuntu_jammy"
  name       = "todevops-k8s-node-1"

  tags = ["k8s-nodes", "k8s_node_1"]

  ip_id = scaleway_instance_ip.k8s_node_1_public_ip.id

  root_volume {
    size_in_gb = 40
  }

}

resource "scaleway_instance_server" "k8s_node_2" {
  project_id = var.SCW_PROJECT_ID
  name       = "todevops-k8s-node-2"
  type       = "DEV1-L"
  image      = "ubuntu_jammy"

  tags = ["k8s-nodes", "k8s_node_2"]

  ip_id = scaleway_instance_ip.k8s_node_2_public_ip.id

  root_volume {
    size_in_gb = 40
  }

}

# --- OUTPUT VALUES ---

output "k8s_master_public_ip" {
  value = scaleway_instance_ip.k8s_master_public_ip.address
}
output "k8s_node_1_public_ip" {
  value = scaleway_instance_ip.k8s_node_1_public_ip.address
}
output "k8s_node_2_public_ip" {
  value = scaleway_instance_ip.k8s_node_2_public_ip.address
}

output "k8s_master_name" {
  value = scaleway_instance_server.k8s_master.name
}
output "k8s_node_1_name" {
  value = scaleway_instance_server.k8s_node_1.name
}
output "k8s_node_2_name" {
  value = scaleway_instance_server.k8s_node_2.name
}

# ---/ END OUTPUT VALUES ---
