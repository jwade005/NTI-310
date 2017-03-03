#!/bin/bash

#postgresql install script -- test -- work in progress

#install postgresql
sudo yum -y install epel-release-7
sudo yum -y install postgresql-server postgresql-contrib

echo "Installing git..."
sudo yum -y install git

echo "Cloning jwade005's NTI-310 GitHub..."
sudo git clone https://github.com/jwade005/NTI-310.git /tmp/NTI-310
sudo git config --global user.name "jwade005"
sudo git config --global user.email "jwade005@seattlecentral.edu"

#setup initial database cluster

sudo postgresql-setup initdb

#install and start Apache
sudo yum -y install httpd
sudo systemctl enable httpd
sudo systemctl start httpd

#make a firewall rule for postgres

sudo firewall-cmd --permanent --zone=public --add-service=postgresql
sudo firewall-cmd --reload


#enable and start the postgresql server

sudo systemctl start postgresql
sudo systemctl enable postgresql

#use postgres account to setup database

sudo cp /tmp/NTI-310/config_scripts/postgres.sql /var/lib/pgsql/postgres.sql
sudo -i -u postgres psql -U postgres -f /var/lib/pgsql/postgres.sql

#activate a postgres shell command prompt
#psql  #psql man pages for auotmation
#add a password for posgres user
#\password    <------ *****Don't forget to set the postgres user password!!*****
#create the database for django project1
#CREATE DATABASE project1;
#create a project1 user and password
#CREATE USER project1 WITH PASSWORD 'P@ssw0rd1';
#configure project1 users settings
#ALTER ROLE project1 SET client_encoding TO 'utf8';
#ALTER ROLE project1 SET default_transaction_isolation TO 'read committed';
#ALTER ROLE project1 SET timezone TO 'UTC';
#give database user project1 access rights to the database project1
#GRANT ALL PRIVILEGES ON DATABASE project1 TO project1;
#command \conninfo will give you connection info in the sql prompt
#exit the sql prompt
#\q
#exit the postgres shell
#exit

#edit /var/lib/pgsql/data/postgresql.conf
#listen_addresses = '*'                                           #<---- sed search and replace

sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /var/lib/pgsql/data/postgresql.conf

#edit vi /var/lib/pgsql/data/pg_hba.conf
#host    all             all             0.0.0.0/0      md5       #<---- sed search and replace

sudo sed -i "s/ident/md5/g" /var/lib/pgsql/data/pg_hba.conf
sudo sed -i -e "\$ahost    all             all             0.0.0.0/0      md5" /var/lib/pgsql/data/pg_hba.conf

# This file is read on server startup and when the postmaster receives
# a SIGHUP signal.  If you edit the file on a running system, you have
# to SIGHUP the postmaster for the changes to take effect.  You can
# use "pg_ctl reload" to do that.

sudo -i -u postgres pg_ctl reload

#use the following command to login as project1 user
#psql -U project1

#Install phpPgAdmin

sudo yum -y install phpPgAdmin

#edit /etc/httpd/conf.d/phpPgAdmin.conf  <-- sed search and replace
#change Require Local --> Require all granted
sudo sed -i 's,  Require local,  Require all granted,g' /etc/httpd/conf.d/phpPgAdmin.conf

# edit /etc/phpPgAdmin/config.inc.php

sudo cp /tmp/NTI-310/config_scripts/config.inc.php /etc/phpPgAdmin/config.inc.php

#sudo sed -i "s,$conf['servers'][0]['host'] = 'localhost';,$conf['servers'][0]['host'] = 'localhost';,g"
#sudo sed -i "s,$conf['servers'][0]['desc'] = 'PostgreSQL';,$conf['servers'][0]['desc'] = 'jwade005 PostgreSQL';"
#sudo sed -i "s,$conf['servers'][0]['defaultdb'] = 'template1';,$conf['servers'][0]['defaultdb'] = 'postgres';"
# $conf['servers'][0]['port'] = 5432;
# $conf['extra_login_security'] = false;
# $conf['owned_only'] = true;

#allow db to connect on httpd

sudo setsebool -P httpd_can_network_connect_db on

#restart postgres and httpd services

sudo systemctl restart postgresql
sudo systemctl restart httpd

#point browser to <serverIPaddress>/phpPgAdmin and login using postgres or project1 user to login
echo "point browser to <serverIPaddress>/phpPgAdmin and login using postgres or project1 user to login."
