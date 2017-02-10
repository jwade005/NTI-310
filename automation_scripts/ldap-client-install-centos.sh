#!/bin/bash

#TEST SCRIPT
#script installs openldap client for centos7

#run as root

yum -y install openldap-clients nss-pam-ldapd

authconfig --enableldap \
--enableldapauth \
--ldapserver=35.185.26.4  \
--ldapbasedn="dc=jwade,dc=local" \
--enablemkhomedir \
--update

#add a SELinx rule to allow creating home directories automatically by mkhomedir

echo "module mkhomedir 1.0;

require {
        type unconfined_t;
        type oddjob_mkhomedir_exec_t;
        class file entrypoint;
}

#============= unconfined_t ==============
allow unconfined_t oddjob_mkhomedir_exec_t:file entrypoint;" >> mkhomedir.te

checkmodule -m -M -o mkhomedir.mod mkhomedir.te
semodule_package --outfile mkhomedir.pp --module mkhomedir.mod
semodule -i mkhomedir.pp

#interactive -- user added at login, must change password
#testuser@35.185.20.22
#passwd
#enter new password
