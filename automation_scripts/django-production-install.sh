#!/bin/bash

#django/apache production install script

#isntall pip, apache, and mod-wsgi
sudo yum -y install python-pip httpd mod_wsgi

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

#install virtual env
sudo pip install virtualenv

echo "Beginning Django Web Framework install..."
echo "Current version of Python:"

python --version

echo "Installing virtualenv to give Django it's own version of Python..."

sudo yum -y install python-pip

sudo pip install virtualenv
cd /opt

# we're going to install our django libs in /opt, often used for optional or add-on

# we want to make this env accessible to the GCloud user because we don't want to have to run it as root

sudo mkdir django
sudo chown -R Jonathan django
sleep 5
cd django
sudo virtualenv django-env

echo "Activating virtualenv..."

source /opt/django/django-env/bin/activate

echo "To switch out of virtualenv, type deactivate."

echo "Now using this version of Python:"

which python
sudo chown -R Jonathan /opt/django

echo "Installing Django"

pip install Django

echo "Django admin is version:"

django-admin --version
django-admin startproject project1

echo "Adjusting settings.py allowed_hosts..."
sed -i "s,ALLOWED_HOSTS = \[\],ALLOWED_HOSTS = \['*'\],g" /opt/django/project1/project1/settings.py

echo "This is the new django project directory..."

echo 'STATIC_ROOT = os.path.join(BASE_DIR, "static/")' >> /opt/django/project1/project1/settings.py

sudo yum -y install tree
tree project1

#generate password for Superuser      #<----- ***permission denied***
#sudo RPASS=$(mkpasswd -l 12)
#sudo echo -n "$RPASS" > /root/django_admin_pass

#sudo chmod 600 /root/django_admin_pass

#make initial migrations using sqllite
cd /opt/django/project1
/opt/django/django-env/bin/python manage.py makemigrations
/opt/django/django-env/bin/python manage.py migrate
/opt/django/django-env/bin/python manage.py collectstatic

#create superuser for admin login
cd /opt/django/project1
#/opt/django/django-env/bin/python manage.py createsuperuser
#manage.py docs for automataing
echo "from django.contrib.auth.models import User; User.objects.create_superuser('auser', 'jwade005@seattlecentral.edu', 'P@ssw0rd1')" | python manage.py shell

#/opt/django/django-env/bin/python manage.py createsuperuser   --username jwade --email jwade005@seattlecentral.edu --password P@ssw0rd1 --noinput

deactivate

#tell django to use apache and mod_wsgi, adjust permissions

sudo cp /home/Jonathan/NTI-310/config_scripts/httpd.conf /etc/httpd/conf/httpd.conf
sudo usermod -a -G Jonathan apache
sudo systemctl restart httpd

echo "Django is now accessible from the web at [server IP]"

#prepare django for postgresql integration -- install postgres dev packages
sudo yum -y install python-devel postgresql-devel
sudo yum -y install gcc

#install psycopg2 to allow us to use the project1 database on postgres server
pip install psycopg2

#configure django database settings
