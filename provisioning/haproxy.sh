#!/bin/bash
### Script for HAproxy package[master / slave]
role=$1
	if [[ $role = "master" ]];then
		zinst i haproxy -stable
	else
		zinst i haproxy haproxy_marathon_bridge -stable
	fi
