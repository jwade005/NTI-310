#!bin/bash

#nfs install centos7 server

#allow services through the firewall

sudo firewall-cmd --permanent --zone=public --add-service=ssh
sudo firewall-cmd --permanent --zone=public --add-service=nfs
sudo firewall-cmd --reload

#install nfs
sudo yum -y install nfs-utils

#start nfs server and services
sudo systemctl enable nfs-server.service
sudo systemctl start nfs-server.service

#make directories and adjust ownership and permissions
sudo mkdir /var/dev
sudo chown nfsnobody:nfsnobody /var/dev
sudo chmod 755 /var/dev

sudo mkdir /var/config
sudo chown nfsnobody:nfsnobody /var/config
sudo chmod 755 /var/config

#adjust /etc/exports to allow sharing of folders ***must use internal IPs***
#sudo vi /etc/exports
#add these lines       ***use sed--add uncommented lines-empty file***
#/home           10.128.0.3(rw,sync,no_root_squash,no_subtree_check)
#/var/dev        10.128.0.3(rw,sync,no_subtree_check)
#/var/config        10.128.0.3(rw,sync,no_subtree_check)

#make changes take effect
sudo exportfs -a
