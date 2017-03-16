#!/bin/bash

echo "This is jwade005's Gcloud Automation"

echo "Authorizing jwade005 for this project..."
gcloud auth login wadejonathan005@gmail.com --no-launch-browser

echo "Enabling billing..."
gcloud alpha billing accounts projects link nti310-auto-5 --account-id=00CB7D-C97746-2D8BC1

echo "Setting admin account-id..."
gcloud config set account wadejonathan005@gmail.com

echo "Setting the project for Configuration..."
gcloud config set project nti310-auto-5

echo "Setting zone/region for Configuration..."
gcloud config set compute/zone us-west1-b

gcloud config set compute/region us-west1

echo "Creating firewall-rules..."
gcloud compute firewall-rules create allow-http --description "Incoming http allowed." \
    --allow tcp:80

gcloud compute firewall-rules create allow-ldap --description "Incoming ldap allowed." \
    --allow tcp:636

gcloud compute firewall-rules create allow-postgresql --description "Posgresql allowed." \
    --allow tcp:5432

gcloud compute firewall-rules create allow-https --description "Incoming https allowed." \
    --allow tcp:443

gcloud compute firewall-rules create allow-django --description "Django test server connection allowed." \
    --allow tcp:8000

gcloud compute firewall-rules create allow-ftp --description "FTP Allowed." \
    --allow tcp:21

echo "Creating the rsyslog-server instance and running the install script..."
gcloud compute instances create rsyslog-server \
    --image-family centos-7 \
    --image-project centos-cloud \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --metadata-from-file startup-script=/Users/Jonathan/desktop/NTI310/NTI-310/automation_scripts/rsyslog-server-install.sh \

echo "Creating the ldap-server instance and running the install script..."
gcloud compute instances create ldap-server \
    --image-family centos-7 \
    --image-project centos-cloud \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --metadata-from-file startup-script=/Users/Jonathan/desktop/NTI310/NTI-310/automation_scripts/ldap-server-install.sh \

echo "Creating ubuntu-client-a instance and running the install scripts..."
gcloud compute instances create ubuntu-client-a \
    --image-family ubuntu-1604-lts \
    --image-project ubuntu-os-cloud \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --metadata-from-file startup-script=/Users/Jonathan/desktop/NTI310/NTI-310/automation_scripts/ubuntu-client-install.sh \

echo "Creating ubuntu-client-b instance and running the install scripts..."
gcloud compute instances create ubuntu-client-b \
    --image-family ubuntu-1604-lts \
    --image-project ubuntu-os-cloud \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --metadata-from-file startup-script=/Users/Jonathan/desktop/NTI310/NTI-310/automation_scripts/ubuntu-client-install.sh \

echo "Creating ubuntu-client-c instance and running the install scripts..."
gcloud compute instances create ubuntu-client-c \
    --image-family ubuntu-1604-lts \
    --image-project ubuntu-os-cloud \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --metadata-from-file startup-script=/Users/Jonathan/desktop/NTI310/NTI-310/automation_scripts/ubuntu-client-install.sh \

echo "Creating the nfs-server and running the install script..."
gcloud compute instances create nfs-server \
    --image-family centos-7 \
    --image-project centos-cloud \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --metadata-from-file startup-script=/Users/Jonathan/desktop/NTI310/NTI-310/automation_scripts/nfs-server-install.sh \

echo "Creating the postgres-a-test server and running the install script..."
gcloud compute instances create postgres-a-test \
    --image-family centos-7 \
    --image-project centos-cloud \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --metadata-from-file startup-script=/Users/Jonathan/desktop/NTI310/NTI-310/automation_scripts/postgres-install.sh \

echo "Creating the postgres-b-staging server and running the install script..."
gcloud compute instances create postgres-b-staging \
    --image-family centos-7 \
    --image-project centos-cloud \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --metadata-from-file startup-script=/Users/Jonathan/desktop/NTI310/NTI-310/automation_scripts/postgres-install.sh \

echo "Creating the postgres-c-production server and running the install script..."
gcloud compute instances create postgres-c-production \
    --image-family centos-7 \
    --image-project centos-cloud \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --metadata-from-file startup-script=/Users/Jonathan/desktop/NTI310/NTI-310/automation_scripts/postgres-install.sh \

echo "Creating the django-a-test server and running the install script..."
gcloud compute instances create django-a-test \
    --image-family centos-7 \
    --image-project centos-cloud \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --metadata-from-file startup-script=/Users/Jonathan/desktop/NTI310/NTI-310/automation_scripts/apache-django-install.sh \

echo "Creating the django-b-staging server and running the install script..."
gcloud compute instances create django-b-staging \
    --image-family centos-7 \
    --image-project centos-cloud \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --metadata-from-file startup-script=/Users/Jonathan/desktop/NTI310/NTI-310/automation_scripts/django-staging-install.sh \

echo "Creating the django-c-production server and running the install script..."
gcloud compute instances create django-c-production \
    --image-family centos-7 \
    --image-project centos-cloud \
    --machine-type f1-micro \
    --scopes cloud-platform \
    --metadata-from-file startup-script=/Users/Jonathan/desktop/NTI310/NTI-310/automation_scripts/django-production-install.sh \

echo "Jwade005's Google Cloud Final Project Automatic Installation Complete. :)"
