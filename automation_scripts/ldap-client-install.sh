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
apt-get --yes install libnss-ldap libpam-ldap ldap-utils nslcd
unset DEBIAN_FRONTEND

echo "Cloning jwade005's NTI-310 GitHub..."
git clone https://github.com/jwade005/NTI-310.git /tmp/NTI-310
git config --global user.name "jwade005"
git config --global user.email "jwade005@seattlecentral.edu"


cp /tmp/NTI-310/config_scripts/ldap.conf /etc/ldap.conf <-- ***adjust ldap.conf for ladps:/// and port 636
cp /tmp/NTI-310/config_scripts/nslcd.conf /etc/nslcd.conf
sed -i -e '$aTLS_REQCERT allow' /etc/ldap/ldap.conf
sed -i 's,#BASE   dc=example\,dc=com,BASE	dc=jwade\,dc=local,g' /etc/ldap/ldap.conf
sed -i 's,##URI	ldap:\/\/ldap.example.com ldap:\/\/ldap-master.example.com:666,URI	ldaps:\/\/10.128.0.2'

#edit the /etc/nsswitch.conf file - add 'ldap' to these lines
#vi /etc/nsswitch.conf #---use sed command

sed -i 's,passwd:         compat,passwd:         ldap compat,g' /etc/nsswitch.conf
#sed -i 's,passwd:         compat,passwd:         ldap compat' /etc/nsswitch.conf #*****FIX THIS
sed -i 's,group:          compat,group:          ldap compat,g' /etc/nsswitch.conf
#sed -i 's,group:          compat,group:          ldap compat' /etc/nsswitch.conf #*****FIX THIS
sed -i 's,shadow:         compat,shadow:         ldap compat,g' /etc/nsswitch.conf
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
