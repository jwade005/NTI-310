#!/bin/bash

##caution   this is a work in progress

#install git

yum -y install git
git clone https://github.com/jwade005/NTI-310.git
git config --global user.name "jwade005"
git config --global user.email "jwade005@seattlecentral.edu"

#install ldap

yum -y install openldap-servers openldap-clients

#copy db config, change ownership

cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
chown ldap. /var/lib/ldap/DB_CONFIG

#enable and start ldap

systemctl enable slapd
systemctl start slapd

#install apache

yum -y install httpd

#enable and start apache

systemctl enable httpd
systemctl start httpd

#install phpldapadmin

yum -y install epel-release
yum -y install phpldapadmin

#allow http connection to ldap

setsebool -P httpd_can_connect_ldap on

#copy db.ldif and add to config

cp /nti-310/config_scripts/db.ldif /etc/openldap/slapd.d/db.ldif

sudo ldapmodify -Y EXTERNAL  -H ldapi:/// -f db.ldif
sleep 5

#copy monitor.ldif and add to config

cp /nti-310/config_scripts/monitor.ldif /etc/openldap/slapd.d/monitor.ldif

sudo ldapmodify -Y EXTERNAL  -H ldapi:/// -f monitor.ldif
sleep 5

#create ssl cert

sudo cp /nti-310/config_scripts/create_ldap_ssl.sh /etc/openldap/certs/create_ldap_ssl.sh
sudo ./etc/openldap/certs/create_ldap_ssl.sh

echo "Key and Cert created in /etc/openldap/certs"

#change ownership of certs and verify

sudo chown -R ldap:ldap /etc/openldap/certs/*.pem
sudo ll /etc/openldap/certs/*.pem

#copy cert ldif and add to config

sudo cp /nti-310/config_scripts/certs.ldif /etc/openldap/slapd.d/certs.ldif
sudo ldapmodify -Y EXTERNAL  -H ldapi:/// -f certs.ldif

#add the cosine and nis LDAP schemas

sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif

#create base.ldif file for domain

cp /nti-310/config_scripts/base.ldif /etc/openldap/slapd.d/base.ldif
sudo ldapadd -x -W -D "cn=ldapadm,dc=jwade,dc=local" -f base.ldif

#install tcl tk packages

sudo yum -y install tcl
sudo yum -y isntall tcl-devel

sudo yum -y install tk
sudo yum -y install tk-devel


#install exdpect package

tar -zxvf expect5.45.tar.gz
./expect5.45/configure

make
sudo make install && ln -svf expect5.45/libexpect5.45.so /usr/lib

#build the directory structure

sudo ldapadd -x -W -D "cn=ldapadm,dc=itzgeek,dc=local" -f base.ldif
./expect.exp
