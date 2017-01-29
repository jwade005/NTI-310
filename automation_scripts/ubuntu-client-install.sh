#!/bin/bash

#this is a working copy of the ubuntu client automation script
#it will be updated throughout the quarter as we add services
#use with caution

#install gnome-shell
sudo apt-get --yes install gnome-shell && sudo apt-get --yes install ubuntu-gnome-desktop

#update ubuntu
sudo apt-get --yes update && sudo apt-get --yes upgrade && sudo apt-get --yes dist-upgrade

#isntall ldap client
sudo apt-get --yes install libpam-ldap nscd


#configure ldap client
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
#sudo dpkg-reconfigure ldap-auth-config

#edit the /etc/nsswitch.conf file - add 'ldap' to these lines
sudo vi /etc/nsswitch.conf #---use sed command

#passwd:         ldap compat
#group:          ldap compat
#shadow:         ldap compat


#edit the PAM config file - /etc/pam.d/common-session
sudo vi /etc/pam.d/common-session #---use sed command

#add this line to the bottom of the config file
#session required    pam_mkhomedir.so skel=/etc/skel umask=0022

#restart the nscd service
sudo /etc/init.d/nscd restart

#edit the sudoers file to give sudo access to the admin group in ldap
sudo visudo

#comment out this line
#%admin ALL=(ALL) ALL #---use sed command

#adjust the ssh config file for the ubuntu-desktop instance /etc/ssh/sshd_config
sudo vi /etc/ssh/sshd_config #---use sed command
#comment out these two lines
#PasswordAuthentication no
#ChallengeResponseAuthentication no

#restart the sshd service
sudo systemctl restart sshd.service

#login as ldap user on the ubuntu-desktop!
#command from terminal: ssh <username>@<ubuntuIPaddress>
#enter user password defined in phpldapadmin
