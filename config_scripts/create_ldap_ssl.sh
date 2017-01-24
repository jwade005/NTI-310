#creates ssl cert without input from user

openssl req -new -x509 -nodes -batch -out /etc/openldap/certs/jwadeldapcert.pem -keyout /etc/openldap/certs/jwadeldapkey.pem -days 3650



