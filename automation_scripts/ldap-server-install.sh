#!/bin/bash

#This script works but it will prompt for ldapadm password at base.ldif ldapadd
#use with caution   this is still a work in progress...
#replace parameters, github link, and config files with your own

#install git

sudo yum -y install git
sudo git clone https://github.com/jwade005/NTI-310.git /tmp/NTI-310
sudo git config --global user.name "jwade005"
sudo git config --global user.email "jwade005@seattlecentral.edu"

#make NTI-310 directory accessible
#sudo chmod -R 777 /home/Jonathan/NTI-310

#install ldap

sudo yum -y install openldap-servers openldap-clients

#copy db config, change ownership

sudo cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
sudo chown ldap. /var/lib/ldap/DB_CONFIG

#enable and start ldap

sudo systemctl enable slapd
sudo systemctl start slapd

#install apache

sudo yum -y install httpd

#enable and start apache

sudo systemctl enable httpd
sudo systemctl start httpd

#install phpldapadmin

sudo yum -y install epel-release
sudo yum -y install phpldapadmin

#allow http connection to ldap

sudo setsebool -P httpd_can_connect_ldap on
sleep 5

#copy db.ldif and add to config

sudo cp /tmp/NTI-310/config_scripts/db.ldif /etc/openldap/slapd.d/db.ldif

sudo ldapmodify -Y EXTERNAL  -H ldapi:/// -f /etc/openldap/slapd.d/db.ldif
sleep 5

#copy monitor.ldif and add to config

sudo cp /tmp/NTI-310/config_scripts/monitor.ldif /etc/openldap/slapd.d/monitor.ldif
sudo chown ldap. /etc/openldap/slapd.d/monitor.ldif

sudo ldapmodify -Y EXTERNAL  -H ldapi:/// -f /etc/openldap/slapd.d/monitor.ldif
sleep 5

#create ssl cert

sudo cp /tmp/NTI-310/config_scripts/create_ldap_ssl.sh /etc/openldap/certs/create_ldap_ssl.sh
sudo /etc/openldap/certs/create_ldap_ssl.sh

echo "Key and Cert created in /etc/openldap/certs"

#change ownership of certs and verify

sudo chown -R ldap:ldap /etc/openldap/certs/*.pem
sudo ll /etc/openldap/certs/*.pem

#copy cert ldif and add to config

sudo cp /tmp/NTI-310/config_scripts/certs.ldif /etc/openldap/slapd.d/certs.ldif
sudo ldapmodify -Y EXTERNAL  -H ldapi:/// -f /etc/openldap/slapd.d/certs.ldif

#add the cosine and nis LDAP schemas

sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif

#create base.ldif file for domain

sudo cp /tmp/NTI-310/config_scripts/base.ldif /etc/openldap/slapd.d/base.ldif
sudo ldapadd -x -W -D "cn=ldapadm,dc=jwade,dc=local" -f /etc/openldap/slapd.d/base.ldif

#......script stops here and prompts for ldap root password......


#grants connections from the web

sudo cp -f /tmp/NTI-310/config_scripts/phpldapadmin.php /etc/httpd/conf.d/phpldapadmin.php

#allow cd,dc,dc login

sudo cp -f /tmp/NTI-310/config_scripts/config.php /etc/phpldapadmin/config.php

#allow login from the web

sudo cp -f /tmp/NTI-310/config_scripts/phpldapadmin.conf /etc/httpd/conf.d/phpldapadmin.conf

#restart htttpd, slapd services

sudo systemctl restart httpd
sudo systemctl restart slapd

#configure firewall to allow access

sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --reload

#allow cd,dc,dc login
