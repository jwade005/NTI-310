#!/bin/bash

echo "This is jwade005's Gcloud Automation"

echo "Authorizing jwade005 for this project..."
gcloud auth login jwade005@seattlecentral.edu --no-launch-browser

echo "Creating the project..."
gcloud alpha projects create nti310-automation-9 \
    --name="NTI310 Automation"

echo "Creating Configuration..."
gcloud config configurations create auto1

echo "Enabling billing..."
gcloud alpha billing accounts projects link nti310-automation-9 --account-id=00CC7B-8C9651-1D73FA

echo "Setting admin account-id..."
gcloud config set account jwade005@seattlecentral.edu

echo "Setting the project for Configuration..."
gcloud config set project nti310-automation-9

echo "Setting zone/region for Configuration..."
gcloud config set compute/zone us-west1-a

gcloud config set compute/region us-west1

echo "Creating firewall-rules..."
gcloud compute firewall-rules create allow-http --description "Incoming http allowed." \
    --allow tcp:80

gloud compute firewall-rules create allow-ldap --description "Incoming ldap allowed." \
    --allow tcp:636

gcloud compute firewall-rules create allow-postgresql --description "Posgresql allowed." \
    --allow tcp:5432

gcloud compute firewall-rules create allow-https --description "Incoming https allowed." \
    --allow tcp:443

gcloud compute firewall-rules create allow-django --description "Django test server connection allowed." \
    --allow tcp:8000

gcloud compute firewall-rules create allow-ftp --description "FTP Allowed." \
    --allow tcp:21

echo "Creating ubuntu-client instance and running the install scripts..."
gcloud compute instances create ubuntu-client \
    --image-family ubuntu-1604-lts \
    --image-project ubuntu-os-cloud \
    --machine-type f1-micro \
    --zone us-west1-a \
    --metadata-from-file startup-script=/Users/Jonathan/desktop/NTI310/NTI-310/automation_scripts/ldap-client-install.sh \



echo "Creating the ldap-server instance and running the install script..."
gcloud compute instances create ldap-server \
    --image-family centos-7 \
    --image-project centos-cloud \
    --machine-type f1-micro \
    --zone us-west1-a \
    --metadata-from-file startup-script=/Users/Jonathan/desktop/NTI310/NTI-310/automation_scripts/ldap-server-install.sh \



echo "Creating the rsyslog-server instance and running the install script..."
gcloud compute instances create rsyslog-server \
    --image-family centos-7 \
    --image-project centos-cloud \
    --machine-type f1-micro \
    --zone us-west1-a \
    --metadata-from-file startup-script=/Users/Jonathan/desktop/NTI310/NTI-310/automation_scripts/rsyslog-server-install.sh \



echo "Creating the nfs-server and running the install script..."
gcloud compute instances create nfs-server \
    --image-family centos-7 \
    --image-project centos-cloud \
    --machine-type f1-micro \
    --zone us-west1-a \
    --metadata-from-file startup-script=/Users/Jonathan/desktop/NTI310/NTI-310/automation_scripts/nfs-server-install.sh \



echo "Creating the postgres-a-test server and running the install script..."
gcloud compute instances create postgres-a-test \
    --image-family centos-7 \
    --image-project centos-cloud \
    --machine-type f1-micro \
    --zone us-west1-a \
    --metadata-from-file startup-script=/Users/Jonathan/desktop/NTI310/NTI-310/automation_scripts/postgres-install.sh \



echo "Creating the postgres-b-staging server and running the install script..."
gcloud compute instances create postgres-b-staging \
    --image-family centos-7 \
    --image-project centos-cloud \
    --machine-type f1-micro \
    --zone us-west1-a \
    --metadata-from-file startup-script=/Users/Jonathan/desktop/NTI310/NTI-310/automation_scripts/postgres-install.sh \



echo "Creating the postgres-c-production server and running the install script..."
gcloud compute instances create postgres-c-production \
    --image-family centos-7 \
    --image-project centos-cloud \
    --machine-type f1-micro \
    --zone us-west1-a \
    --metadata-from-file startup-script=/Users/Jonathan/desktop/NTI310/NTI-310/automation_scripts/postgres-install.sh \



echo "Creating the django-a-test server and running the install script..."
gcloud compute instances create django-a-test \
    --image-family centos-7 \
    --image-project centos-cloud \
    --machine-type f1-micro \
    --zone us-west1-a \
    --metadata-from-file startup-script=/Users/Jonathan/desktop/NTI310/NTI-310/automation_scripts/apache-django-install.sh \



echo "Creating the django-b-staging server and running the install script..."
gcloud compute instances create django-b-staging \
    --image-family centos-7 \
    --image-project centos-cloud \
    --machine-type f1-micro \
    --zone us-west1-a \
    --metadata-from-file startup-script=/Users/Jonathan/desktop/NTI310/NTI-310/automation_scripts/django-production-install.sh \



echo "Creating the django-c-production server and running the install script..."
gcloud compute instances create django-c-production \
    --image-family centos-7 \
    --image-project centos-cloud \
    --machine-type f1-micro \
    --zone us-west1-a \
    --metadata-from-file startup-script=/Users/Jonathan/desktop/NTI310/NTI-310/automation_scripts/django-production-install.sh \

echo "Google Cloud Project nti310-auto-8 Installation Complete. :)"
