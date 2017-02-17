#creates ssl cert without input from user

#openssl req -new -x509 -nodes -batch -out /etc/openldap/certs/jwadeldapcert.pem -keyout /etc/openldap/certs/jwadeldapkey.pem -days 3650

openssl req -new -x509 -nodes -out /etc/openldap/certs/jwadeldapcert.crt -keyout /etc/openldap/certs/jwadeldapkey.key -days 365 -subj "/C=US/ST=WA/L=Seattle/O=IT/OU=NTI310IT/CN=jwade.local"
