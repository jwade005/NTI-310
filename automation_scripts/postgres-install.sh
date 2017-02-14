#!/bin/bash

#postgresql install script -- test -- work in progress

#install postgresql

sudo yum -y install postgresql-server postgresql-contrib

#setup initial database cluster

sudo postgresql-setup initdb

#make a firewall rule for postgres

firewall-cmd --permanent --zone=public --add-service=postgresql
firewall-cmd --reload

#enable and start the postgresql server

sudo systemctl start postgresql
sudo systemctl enable postgresql

#login in to the postgres account created during installation

sudo -i -u postgres

#get a postgres command promt

psql

#create the database for django project1

CREATE DATABASE project1;

#create a project1 user and password

CREATE USER project1 WITH PASSWORD 'P@ssw0rd1';

#configure project1 users settings

ALTER ROLE project1 SET client_encoding TO 'utf8';
ALTER ROLE project1 SET default_transaction_isolation TO 'read committed';
ALTER ROLE project1 SET timezone TO 'UTC';

#give database user project1 access rights to the database project1

GRANT ALL PRIVILEGES ON DATABASE project1 TO project1;

#command \conninfo will give you connection info in the sql prompt

#exit the sql prompt

\q

#exit the postgres shell

exit

#edit /var/lib/pgsql/data/postgresql.conf

#listen_addresses = '*'

#edit vi /var/lib/pgsql/data/pg_hba.conf

#host    all             all             0.0.0.0/0      md5

# This file is read on server startup and when the postmaster receives
# a SIGHUP signal.  If you edit the file on a running system, you have
# to SIGHUP the postmaster for the changes to take effect.  You can
# use "pg_ctl reload" to do that.

pg_ctl reload

#use the following command to login as project1 user
#psql -U project1




#settings.py <— django

#DATABASES = {
#    'default': {
#        'ENGINE': 'django.db.backends.postgresql_psycopg2',
#        'NAME': 'project1',
#        'USER': 'project1',
#        'PASSWORD': 'P@ssw0rd1',
#        'HOST': '10.128.0.6',
#        'PORT': '5432',
#    }
#}
