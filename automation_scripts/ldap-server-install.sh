#!/bin/bash

#ldap server-sdie install script -- run as root

#install git

echo "Installing git..."
yum -y install git

echo "Cloning jwade005's NTI-310 GitHub..."
git clone https://github.com/jwade005/NTI-310.git /tmp/NTI-310
git config --global user.name "jwade005"
git config --global user.email "jwade005@seattlecentral.edu"

#make NTI-310 directory accessible
#chmod -R 777 /home/Jonathan/NTI-310

#install ldap

echo "Installing openldap-servers... openldap-clients..."
yum -y install openldap-servers openldap-clients

#copy db config, change ownership

echo "Copying config file and adjusting permissions..."
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
chown ldap /var/lib/ldap/DB_CONFIG

#enable and start ldap

echo "Enabling and Starting the slapd service..."
systemctl enable slapd
systemctl start slapd

#install apache

echo "Installing apache..."
yum -y install httpd

#enable and start apache

echo "Enabling and starting the httpd service..."
systemctl enable httpd
systemctl start httpd

#install phpldapadmin

echo "Installin the epel-release repo..."
yum -y install epel-release

echo "Installing phpldapadmin..."
yum -y install phpldapadmin

#allow http connection to ldap

echo "Allowing ldap to use httpd..."
setsebool -P httpd_can_connect_ldap on
sleep 5

#generate new hashed password for db.ldif and store it on the server
newsecret=$(slappasswd -g)
newhash=$(slappasswd -s "$newsecret")
echo -n "$newsecret" > /root/ldap_admin_pass

chmod 600 /root/ldap_admin_pass

#copy db.ldif and add to config

echo "echo db.ldif and adding it to ldap configuration..."
#cp /tmp/NTI-310/config_scripts/db.ldif /etc/openldap/slapd.d/db.ldif
echo "dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=jwade,dc=local

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=ldapadm,dc=jwade,dc=local

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: $newhash" >> /etc/openldap/slapd.d/db.ldif

ldapmodify -Y EXTERNAL  -H ldapi:/// -f /etc/openldap/slapd.d/db.ldif
sleep 5

#copy monitor.ldif and add to config

echo "Copying monitor.ldif, adjusting ownership, and adding it to ldap configuration..."
cp /tmp/NTI-310/config_scripts/monitor.ldif /etc/openldap/slapd.d/monitor.ldif
chown ldap. /etc/openldap/slapd.d/monitor.ldif

ldapmodify -Y EXTERNAL  -H ldapi:/// -f /etc/openldap/slapd.d/monitor.ldif
sleep 5

#create ssl cert

yum -y install mod_ssl

mkdir /etc/ssl/private
chmod 700 /etc/ssl/private
openssl req -new -x509 -nodes -out /etc/openldap/certs/jwadeldapcert.crt -newkey rsa:2048 -keyout /etc/openldap/certs/jwadeldapkey.key -days 365 -subj "/C=US/ST=WA/L=Seattle/O=IT/OU=NTI310IT/CN=jwade.local"
/etc/ssl/certs/apache-selfsigned.crt
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
cat /etc/ssl/certs/dhparam.pem | tee -a /etc/ssl/certs/apache-selfsigned.crt

#modify /etc/httpd/conf.d/ssl.conf

sed  -i '/<VirtualHost _default_:443>/a Alias \/phpldapadmin \/usr\/share\/phpldapadmin\/htdocs' /etc/httpd/conf.d/ssl.conf
sed  -i '/Alias \/phpldapadmin \/usr\/share\/phpldapadmin\/htdocs/a Alias \/ldapadmin \/usr\/share\/phpldapadmin\/htdocs' /etc/httpd/conf.d/ssl.conf
sed  -i '/Alias \/ldapadmin \/usr\/share\/phpldapadmin\/htdocs/a DocumentRoot \"\/usr\/share\/phpldapadmin\/htdocs\"' /etc/httpd/conf.d/ssl.conf
sed  -i '/DocumentRoot \"\/usr\/share\/phpldapadmin\/htdocs\"/a ServerName ldap:443' /etc/httpd/conf.d/ssl.conf

#update cypher suite
sed -i "s/SSLProtocol all -SSLv2/#SSLProtocol all -SSLv2/g" /etc/httpd/conf.d/ssl.conf
sed -i "s/SSLCipherSuite HIGH:MEDIUM:\!aNULL:\!MD5:\!SEED:\!IDEA/#SSLCipherSuite HIGH:MEDIUM:\!aNULL:\!MD5:\!SEED:\!IDEA/g" /etc/httpd/conf.d/ssl.conf

cat <<EOT>> /etc/httpd/conf.d/ssl.conf
# Begin copied text
# from https://cipherli.st/
# and https://raymii.org/s/tutorials/Strong_SSL_Security_On_Apache2.html

SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH
SSLProtocol All -SSLv2 -SSLv3
SSLHonorCipherOrder On
# Disable preloading HSTS for now.  You can use the commented out header line that includes
# the "preload" directive if you understand the implications.
#Header always set Strict-Transport-Security "max-age=63072000; includeSubdomains; preload"
Header always set Strict-Transport-Security "max-age=63072000; includeSubdomains"
Header always set X-Frame-Options DENY
Header always set X-Content-Type-Options nosniff
# Requires Apache >= 2.4
SSLCompression off
SSLUseStapling on
SSLStaplingCache "shmcb:logs/stapling-cache(150000)"
# Requires Apache >= 2.4.11
# SSLSessionTickets Off
EOT

#restart the httpd service
systemctl restart httpd

#copy cert ldif and add to config

echo "Copying cert.ldif and adding it to ldap configuration..."
cp /tmp/NTI-310/config_scripts/certs.ldif /etc/openldap/slapd.d/certs.ldif
ldapmodify -Y EXTERNAL  -H ldapi:/// -f /etc/openldap/slapd.d/certs.ldif

#add the cosine and nis LDAP schemas

echo "Adding the cosine and nis schemas..."
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif

#create base.ldif file for domain

echo "Copying the base.ldif file for the domain and adding it to ldap configuration..."
cp /tmp/NTI-310/config_scripts/base.ldif /etc/openldap/slapd.d/base.ldif
ldapadd -x -D "cn=ldapadm,dc=jwade,dc=local" -f /etc/openldap/slapd.d/base.ldif -y /root/ldap_admin_pass
#ldapadd -W -x -D "cn=ldapadm,dc=jwade,dc=local" -f /etc/openldap/slapd.d/base.ldif

#allow cn=xxx,dc=xxx,dc=xxx login

echo "Setting login to fqdn..."
cp -f /tmp/NTI-310/config_scripts/config.php /etc/phpldapadmin/config.php

#allow login from the web

echo "Making ldap htdocs accessible from the web..."
cp -f /tmp/NTI-310/config_scripts/phpldapadmin.conf /etc/httpd/conf.d/phpldapadmin.conf

#restart htttpd, slapd services

echo "Restarting the httpd and slapd services..."
systemctl restart httpd
systemctl restart slapd

#configure firewall to allow access

echo "Configuring the built-in firewall to allow access..."
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --reload

echo "ldap configuration complete. Point your browser to http://<serverIPaddress>/phpldapadmin to login..."
