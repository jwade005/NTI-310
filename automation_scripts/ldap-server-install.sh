#!/bin/bash

yum -y install git
git clone https://github.com/jwade005/NTI-310.git
git config --global user.name "jwade005"
git config --global user.email "jwade005@seattlecentral.edu"

yum -y install openldap-servers openldap-clients

cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG 
chown ldap. /var/lib/ldap/DB_CONFIG

systemctl enable slapd
systemctl start slapd

yum -y install httpd

systemctl enable httpd 
systemctl start httpd 

yum -y install epel-release
yum -y install phpldapadmin

setsebool -P httpd_can_connect_ldap on

cd /etc/openldap/slapd.d

cp /nti-310/config_scripts/dn.ldif /etc/openldap/slapd.d/db.ldif

sudo ldapmodify -Y EXTERNAL  -H ldapi:/// -f db.ldif
sleep 5

cp /nti-310/config_scripts/monitor.ldif /etc/openldap/slapd.d/monitor.ldif

sudo ldapmodify -Y EXTERNAL  -H ldapi:/// -f monitor.ldif
sleep 5

sudo cp /nti-310/config_scripts/create_ldap_ssl.sh /etc/openldap/certs/create_ldap_ssl.sh
sudo ./etc/openldap/certs/create_ldap_ssl.sh

echo "Key and Cert created in /etc/openldap/certs"

sudo chown -R ldap:ldap /etc/openldap/certs/*.pem
sudo ll /etc/openldap/certs/*.pem

sudo cp /nti-310/config_scripts/certs.ldif /etc/openldap/slapd.d/certs.ldif
sudo ldapmodify -Y EXTERNAL  -H ldapi:/// -f certs.ldif





