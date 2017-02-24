#!/bin/bash

#kerberos install script ***TEST***

#edit /etc/hosts since we do not have DNS

echo "10.128.0.7 kerberos-sever.c.nti-310-project.internal
10.128.0.2 ubuntu.c.nti-310-project.internal" >> /etc/hosts

#install kerberos packages

yum install -y krb5-server krb5-workstation pam_krb5

#edit /var/kerberos/krb5kdc/kdc.conf

#replace EXAMPLE.COM with jwade.local
#uncomment #master_key_type = aes256-cts to remove keberos 4 compatibility, but improve security
#paste:   default_principal_flags = +preauth    into the 'realms' area

#edit /etc/krb5.conf

#uncomment all the lines, replace EXAMPLE.COM with your own realm, example.com with your own domain name, and kerberos.example.com with your own KDC server name (here kbserver.example.com)
