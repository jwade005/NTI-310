#!/bin/bash

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
echo "Publishing Website..."
sudo sh -c 'cat NTI-310/automation_scripts/index.html > /var/www/html/index.html'
sudo sh -c 'cat install_scripts/page2.html > /var/www/html/page2.html'

echo "Adjusting Permissions..."
sudo chmod 644 /var/www/html/index.html
sudo setenforce 0

echo "Adjusting http.conf file..."
sudo sed -i "151s/None/AuthConfig/1" /etc/httpd/conf/httpd.conf
echo "Adding .htaccess and .htpasswrd files..."
sudo sh -c 'cat install_scripts/.htaccess > /var/www/html/.htaccess'

sudo sh -c 'cat install_scripts/.htpasswd > /var/www/html/.htpasswd'

echo "Adjusting permissions..."
sudo chmod 644 /var/www/html/.htaccess
sudo chmod 644 /var/www/html/.htpasswd

echo "Restarting HTTP service..."
sudo service httpd restart

echo "Beginning Django Web Framework install..."
echo "Current version of Python:"

python --version

echo "Installing virtualenv to give Django it's own version of Python..."

sudo rpm -iUvh https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm
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
sed -i 's,ALLOWED_HOSTS = \[\],ALLOWED_HOSTS = \[*\],g' /opt/django/project1/project1/settings.py

echo "This is the new django project directory..."

sudo yum -y install tree
tree project1

echo "Go to https://docs.djangoproject.com/en/1.10/intro/tutorial01/ to begin first Django Project!"

echo "Starting Django server..."

sudo chmod 644 /opt/django/project1/manage.py
sudo setenforce 0

source /opt/django/django-env/bin/activate

cd /opt/django/project1

#echo "Migrating database files..."

#python manage.py migrate

echo "Django is now accessible from the web at [server IP]:8000..."

#prepare django for postgresql integration -- install postgres dev packages

sudo yum -y install python-devel postgresql-devel
sudo yum -y install gcc

#install psycopg2 to allow us to use the project1 database on postgres server

pip install psycopg2

#configure django database settings

sed -i "s/        'ENGINE': 'django.db.backends.sqlite3',/        'ENGINE': 'django.db.backends.postgresql_psycopg2',/g" /opt/django/project1/project1/settings.py
sed -i "s/        'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),/        'NAME': 'project1',/g" /opt/django/project1/project1/settings.py
sed -i "80i       'USER': 'project1'," /opt/django/project1/project1/settings.py    #**** FIX TAB
sed -i "81i       'PASSWORD': 'P@ssw0rd1'," /opt/django/project1/project1/settings.py #**** FIX TAB
sed -i "82i       'HOST': '10.128.0.6'," /opt/django/project1/project1/settings.py  #***** FIX TAB
sed -i "83i       'PORT': '5432'," /opt/django/project1/project1/settings.py  #**** FIX TAB

#migrate databasae

cd /opt/django/project1
python manage.py makemigrations #*******
python manage.py migrate

#create user

python manage.py createsuperuser #<-- will allow admin login

#python manage.py runserver 0.0.0.0:8000
#http://server_domain_or_IP:8000/admin
#
#
# (django-env) [Jonathan@django-a-centos7 project1]$ python manage.py migrate
# Operations to perform:
#   Apply all migrations: admin, auth, contenttypes, sessions
# Running migrations:
#   Applying contenttypes.0001_initial... OK
#   Applying auth.0001_initial... OK
#   Applying admin.0001_initial... OK
#   Applying admin.0002_logentry_remove_auto_add... OK
#   Applying contenttypes.0002_remove_content_type_name... OK
#   Applying auth.0002_alter_permission_name_max_length... OK
#   Applying auth.0003_alter_user_email_max_length... OK
#   Applying auth.0004_alter_user_username_opts... OK
#   Applying auth.0005_alter_user_last_login_null... OK
#   Applying auth.0006_require_contenttypes_0002... OK
#   Applying auth.0007_alter_validators_add_error_messages... OK
#   Applying auth.0008_alter_user_username_max_length... OK
#   Applying sessions.0001_initial... OK
# (django-env) [Jonathan@django-a-centos7 project1]$ python manage.py createsuperuser
# Username (leave blank to use 'jonathan'):
# Email address: jwade005@seattlecentral.edu
# Password:
# Password (again):
# Superuser created successfully.
