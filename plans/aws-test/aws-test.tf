# instantiate AWS servers for the aws-terraform-ansible-kvm-hadoop project.
# "Test" version specificity is about using only instances instead of baremetal
# to validate this Terraform script without having to pay for baremetal servers.
# GitHub : https://github.com/flavienbwk/aws-terraform-ansible-kvm-hadoop

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}


# --- MACHINES DEFINITION ---

resource "aws_instance" "machine_1" {
  ami                         = "ami-03e08697c325f02ab"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.takh_sg.id]
  associate_public_ip_address = true

  # associate to subnet
  subnet_id = aws_subnet.takh_net.id

  # Add keypair to be able to connect to the instance
  key_name = "main"

  # Add 10GB of disk space
  root_block_device {
    volume_size = 8
  }

  tags = {
    Name = "machine-1"
  }
}

resource "aws_instance" "machine_2" {
  ami                         = "ami-03e08697c325f02ab"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.takh_sg.id]
  associate_public_ip_address = true

  # associate to subnet
  subnet_id = aws_subnet.takh_net.id

  # Add keypair to be able to connect to the instance
  key_name = "main"

  # Add 10GB of disk space
  root_block_device {
    volume_size = 8
  }

  tags = {
    Name = "machine-2"
  }
}

resource "aws_instance" "machine_3" {
  ami                         = "ami-03e08697c325f02ab"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.takh_sg.id]
  associate_public_ip_address = true

  # associate to subnet
  subnet_id = aws_subnet.takh_net.id

  # Add keypair to be able to connect to the instance
  key_name = "main"

  # Add 10GB of disk space
  root_block_device {
    volume_size = 8
  }

  tags = {
    Name = "machine-3"
  }
}

resource "aws_instance" "vpn_server" {
  ami                         = "ami-03e08697c325f02ab"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.takh_sg.id]
  associate_public_ip_address = true

  # associate to subnet
  subnet_id = aws_subnet.takh_net.id

  # Add keypair to be able to connect to the instance
  key_name = "main"

  # Add 10GB of disk space
  root_block_device {
    volume_size = 8
  }

  tags = {
    Name = "vpn-server"
  }
}

resource "aws_instance" "hdfs_client" {
  ami                         = "ami-03e08697c325f02ab"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.takh_sg.id]
  associate_public_ip_address = true

  # associate to subnet
  subnet_id = aws_subnet.takh_net.id

  # Add keypair to be able to connect to the instance
  key_name = "main"

  # Add 10GB of disk space
  root_block_device {
    volume_size = 8
  }

  tags = {
    Name = "hdfs-client"
  }
}

# ---/ END MACHINES DEFINITION ---

# Create the global.ini file from IPs of our instances
resource "local_file" "ansible_inventory" {
  filename = "../../inventories/global.ini"
  content = templatefile("../../inventories/global.ini.tpl", {
    machine_1_ip     = aws_instance.machine_1.public_ip
    machine_1_user   = "ubuntu"
    machine_2_ip     = aws_instance.machine_2.public_ip
    machine_2_user   = "ubuntu"
    machine_3_ip     = aws_instance.machine_3.public_ip
    machine_3_user   = "ubuntu"
    vpn_server_ip    = aws_instance.vpn_server.public_ip
    vpn_server_user  = "ubuntu"
    hdfs_client_ip   = aws_instance.hdfs_client.public_ip
    hdfs_client_user = "ubuntu"
  })
}

# Computing pricing
module "pricing" {
  source = "terraform-aws-modules/pricing/aws//modules/pricing"

  resources = {
    "aws_instance.machine_1" = {
      instanceType = "t2.micro"
      location     = "us-east-1"
    }
    "aws_instance.machine_2" = {
      instanceType = "t2.micro"
      location     = "us-east-1"
    }
    "aws_instance.machine_3" = {
      instanceType = "t2.micro"
      location     = "us-east-1"
    }
    "aws_instance.vpn_server" = {
      instanceType = "t2.micro"
      location     = "us-east-1"
    }
    "aws_instance.hdfs_client" = {
      instanceType = "t2.micro"
      location     = "us-east-1"
    }
  }
}
output "pricing_per_instance" {
  value = module.pricing.pricing_per_resources
}
output "pricing_month" {
  value = module.pricing.total_price_per_month # 730 hours per month
}
