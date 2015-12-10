# vagrantfile_gen
Vagrantfile generator for each differenc environment(such as KVM, Virtualbox)

## Directory
```
├── vagrantfile_gen.sh 				--- This is a key file for generate to Vagrantfile by below configuration & host information
├── conf: Has a configuration for each provisioning
│   ├── bakery.conf					--- Configuration part of bakery in the Vagrantfile
│   ├── consul.conf					--- Configuration part of consul server/client/bootstrap in the Vagrantfile
│   ├── haproxy.conf				--- Configuration part of Haproxy Master/slave with marathon-bridge in the Vagrantfile
│   ├── mesos.conf					--- Configuration part of Mesos Master/slave in the Vagrantfile
│   └── test.conf					--- Configuration part of test environment in the Vagrantfile
├── host: 
│   └── vagrant01.list				--- Sample list of variables(Repository IP address, Remote Hypervisor IP, Private IP range for each VMs)
├── provisioning
│   ├── bakery.sh				--- Provisioning script for The Docker bakery
│   ├── consul.sh				--- Provisioning script for The Consul
│   ├── docker_registry.sh		--- Provisioning script for The Docker local-registry
│   ├── haproxy.sh				--- Provisioning script for The Haproxy Master/slave
│   └── mesos.sh				--- Provisioning script for The Mesos Master/slave 
├── ubuntu_vagrantfile_gen.zicf --- You can make a package by this index file If you are using the zinst package mgmt on Ubuntu
└── vagrantfile_gen.zicf		--- You can make a package by this index file If you are using the zinst package mgmt on RHEL
```

## Description
* This a Script for Vagrantfile generator of each Virtual host environment
* If you using the Consul you can get a detail information from that as below
 * http://192.168.15.2:8500/v1/kv/hypervisors/hosts?raw
```
kvm01
kvm02
kvm03
```
 * 192.168.15.2:8500/v1/kv/hypervisors/kvm01/data?raw
```
hypervisor_ip="192.0.1.12"

was_private="192.168.121.12x"
was_public="192.0.1.12x"

web_private="192.168.33.1x"

mesos_master_private="192.168.133.1x"
mesos_slave_private="192.168.133.10x"

haproxy_slave_private="192.168.133.14x"
haproxy_master_private="192.168.133.13x"

consul_bootstrap_private="192.168.133.20"
consul_client_private="192.168.133.3x"
consul_server_private="192.168.133.2x"

bakery_mc_private="192.168.33.210"
baker_global_private="192.168.33.200"

web_test_private="192.168.33.1x"
was_test_private="192.168.121.12x"
was_test_public="192.0.1.12x"
```
* Or you just can modify the sample file as below
```
$] cp ./host/vagrant01.list ./host/kvm01.list
$] vi ./host/kvm01.list

hypervisor_ip="192.0.1.12"

was_private="192.168.121.12x"
was_public="192.0.1.12x"

web_private="192.168.33.1x"

mesos_master_private="192.168.133.1x"
mesos_slave_private="192.168.133.10x"

haproxy_slave_private="192.168.133.14x"
haproxy_master_private="192.168.133.13x"

consul_bootstrap_private="192.168.133.20"
consul_client_private="192.168.133.3x"
consul_server_private="192.168.133.2x"

bakery_mc_private="192.168.33.210"
baker_global_private="192.168.33.200"

web_test_private="192.168.33.1x"
was_test_private="192.168.121.12x"
was_test_public="192.0.1.12x"
```

## How to use
* You just can run the script as below with each configuration for VMs IP range
```
vagrantfile_gen.sh
```

















