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

# here you can install with updates or without updates.  To install python pip with a full kernel upgrade (not somthing you would do in prod, but
# definately somthing you might do to your testing or staging server: sudo yum update

# for a prod install (no update)


# this adds the noarch release reposatory from the fedora project, wich contains python pip

# python pip is a package manager for python...

sudo rpm -iUvh https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm
sudo yum -y install python-pip


# Now we're installing virtualenv, which will allow us to create a python installation and environment, just for our Django server

sudo pip install virtualenv
cd /opt

# we're going to install our django libs in /opt, often used for optional or add-on.  /usr/local is also a perfectly fine place for new apps

# we want to make this env accessible to the ec2-user at first, because we don't want to have to run it as root.

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

echo "This is the new django project directory..."

sudo yum -y install tree
tree project1

echo "Go to https://docs.djangoproject.com/en/1.10/intro/tutorial01/ to begin first Django Project!"

echo "Starting Django server..."

source /opt/django/django-env/bin/activate

sudo chmod 644 /opt/django/project1/manage.py
sudo setenforce 0

cd /opt/django/project1

echo "Migrating database files..."

python manage.py migrate

echo "Django is now accessible from the web at [server IP]:8000..."
