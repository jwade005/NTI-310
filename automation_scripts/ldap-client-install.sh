#!/bin/bash

#this is a working copy of the ubuntu client automation script
#it will be updated throughout the quarter as we add services
#use with caution

#run as root

#install gnome-shell
apt-get --yes install gnome-shell && apt-get --yes install ubuntu-gnome-desktop

#update ubuntu
apt-get --yes update && apt-get --yes upgrade && apt-get --yes dist-upgrade

#isntall ldap client
apt-get --yes install libpam-ldap nscd

#******how to skip the autoconfig?*******

#configure ldap client
#use sed to add config lines to /etc/ldap.conf
#sed '1 a\base dc=jwade,dc=local' /etc/ldap.conf
#sed '2 a\uri ldap://104.197.215.83/' /etc/ldap.conf
#sed '3 a\ldap_version 3' /etc/ldap.conf
#sed '4 a\pam_password md5' /etc/ldap.conf


#LDAP server Uniform Resource Identifier: ldap://104.197.215.83

#Change the initial string from "ldapi:///" to "ldap://" before inputing your server's information
#Distinguished name of the search base:

#This should match the value you put in your LDAP server's /etc/phpldapadmin/config.php file.
#Search for: " 'server','base',array " within the file.
#dc=jwade,dc=local

#LDAP version to use: 3

#Make local root Database admin: No

#Does the LDAP database require login? No

#if you make a mistake and need to run the configuration again, use this command
#dpkg-reconfigure ldap-auth-config

#edit the /etc/nsswitch.conf file - add 'ldap' to these lines
vi /etc/nsswitch.conf #---use sed command

#sed -i 's,passwd:         compat,passwd:         ldap compat' /etc/nsswitch.conf #*****FIX THIS
#sed -i 's,group:          compat,group:          ldap compat' /etc/nsswitch.conf #*****FIX THIS
#sed -i 's,shadow:         compat,shadow:         ldap compat' /etc/nsswitch.conf #*****FIX THIS
#passwd:         ldap compat
#group:          ldap compat
#shadow:         ldap compat


#edit the PAM config file - /etc/pam.d/common-session
#vi /etc/pam.d/common-session #---use sed command

#add this line to the bottom of the config file
sed '$ a\session required    pam_mkhomedir.so skel=/etc/skel umask=0022' /etc/pam.d/common-session

#restart the nscd service
/etc/init.d/nscd restart

#edit the sudoers file to give access to the admin group in ldap
#visudo

#comment out this line
sed -i 's,%admin=(ALL) ALL,#%admin ALL=(ALL) ALL' /etc/sudoers    #---use sed command

#adjust the ssh config file for the ubuntu-desktop instance /etc/ssh/sshd_config
#vi /etc/ssh/sshd_config #---use sed command
#comment out these two lines
sed -i 's,PasswordAuthentication no,#PasswordAuthentication no' /etc/ssh/sshd_config
#ChallengeResponseAuthentication no

#restart the sshd service
systemctl restart sshd.service

#login as ldap user on the ubuntu-desktop!
#command from terminal: ssh <username>@<ubuntuIPaddress>
#enter user password defined in phpldapadmin
