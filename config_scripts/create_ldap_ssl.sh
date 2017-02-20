#creates ssl cert without input from user

#openssl req -new -x509 -nodes -batch -out /etc/openldap/certs/jwadeldapcert.pem -keyout /etc/openldap/certs/jwadeldapkey.pem -days 3650

openssl req -new -x509 -nodes -out /etc/openldap/certs/jwadeldapcert.pem -newkey rsa:2048 -keyout /etc/openldap/certs/jwadeldapkey.pem -days 365 -subj "/C=US/ST=WA/L=Seattle/O=IT/OU=NTI310IT/CN=jwade.local"


#openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out
