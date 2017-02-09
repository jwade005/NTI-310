#!/bin/bash

#this script installs the ubuntu client side of nfs and mounts the volumes -- run as root

#install the nfs client packages
apt-get -y install nfs-common nfs-kernel-server
service nfs-kernel-server start

#create mount directories
mkdir -p /mnt/nfs/home
mkdir -p /mnt/nfs/var/dev
mkdir -p /mnt/nfs/var/config

#start the mapping service
service nfs-idmapd start

#mount the volumes
mount -v -t nfs 10.128.0.4:/home /mnt/nfs/home
mount -v -t nfs 10.128.0.4:/var/dev /mnt/nfs/var/dev
mount -v -t nfs 10.128.0.4:/var/config /mnt/nfs/var/config

#make changes mounting the nfs volumes permanent by editing fstab
echo "10.128.0.4:/home            /mnt/nfs/home           nfs     defaults 0 0" >> /etc/fstab
echo "10.128.0.4:/var/dev         /mnt/nfs/var/dev        nfs     defaults 0 0" >> /etc/fstab
echo "10.128.0.4:/var/config      /mnt/nfs/var/config     nfs     defaults 0 0" >> /etc/fstab

#verify the mount
df -h

#automount /home directory from a NFS server when user logging in

#install autofs
#apt-get -y install autofs

#edit /etc/auto.master
#sed -i '$ a\  /home         /etc/auto.home' /etc/auto.master           #add this line to EOF----use sed

#create and write to /etc/auto.home
#touch /etc/auto.home
#chmod 777 /etc/auto.home
#echo "*          10.128.0.4:/export/home/&" >> /etc/auto.home

#start autofs to enable the configuration
#/etc/init.d/autofs start
