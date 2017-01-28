#this is a working copy of the ubuntu-ldap-client automation script

sudo apt-get update
sudo apt-get install libpam-ldap nscd

#configure ldap client
#LDAP server Uniform Resource Identifier: ldap://104.199.116.113

#Change the initial string from "ldapi:///" to "ldap://" before inputing your server's information
#Distinguished name of the search base:

#This should match the value you put in your LDAP server's /etc/phpldapadmin/config.php file.
#Search for: " 'server','base',array " within the file.
#dc=jwade,dc=local

#LDAP version to use: 3

#Make local root Database admin: Yes

#Does the LDAP database require login? No

#LDAP account for root:

#This should also match the value in your /etc/phpldapadmin/config.php.
#Search for: " 'login','bind_id' " within the file
#cn=ldapadm,dc=jwade,dc=local

#LDAP root account password: Your-LDAP-root-password

#if you make a mistake and need to run the configuration again, use this command
#sudo dpkg-reconfigure ldap-auth-config

#edit the /etc/nsswitch.conf file - add 'ldap' to these lines
sudo vi /etc/nsswitch.conf

#passwd:         ldap compat
#group:          ldap compat
#shadow:         ldap compat


#edit the PAM config file - /etc/pam.d/common-session
sudo vi /etc/pam.d/common-session

#add this line to the bottom of the config file
#session required    pam_mkhomedir.so skel=/etc/skel umask=0022

#restart the nscd service
sudo /etc/init.d/nscd restart

#edit the sudoers file to give sudo access to the admin group in ldap
sudo visudo

#comment out this line
#%admin ALL=(ALL) ALL

#adjust the ssh config file for the ubuntu-desktop instance /etc/ssh/sshd_config
sudo vi /etc/ssh/sshd_config
#comment out these two lines
#PasswordAuthentication no
#ChallengeResponseAuthentication no

#restart the sshd service
sudo systemctl restart sshd.service

#login as ldap user on the ubuntu-desktop!


