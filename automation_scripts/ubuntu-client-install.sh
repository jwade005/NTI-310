#!/bin/bash

#this is a working copy of the ubuntu client automation script
#it will be updated throughout the quarter as we add services
#use with caution

#run as root

#update ubuntu
apt-get --yes update && apt-get --yes upgrade && apt-get --yes dist-upgrade

#isntall ldap client

export DEBIAN_FRONTEND=noninteractive       #******how to skip the autoconfig*******
#apt-get --yes install libpam-ldap nscd  #ldap-auth-client
apt-get --yes install libnss-ldap libpam-ldap ldap-utils nslcd debconf-utils
unset DEBIAN_FRONTEND

echo "Cloning jwade005's NTI-310 GitHub..."
git clone https://github.com/jwade005/NTI-310.git /tmp/NTI-310
git config --global user.name "jwade005"
git config --global user.email "jwade005@seattlecentral.edu"

#adjust /etc/ldap/ldap.conf file for ip address and fqdn
ip1=$(gcloud compute instances list | grep ldap-server | awk '{print $4}')
sed -i "s,#URI\tldap:\/\/ldap.example.com ldap:\/\/ldap-master.example.com:666,URI\tldaps:\/\/$ip1,g" /etc/ldap/ldap.conf
sed -i 's/#BASE\tdc=example,dc=com/BASE\tdc=jwade,dc=local/g' /etc/ldap/ldap.conf
sed -i -e '$aTLS_REQCERT allow' /etc/ldap/ldap.conf

#cp /tmp/NTI-310/config_scripts/debconf /etc/debconf
#sed -i "s,ldap-auth-config        ldap-auth-config\/ldapns\/ldap-server     string  ldaps:\/\/NEEDTOADDIP\/,ldap-auth-config        ldap-auth-config/ldapns/ldap-server     string  ldaps:\/\/$ip1\/,g" /etc/debconf
#sed -i "s,nslcd   nslcd/ldap-uris string  ldaps://NEEDTOADDIP/,nslcd   nslcd/ldap-uris string  ldaps://$ip1/,g" /etc/debconf

#while read line; do echo "$line" | debconf-set-selections; done < /etc/debconf

cp /tmp/NTI-310/config_scripts/ldap.conf /etc/ldap.conf #<-- ***adjust ldap.conf for ladps:/// and port 636
sed -i "s,uri ldaps:\/\/NEEDTOADDIP\/,uri ldaps:\/\/$ip1\/,g" /etc/ldap.conf
cp /tmp/NTI-310/config_scripts/nslcd.conf /etc/nslcd.conf
sed -i "s,uri ldaps:\/\/NEEDTOADDIP\/,uri ldaps:\/\/$ip1\/,g" /etc/nslcd.conf

#edit the /etc/nsswitch.conf file - add 'ldap' to these lines
#vi /etc/nsswitch.conf #---use sed command

sed -i 's,passwd:         compat,passwd:         compat ldap,g' /etc/nsswitch.conf
#sed -i 's,passwd:         compat,passwd:         ldap compat' /etc/nsswitch.conf #*****FIX THIS
sed -i 's,group:          compat,group:          compat ldap,g' /etc/nsswitch.conf
#sed -i 's,group:          compat,group:          ldap compat' /etc/nsswitch.conf #*****FIX THIS
sed -i 's,shadow:         compat,shadow:         compat ldap,g' /etc/nsswitch.conf
#sed -i 's,shadow:         compat,shadow:         ldap compat' /etc/nsswitch.conf #*****FIX THIS

#add this line to the bottom of the config file
sed -i '$ a\session required    pam_mkhomedir.so skel=/etc/skel umask=0022' /etc/pam.d/common-session

#restart the nslcd service
/etc/init.d/nslcd restart

#edit the sudoers file to give access to the admin group in ldap
#visudo

#comment out this line
sed -i 's,%admin=(ALL) ALL,#%admin ALL=(ALL) ALL,g' /etc/sudoers    #---use sed command

#adjust the ssh config file for the ubuntu-desktop instance /etc/ssh/sshd_config
#vi /etc/ssh/sshd_config #---use sed command
#comment out these two lines

#PasswordAuthentication no
sed -i 's,PasswordAuthentication no,#PasswordAuthentication no,g' /etc/ssh/sshd_config
#ChallengeResponseAuthentication no
sed -i 's,ChallengeResponseAuthentication no,#ChallengeResponseAuthentication no,g' /etc/ssh/sshd_config

#restart the sshd service
systemctl restart sshd.service

#login as ldap user on the ubuntu-desktop!
#command from terminal: ssh <username>@<ubuntuIPaddress>
#enter user password defined in phpldapadmin


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
sudo mount -v -t nfs nfs-server:/home /mnt/nfs/home
sudo mount -v -t nfs nfs-server:/var/dev /mnt/nfs/var/dev
sudo mount -v -t nfs nfs-server:/var/config /mnt/nfs/var/config

#make changes mounting the nfs volumes permanent by editing fstab
sudo echo "nfs-server:/home            /mnt/nfs/home           nfs     defaults 0 0" >> /etc/fstab
sudo echo "nfs-server:/var/dev         /mnt/nfs/var/dev        nfs     defaults 0 0" >> /etc/fstab
sudo echo "nfs-server:/var/config      /mnt/nfs/var/config     nfs     defaults 0 0" >> /etc/fstab

#install tree to verify mount
apt-get -y install tree

#verify the mount
df -h
tree /mnt

#rsyslog client-side configuration -- run as root
#must be run on each rsyslog client
ip=$(gcloud compute instances list | grep rsyslog-server | awk '{print $4}')

echo "*.info;mail.none;authpriv.none;cron.none    @$ip" >> /etc/rsyslog.conf

#sudo echo "*.info;mail.none;authpriv.none;cron.none    @rsyslog-server" >> /etc/rsyslog.conf
sudo service rsyslog restart                                     #ubuntu command
