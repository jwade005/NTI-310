#!/bin/bash

#django/apache production install script

echo "Installing Apache server..."
sudo yum -y install httpd

echo "Starting HTTP service..."
sudo systemctl enable httpd.service

echo "Starting Apache Server..."
sudo systemctl start httpd.service

echo "Cloning jwade005's github..."
sudo yum -y install git
git clone https://github.com/jwade005/install_scripts.git
git clone https://github.com/jwade005/NTI-310.git

#isntall current epel release
sudo yum -y install epel-release

#isntall pip, apache, and mod-wsgi
sudo yum -y install python-pip httpd mod_wsgi

#install virtual env
sudo pip install virtualenv

#create project directory
cd /opt
mkdir django
sudo chown -R Jonathan django
cd django

#create python virtualenv in project directory
virtualenv project1env

#activate the virtualenv <-- to exit virtualenv, type 'deactivate'
source /opt/django/project1env/bin/activate

which python
sudo chown -R Jonathan /opt/django

#install django
pip install django

echo "Django admin is version:"

django-admin --version

#create the project1
django-admin.py startproject project1

#show project1 directory structure

echo "This is the new django project directory..."
sudo yum -y install tree
tree project1

#adjust project settings
sed -i "s,ALLOWED_HOSTS = \[\],ALLOWED_HOSTS = \['*'\],g" /opt/django/project1/project1/settings.py

#generate password for Superuser
sudo RPASS=$(mkpasswd -l 12)
sudo echo -n "$RPASS" > /root/django_admin_pass

sudo chmod 600 /root/django_admin_pass

#create superuser for admin login
python manage.py createsuperuser
#manage.py docs for automataing
python manage.py syncdb --noinput
echo "from django.contrib.auth.models import User; User.objects.create_superuser('jonathan', 'jwade005@seattlecentral.edu', '$RPASS')" | python manage.py shell
