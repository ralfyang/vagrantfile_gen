#!/bin/bash
### Script for consul env. for each other
role=$1
Start_join=$2

## Server or Client
zinst  i gsshop_authorize_client  -stable
zinst  i user_consul  consul -stable -set consul.rule="$role" -set consul.start_join="$Start_join"
zinst start consuld
	if [[ $role = "bootstrap" ]];then
		ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
	fi
zinst  i monit_rootfs -stable

