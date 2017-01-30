#!/bin/bash

#this script installs the ubuntu client side of nfs and mounts the volumes

#install the nfs client packages
sudo apt-get -y install nfs-common nfs-kernel-server
sudo service nfs-kernel-server start

#sudo vi /etc/idmapd.conf
#uncomment line 6 and change to Domain = jwade.local

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
