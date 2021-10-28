#!/bin/bash
export DEBIAN_FRONTEND=noninteractive ;
set -eu ; # abort this script when a command fails or an unset variable is used.
#set -x ; # echo all the executed commands.

# Repair "==> default: stdin: is not a tty" message
sudo ex +"%s@DPkg@//DPkg" -cwq /etc/apt/apt.conf.d/70debconf ;
sudo dpkg-reconfigure debconf -f noninteractive -p critical ;

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update > /dev/null
if sudo apt-get install -yq docker-ce docker-ce-cli containerd.io 2>&1>/dev/null;then
	printf 'INSTALLED DOCKER\n';
else 
	printf 'ERROR IN DOCKER\n'
fi 


