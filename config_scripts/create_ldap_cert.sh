#!/bin/bash

openssl req -new -x509 -nodes -out /etc/openldap/certs/jwadeldapcert.pem -keyout /etc/openldap/certs/jwadeldapkey.pem -days 365<<EOF
$US \n
$Washington \n
$Seattle \n
$IT \n
$nti310 \n
$jwade.local \n
$jwade005@seattlecentral.edu \n
EOF
