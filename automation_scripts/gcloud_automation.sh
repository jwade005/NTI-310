gcloud auth login jwade005@seattlecentral.edu --no-launch-browser

gcloud alpha projects create nti310-automation-1 \
    --name="NTI310 Automation 1"

gcloud config configurations activate jwade005_configuration

gcloud config set account jwade005@seattlecental.edu

gcloud config set project nti310-automation-1

gcloud alpha billing accounts projects link nti310-automation-1 --account-id=00CC7B-8C9651-1D73FA

gcloud compute instances create ubuntu-client \
    --image-family ubuntu-1604-lts --image-project ubuntu-os-cloud \
    --machine-type f1-micro \
    --zone us-central1-a \
    --service-account=jwade005@seattlecentral.edu
    --metadata startup-script=

gcloud compute instances create ldap-server \
    rsyslog-server nfs-server postgres-a-test postgres-b-staging postgres-c-production django-a-test django-b-staging django-c-production \
    --image-family centos-7 --image-project centos-cloud \
    --machine-type f1-micro \
    --zone us-central1-a \
    --service-account=jwade005@seattlecentral.edu
