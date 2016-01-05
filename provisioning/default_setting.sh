#!/bin/bash
# Script for Default env. of zinst
#!/bin/bash
input_arry=($@)
	Countx=0
	while [ $Countx -lt  ${#input_arry[@]} ] ;do
		case "${input_arry[$Countx]}" in
		type*)
			type=`echo "${input_arry[$Countx]}" | awk -F'=' '{print $2}'`
			;;
		ip*)
			ip=`echo "${input_arry[$Countx]}" | awk -F'=' '{print $2}'`
			;;
		host*)
			host=`echo "${input_arry[$Countx]}" | awk -F'=' '{print $2}'`
			;;
		dns*)
			dns=`echo "${input_arry[$Countx]}" | awk -F'=' '{print $2}'`
			;;
		http_proxy*)
			http_proxy=`echo "${input_arry[$Countx]}" | awk -F'=' '{print $2}'`
			;;
		esac
	let Countx=$Countx+1
	done


LANG=en_US.UTF-8
sed -i '/^LANG=/d' /etc/sysconfig/i18n
echo 'LANG=en_US.UTF-8' >> /etc/sysconfig/i18n
sed -i 's/=enforcing/=disabled/g' /etc/selinux/config

	if [[ $dns != "" ]];then
		cat <<EOF > /etc/resolv.conf
nameserver $dns
EOF
	fi 

setenforce 0

curl -sL http://bit.ly/online-install |sh
	if [[ $type != "file" ]];then
		/usr/bin/zinst self-conf ip=$ip host=$host
	fi
zinst self-update
zinst i server_default_setting -stable
zinst i gsshop_account_policy -stable

	if [[ $http_proxy != "" ]];then
		/usr/bin/zinst i proxyctl -stable 
		 /usr/bin/zinst set proxyctl.HTTP="$http_proxy" -set proxyctl.HTTPS="$http_proxy"
		/data/z/etc/init.d/proxyctl start
		bash -l
	fi

	if [[ $dns != "" ]];then
		zinst set server_default_setting.name1=$dns
		/data/bin/nameserver.sh
	fi 

zinst i monit -stable


