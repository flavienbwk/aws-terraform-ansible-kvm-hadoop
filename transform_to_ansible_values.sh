#!/bin/bash

# This script initializes Ansible inventory values with
# output values from our Terraform configuration.

# exit when any command fails
set -e

if ! command -v jq &> /dev/null
then
    echo "jq could not be found. Please install it."
    exit 1
fi

terraform_values_path="$(pwd)/plans/terraform_values.json"
if ! test -f "$terraform_values_path"; then
    echo "$terraform_values_path was not found, did you perform the terraform output command from the documentation ?"
    exit 1
fi

terraform_values_content="$(cat $terraform_values_path)"
k8s_master_name="$(echo $terraform_values_content | jq -r .k8s_master_name.value)"
k8s_master_public_ip="$(echo $terraform_values_content | jq -r .k8s_master_public_ip.value)"
k8s_node_1_name="$(echo $terraform_values_content | jq -r .k8s_node_1_name.value)"
k8s_node_1_public_ip="$(echo $terraform_values_content | jq -r .k8s_node_1_public_ip.value)"
k8s_node_2_name="$(echo $terraform_values_content | jq -r .k8s_node_2_name.value)"
k8s_node_2_public_ip="$(echo $terraform_values_content | jq -r .k8s_node_2_public_ip.value)"

for value in "k8s_master_name" "k8s_master_public_ip" "k8s_node_1_name" "k8s_node_1_public_ip" "k8s_node_2_name" "k8s_node_2_public_ip"
do
    if [ -z "${!value}" ]
    then
        echo "Value of $value is empty"
        exit 1
    fi
done
echo -e "Retrieved values. Now replacing them."

inventory_path="$(pwd)/inventories/scaleway.ini"
if ! test -f "$inventory_path"; then
    echo "$inventory_path was not found, are you at the root of this project ?"
    exit 1
fi
sed -i -E 's/master ansible_host=([0-9.]{1,3})+/master ansible_host='$k8s_master_public_ip'/g' "$inventory_path"
sed -i -E 's/node1 ansible_host=([0-9.]{1,3})+/node1 ansible_host='$k8s_node_1_public_ip'/g' "$inventory_path"
sed -i -E 's/node2 ansible_host=([0-9.]{1,3})+/node2 ansible_host='$k8s_node_2_public_ip'/g' "$inventory_path"

sed -i -E 's/master(.*)machine_name=(.*)/master\1machine_name='$k8s_master_name'/g' "$inventory_path"
sed -i -E 's/node1(.*)machine_name=(.*)/node1\1machine_name='$k8s_node_1_name'/g' "$inventory_path"
sed -i -E 's/node2(.*)machine_name=(.*)/node2\1machine_name='$k8s_node_2_name'/g' "$inventory_path"

echo -e "Success : values replaced !"
