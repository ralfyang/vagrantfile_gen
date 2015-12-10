#!/bin/bash
consul="10.53.15.219"

consul_url="http://$consul:8500/v1/kv/hypervisors"
hostfile_dir="./host"

conf_dir="./conf"


Vagrantfile_base="./service"


rm -Rf $Vagrantfile_base/*

Conf_create(){
input_type=$1

	if [[ $input_type = "file" ]];then
		host_list=(`ls $hostfile_dir | sed -e 's#\.list##g'`)
	elif [[ $input_type = "consul" ]];then
		host_list=(`curl -s $consul_url/hosts?raw`)
	fi

	Count=0
	while [ $Count -lt ${#host_list[@]} ];do
		mkdir -p $Vagrantfile_base/${host_list[$Count]}
		output_file="$Vagrantfile_base/${host_list[$Count]}/vagrant.out"
		result_file="$Vagrantfile_base/${host_list[$Count]}/Vagrantfile"

		## IP range listup by each hosts
		if [[ $input_type = "file" ]];then
			cat $hostfile_dir/${host_list[$Count]}.list | sed -e 's/[0-9]x/&{i}/g' -e 's/x{/#{/g' > $output_file
		elif [[ $input_type = "consul" ]];then
			curl  -s $consul_url/${host_list[$Count]}/data?raw  | sed -e 's/[0-9]x/&{i}/g' -e 's/x{/#{/g' > $output_file
        	fi
        
		## Start to stamping for vagrant export
		echo "cat << EOF > $result_file" >> $output_file
        
		## Vagrant basic script export
		cat << EOF >> $output_file
# -*- mode: ruby -*-
# vi: set ft=ruby :


# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.a

# Script for Default env. of zinst
\\\$script = <<SCRIPT
LANG=en_US.UTF-8
sed -i '/^LANG=/d' /etc/sysconfig/i18n
echo 'LANG=en_US.UTF-8' >> /etc/sysconfig/i18n
sed -i 's/=enforcing/=disabled/g' /etc/selinux/config
setenforce 0
curl -sL http://bit.ly/online-install |sh
/usr/bin/zinst self-conf ip=\$zisnt_repo_ip host=\$zisnt_repo_host
zinst self-update
zinst i server_default_setting gsshop_account_policy -stable
zinst i monit -stable
SCRIPT



VAGRANTFILE_API_VERSION = "2"
NODE_COUNT = 10
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
EOF

		## Each configuration export
		cat $conf_dir/*.conf >> $output_file
		cat << EOF >> $output_file
    config.vm.provider "libvirt" do |libvirt|
      libvirt.driver = "kvm"
      libvirt.memory = 1024
      libvirt.cpus = 1
      libvirt.uri = "qemu+tcp://\$hypervisor_ip/system"
      libvirt.host = "\$hypervisor_ip"
    end
end
EOF

		## Close export script
		echo "EOF" >> $output_file
		chmod 755 $output_file
		./$output_file
		rm -f $output_file
        
#		cat $result_file
        
	let Count=$Count+1
	done
}

Conf_create file
Conf_create consul


echo "  --- Vagrantfile has been created in each service directory. \"$Vagrantfile_base\" as below ---"
tree $Vagrantfile_base
