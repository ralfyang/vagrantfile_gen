#!/bin/bash
### Script for messos env. for each other:   Mesos Provisioning
bakery_type="global"

## source docker_registry.sh -- not works
## Docker registry of Gravity
gravity_mgmt="10.53.15.219:8500"

## SSL Cert-key insert from Consul
sudo mkdir -p "/etc/docker/certs.d/registry.global.gravity:8443/"
curl -sSL "http://$gravity_mgmt/v1/kv/registry.global.gravity.key?raw" -o "/etc/docker/certs.d/registry.global.gravity:8443/ca.crt"
sudo mkdir -p "/etc/docker/certs.d/registry.$bakery_type.gravity:8443/" 2> /dev/null
curl -sSL "http://$gravity_mgmt/v1/kv/registry.$bakery_type.gravity.key?raw" -o "/etc/docker/certs.d/registry.$bakery_type.gravity:8443/ca.crt"  2> /dev/null
curl http://10.53.15.219:8500/v1/kv/management-general/vagrantfile_gen/ssh-key?raw -o /root/.ssh/id_rsa -o /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa

## Host add to /etc/hosts
echo "10.53.15.184 registry.global.gravity" >> /etc/hosts
echo "10.53.15.219 registry.mc.gravity" >>  /etc/hosts
echo "" 

## Make a Git directory
apt-get update
#apt-get install git vagrant tree -y
apt-get install git tree virt-manager -y


cat << EOF >> ~/.ssh/known_hosts
|1|LWiX3w5NXkJh7JnoodrYy7ZST7M=|WrXEcsIMoV7/wSlP2uW1i597tsM= ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFSMqzJeV9rUzU4kWitGjeR4PWSa29SPqJ1fVkhtj3Hw9xjLVXVYrU9QlYWrOLXBpQ6KWjbjTDTdDkoohFzgbEY=
|1|ZJL6yHCbAKF/tELMmlml0Jf51KI=|D8++oRx7mtYKGNnEreI9/zFP55M= ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFSMqzJeV9rUzU4kWitGjeR4PWSa29SPqJ1fVkhtj3Hw9xjLVXVYrU9QlYWrOLXBpQ6KWjbjTDTdDkoohFzgbEY=
EOF

mkdir /root/Git/
cd /root/Git/
git clone git@gitlab.com:iic/vagrant_dev_env.git


## Docker install for ubuntu
zinst i docker -stable

## Local IP Find

### You can change the setting as below what you need
zinst i docker_compose logspout_logstash_container   monit_logspout_container -stable

## Global setting
zinst i	monit_rootfs \
	monit_docker -stable


curl -sL http://10.52.32.60/vagrantbox/vagrant_1.8.1_x86_64.deb -o ./vagrant_1.8.1_x86_64.deb
dpkg -i vagrant_1.8.1_x86_64.deb

sudo apt-get install libxslt-dev libxml2-dev libvirt-dev zlib1g-dev ruby-dev -y
vagrant box add centos6 http://10.52.32.60/vagrantbox/centos-6.6-x86_64.box
vagrant box add ubuntu1404 http://10.52.32.60/vagrantbox/trusty-server-cloudimg-amd64-vagrant-disk1.box
bash -l
vagrant plugin install vagrant-libvirt 
vagrant plugin install vagrant-mutate
vagrant mutate ubuntu1404 libvirt
vagrant mutate centos6 libvirt
