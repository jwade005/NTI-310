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
echo yes | /opt/django/django-env/bin/python manage.py collectstatic

deactivate

#tell django to use apache and mod_wsgi, adjust permissions

sudo cp /home/Jonathan/NTI-310/config_scripts/httpd.conf /etc/httpd/conf/httpd.conf
sudo usermod -a -G Jonathan apache
sudo setenforce 0
sudo systemctl restart httpd

echo "Django is now accessible from the web at [server IP] and admin site and [server IP]/admin"

#configure django database settings
sed -i "s/        'ENGINE': 'django.db.backends.sqlite3',/        'ENGINE': 'django.db.backends.postgresql_psycopg2',/g" /opt/django/project1/project1/settings.py
sed -i "s/        'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),/        'NAME': 'project1',/g" /opt/django/project1/project1/settings.py
sed -i "80i 'USER': 'project1'," /opt/django/project1/project1/settings.py
sed -i "81i 'PASSWORD': 'P@ssw0rd1'," /opt/django/project1/project1/settings.py
sed -i "82i 'HOST': '10.128.0.8'," /opt/django/project1/project1/settings.py
sed -i "83i 'PORT': '5432'," /opt/django/project1/project1/settings.py
sed -i "s/'USER': 'project1',/        'USER': 'project1',/g" /opt/django/project1/project1/settings.py
sed -i "s/'PASSWORD': 'P@ssw0rd1',/        'PASSWORD': 'P@ssw0rd1',/g" /opt/django/project1/project1/settings.py
sed -i "s/'HOST': '10.128.0.8',/        'HOST': '10.128.0.8',/g" /opt/django/project1/project1/settings.py
sed -i "s/'PORT': '5432',/        'PORT': '5432',/g" /opt/django/project1/project1/settings.py

#prepare django for postgresql integration -- install postgres dev packages
source /opt/django/django-env/bin/activate
sudo yum -y install python-devel postgresql-devel
sudo yum -y install gcc

#install psycopg2 to allow us to use the project1 database on postgres server
pip install psycopg2

#migrate databasae  <----***** postgres server must be setup and running to complete the following actoions *****
cd /opt/django/project1
python manage.py makemigrations #*******
python manage.py migrate

#create superuser for admin login
cd /opt/django/project1
#/opt/django/django-env/bin/python manage.py createsuperuser
#manage.py docs for automataing
echo "from django.contrib.auth.models import User; User.objects.create_superuser('jonathan', 'jwade005@seattlecentral.edu', 'P@ssw0rd1')" | python manage.py shell

#/opt/django/django-env/bin/python manage.py createsuperuser   --username jwade --email jwade005@seattlecentral.edu --password P@ssw0rd1 --noinput

deactivate

echo "Django is now installed and connected to postgres db and accessible from the web."
