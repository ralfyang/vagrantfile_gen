#!/bin/bash
### Script for messos env. for each other:   Mesos Provisioning
bakery_type=$1
role=$2
master_ip=$3
adv_ip=$4


## source docker_registry.sh -- not works
## Docker registry of Gravity
gravity_mgmt="10.53.15.219:8500"

## SSL Cert-key insert from Consul
sudo mkdir -p "/etc/docker/certs.d/registry.global.gravity:8443/"
curl -sSL "http://$gravity_mgmt/v1/kv/registry.global.gravity.key?raw" -o "/etc/docker/certs.d/registry.global.gravity:8443/ca.crt"
sudo mkdir -p "/etc/docker/certs.d/registry.$bakery_type.gravity:8443/" 2> /dev/null
curl -sSL "http://$gravity_mgmt/v1/kv/registry.$bakery_type.gravity.key?raw" -o "/etc/docker/certs.d/registry.$bakery_type.gravity:8443/ca.crt"  2> /dev/null

## Host add to /etc/hosts
echo "10.53.15.184 registry.global.gravity" >> /etc/hosts
echo "10.53.15.219 registry.mc.gravity" >>  /etc/hosts
echo "" 


## Make a Git directory
mkdir /root/Git/
## Docker install for ubuntu
zinst i docker -stable

## Local IP Find
IPaddr=`ifconfig eth1 |awk '/inet addr/ {print $2}' | sed -e 's/addr://g'`

## Setup for Master or slave
### You can change the setting as below what you need
	if [[ $role = slave ]];then
		zinst i mesos -stable \
			-set mesos.role="$role" \
			-set mesos.slave_ip="$IPaddr" \
			-set mesos.advertise_port="5051" 
		zinst i docker_compose logspout_logstash_container haproxy monit_haproxy haproxy_marathon_bridge monit_logspout_container -stable
		zinst i monit_haproxy_marathon_bridge -stable 
	else 
		zinst i mesos marathon oracle_jdk8  -stable -set mesos.role="$role" \
			-set mesos.server_id="1" \
			-set mesos.quorum="1" 
	fi

## Global setting
zinst set mesos.advertise_ip="$adv_ip" \
	-set mesos.zk_nodes="$master_ip" \
	-set mesos.Port="5051" \
	-set mesos.zk_ports="2181,2182" \
	-set mesos.zoo_port="2888:3888" 
zinst i monit_mesos \
	monit_rootfs \
	monit_docker -stable


/etc/init.d/mesos
zinst start mesos
zinst start haproxy logspout monit
