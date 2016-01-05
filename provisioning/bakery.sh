#!/bin/bash
### Script for Bakery env. for each other
bakery_type=$1

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

curl http://10.53.15.219:8500/v1/kv/management-general/bakery/ssh-key?raw -o /root/.ssh/id_rsa -o /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa

cat << EOF >> ~/.ssh/known_hosts
gitlab.com,104.210.2.228 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsj2bNKTBSpIYDEGk9KxsGh3mySTRgMtXL583qmBpzeQ+jqCMRgBqB98u3z++J1sKlXHWfM9dyhSevkMwSbhoR8XIq/U0tCNyokEi/ueaBMCvbcTHhO7FcwzY92WK4Yt0aGROY5qX2UKSeOvuP4D6TPqKF1onrSzH9bx9XUf2lEdWT/ia1NEKjunUqu1xOB/StKDHMoX4/OKyIzuS0q/T1zOATthvasJFoPrAjkohTyaDUz2LN5JoH839hViyEG82yB+MjcFV5MU3N1l1QL3cVUCh93xSaua1N85qivl+siMkPGbO5xR/En4iEY6K2XPASUEMaieWVNTRCtJ4S8H+9
EOF


## Git tool install
zinst i git_64 -stable

## Make a Git directory
mkdir /root/Git/
cd /root/Git/
git clone git@gitlab.com:iic/gravity-bakery.git

## Docker install for CentOS
zinst i libcgroup-0.4.0.zinst linux_kernel-3.10.25.zinst docker_engine-1.7.1.zinst -stable
chkconfig --add docker
echo "====== Please waiting 3 mins. for this server reboot with kernel upgrade ======"
echo ""
reboot
