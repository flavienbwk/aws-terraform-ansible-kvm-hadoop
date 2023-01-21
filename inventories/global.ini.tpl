[local]
127.0.0.1 ansible_connection=local

[all:vars]
ansible_python_interpreter=/usr/bin/python3

[machines]
machine-1 ansible_user=${machine_1_user} ansible_host=${machine_1_ip}
machine-2 ansible_user=${machine_2_user} ansible_host=${machine_2_ip}
machine-3 ansible_user=${machine_3_user} ansible_host=${machine_3_ip}
openvpn-server ansible_user=${vpn_server_user} ansible_host=${vpn_server_ip}
hdfs_client ansible_user=${hdfs_client_user} ansible_host=${hdfs_client_ip}

[kvm_hosts]
machine-1
machine-2
machine-3

[vpnserver]
# One only
openvpn-server

[hdfs_fuse_clients]
hdfs_client hdfs_mount_path=/mnt/hdfs

[vpn_clients]
# Will get dynamically updated when adding KVM guests
hdfs_client

[kvm_guests]
# Will get dynamically updated when adding KVM guests

[hadoop_namenodes]
# Will get dynamically updated when adding KVM guests

[hadoop_managers]
# Will get dynamically updated when adding KVM guests

[hadoop_datanodes]
# Will get dynamically updated when adding KVM guests

[hadoop:children]
hadoop_namenodes
hadoop_datanodes
hadoop_managers
