#!/bin/bash
consul="10.53.15.219"

consul_url="http://$consul:8500/v1/kv/hypervisors"
hostfile_dir="./host"

conf_dir="./conf"


Vagrantfile_base="./service"
host_keydir="/data/var/vagrant"

sudo rm -Rf $Vagrantfile_base/*

Conf_create(){
input_type=$1

	if [[ $input_type = "file" ]];then
		host_list=(`ls $hostfile_dir | sed -e 's#\.list##g'`)
	elif [[ $input_type = "consul" ]];then
		host_list_json=`curl -sL http://10.53.15.219:8500/v1/kv/hypervisors?keys`
		host_list=(`echo  "$host_list_json" |sed -e 's/\[\(.*\)\]/\1/g' -e 's/,/ /g' -e 's/"//g'`)
		
			Hcount=0
			while [ $Hcount -lt ${#host_list[@]} ];do
				host_list[$Hcount]=`echo "${host_list[$Hcount]}" | awk -F '/' '{print $(NF-1)}'`
			let Hcount=$Hcount+1
			done
		host_list=(`echo "${host_list[@]}" | sed -e 's/hypervisors//g' | xargs -n1 | sort -u | xargs`)
	fi

	Count=0
	while [ $Count -lt ${#host_list[@]} ];do
		mkdir -p $Vagrantfile_base/${host_list[$Count]}
		output_file="$Vagrantfile_base/${host_list[$Count]}/vagrant.out"
		result_file="$Vagrantfile_base/${host_list[$Count]}/Vagrantfile"

		## IP range listup by each hosts
		if [[ $input_type = "file" ]];then
			echo "#!/bin/bash" > $output_file
			cat $hostfile_dir/${host_list[$Count]}.list | sed -e 's/[0-9]x/&{i}/g' -e 's/x{/#{/g' >> $output_file
		elif [[ $input_type = "consul" ]];then
			echo "#!/bin/bash" > $output_file
			curl -s "$consul_url/${host_list[$Count]}/data?raw"  | sed -e 's/[0-9]x/&{i}/g' -e 's/x{/#{/g' >> $output_file
			sudo mkdir -p $host_keydir
			sudo curl -s "$consul_url/${host_list[$Count]}/ssh-key?raw" -o $host_keydir/${host_list[$Count]}.key
        	fi
        
		## Start to stamping for vagrant export
		echo "" >> $output_file
		cat << EOF >>  $output_file
	if [[ \$zisnt_repo_ip = "" ]];then
		zisnt_repo_ip="10.52.164.254"
	fi
	if [[ \$zisnt_repo_host = "" ]];then
		zisnt_repo_host="package.dist.gsenext.com"
	fi
EOF
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
  config.vm.provision "shell", inline: \\\$script
EOF

		## Each configuration export
		cat $conf_dir/*.conf >> $output_file
		cat << EOF >> $output_file
    config.ssh.insert_key = "false"
    config.vm.provider "libvirt" do |libvirt|
    config.vm.synced_folder ".", "/vagrant", disabled: true
      libvirt.id_ssh_key_file = "$host_keydir/${host_list[$Count]}.key"
      libvirt.driver = "kvm"
      libvirt.memory = 8196
      libvirt.cpus = 8
      libvirt.host = "\$hypervisor_ip"
      libvirt.username = "root"
      libvirt.connect_via_ssh = "true"
    end
end
EOF

		## Close export script
		echo "EOF" >> $output_file
		sudo chmod 755 $output_file

		./$output_file
		sudo rm -f $output_file
        
#		cat $result_file
        
	let Count=$Count+1
	done
}

Conf_create file
Conf_create consul


echo "  --- Vagrantfile has been created in each service directory. \"$Vagrantfile_base\" as below ---"
tree $Vagrantfile_base
