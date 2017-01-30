#!/bin/bash

#this script installs the ubuntu client side of nfs and mounts the volumes

#install the nfs client packages
sudo apt-get -y install nfs-common nfs-kernel-server
sudo service nfs-kernel-server start

#create mount directories
sudo mkdir -p /mnt/nfs/home
sudo mkdir -p /mnt/nfs/var/dev
sudo mkdir -p /mnt/nfs/var/config

#start the mapping service
sudo service nfs-idmapd start

#mount the volumes
sudo mount -v -t nfs 10.128.0.4:/home /mnt/nfs/home
sudo mount -v -t nfs 10.128.0.4:/var/dev /mnt/nfs/var/dev
sudo mount -v -t nfs 10.128.0.4:/var/config /mnt/nfs/var/config

#verify the mount
df -h

#automount /home directory from a NFS server when user logging in

#install autofs
#sudo apt-get -y install autofs

#edit /etc/auto.master
#sudo sed -i '$ a\  /home         /etc/auto.home' /etc/auto.master           #add this line to EOF----use sed

#create and write to /etc/auto.home
#sudo touch /etc/auto.home
#sudo chmod 777 /etc/auto.home
#sudo echo "*          10.128.0.4:/export/home/&" >> /etc/auto.home

#start autofs to enable the configuration
#/etc/init.d/autofs start
