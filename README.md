# aws-terraform-ansible-kvm-hadoop

A sample project to install Hadoop on KVM with Ansible, on AWS machines instanciated by Terraform.

Here is an example of HDFS storage cluster running with this project.

![DFS storage types tab](./dfs_storage_type.png)
![Hadoop cluster live datanodes](./datanodes_alive.png)

## A note about KVM in the Cloud

Basically, you can't work with KVM on a classic AWS EC2 instance [unless you have a baremetal one](https://aws.amazon.com/blogs/aws/new-amazon-ec2-bare-metal-instances-with-direct-access-to-hardware). You must choose a `*.metal` instance type (:moneybag:).

This repo is for educational purposes. If you use Cloud providers, only use KVM if you absolutely NEEDS TO. It asks for a more costly infrastructures, time-consuming instanciations, adds a layer of complexity already managed by Cloud providers (network, machine configuration) and as such is a burden to maintain. This architecture is only useful if you have big machines that must include strictly partitioned VMs.

As [Scaleway Elastic Metal](https://www.scaleway.com/en/elastic-metal/) machines are way less expensive than AWS, you will find Terraform plans and instructions for both AWS and Scaleway.

## 1. Instanciate the infrastructure

![Architecture schema](./schema.jpg)

In this architecture, we will setup a VPN server to get KVM guests to communicate. After setting up and connecting Hadoop nodes through the VPN network, a client will try to [mount an HDFS space as a FUSE](https://sleeplessbeastie.eu/2021/09/13/how-to-mount-hdfs-as-a-local-file-system/) to be used as a file system.

The ResourceManager described here will get the roles of ResourceManager, NodeManager and MapReduce Job History server.

<details open>
<summary>👉 Using AWS (price: 8454.53$/month)</summary>

:warning: :moneybag: Please be very careful running the Terraform plans as prices for baremetal instances are **very high**. The indicated cost is about the least expensive instance found in the North Virginia region.

</details>

<details close>
<summary>👉 Using Scaleway (price: 303.37$/month)</summary>

1. Go to your Scaleway account > [Credentials](https://console.scaleway.com/project/credentials) and create a new API key `terraform-ansible-kvm-hadoop`

2. Run the following `export` commands replacing values by yours

    ```bash
    export TF_VAR_SCW_PROJECT_ID="my-project-id"
    export TF_VAR_SCW_ACCESS_KEY="my-access-key"
    export TF_VAR_SCW_SECRET_KEY="my-secret-key"
    ```

3. Make sure there's no error by running init and plan commands

    ```bash
    cd ./plans
    terraform init
    terraform plan
    ```

4. Execute the plan

    ```bash
    terraform apply
    ```

    > To terminate instances and avoid unintended spendings, use `terraform destroy`

5. Edit values of our Ansible inventory file from Terraform output values

    ```bash
    # Install JSON parser
    sudo apt install -y jq
    # Retrieve and set appropriate values
    terraform output -json > terraform_values.json
    cd ..
    bash terraform_to_ansible_values.sh
    ```

</details>

## 2. Setup the infrastructure and install services

![Chaining of Ansible's playbook actions](./chaining.jpg)

1. Install the OpenVPN server

    ```bash
    ANSIBLE_CONFIG=$(pwd)/ansible.cfg ansible-playbook -i inventories/global.ini ./playbooks/install.yml --extra-vars @./vars/all.yml -t vpn-server
    ```

2. Install KVM on each host and create guests

    ```bash
    ansible-galaxy collection install community.libvirt
    ansible-playbook -i inventories/global.ini ./playbooks/install.yml --extra-vars @./vars/all.yml -t kvm-install
    ```

3. Connect all machines to communicate with each other (OpenVPN clients)

    Connect and retrieve IP of each KVM guest.

    ```bash
    eval `ssh-agent` && ssh-add -D
    ansible-playbook -i inventories/global.ini ./playbooks/install.yml --extra-vars @./vars/all.yml -t vpn-client
    ```

4. Install Hadoop cluster

    ```bash
    ansible-playbook -i inventories/global.ini ./playbooks/install.yml --extra-vars @./vars/all.yml -t hadoop
    ```

5. Install HDFS FUSE client

    ```bash
    ansible-playbook -i inventories/global.ini ./playbooks/install.yml --extra-vars @./vars/all.yml -t hdfs-fuse-clients
    ```

## Inspirations

- OpenVPN : [robertdebock/ansible-role-openvpn](https://github.com/robertdebock/ansible-role-openvpn)
- Hadoop : [andiveloper/ansible-hadoop](https://github.com/andiveloper/ansible-hadoop)
- KVM : [noahbailey/ansible-qemu-kvm](https://github.com/noahbailey/ansible-qemu-kvm)
