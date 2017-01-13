#!/bin/bash

echo "Current version of Python:"

python --version

echo "Installing virtualenv to give Django it's own version of Python..."

# here you can install with updates or without updates.  To install python pip with a full kernel upgrade (not somthing you would do in prod, but
# definately somthing you might do to your testing or staging server: sudo yum update

# for a prod install (no update)

# this adds the noarch release reposatory from the fedora project, wich contains python pip

# python pip is a package manager for python...

rpm -iUvh https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm
yum -y install python-pip

# Now we're installing virtualenv, which will allow us to create a python installation and environment, just for our Django server

pip install virtualenv
cd /opt

# we're going to install our django libs in /opt, often used for optional or add-on.  /usr/local is also a perfectly fine place for new apps

# we want to make this env accisible to the ec2-user at first, because we don't want to have to run it as root.

mkdir django
sleep 5
cd django
virtualenv django-env

echo "Activating virtualenv..."

source /opt/django/django-env/bin/activate

echo "To switch out of virtualenv, type deactivate."

echo "Now using this version of Python:"

which python
chown -R ec2-user /opt/django

echo "installing django"

pip install Django

echo "Django admin is version:"

django-admin --version
django-admin startproject project1

echo "This is the new django project directory..."

tree project1

echo "Use 'python manage.py runserver 0.0.0.0:8000' to start the Django server."
