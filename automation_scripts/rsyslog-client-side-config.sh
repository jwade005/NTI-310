#!/bin/bash

#rsyslog client-side configuration -- run as root
#must be run on each rsyslog client


#ldap server rsyslog config
echo '*.info;mail.none;authpriv.none;cron.none    @10.128.0.2' >> /etc/rsyslog.conf
systemctl restart rsyslog.service
firewall-cmd --permanent --zone=public --add-port=514/tcp
firewall-cmd --permanent --zone=public --add-port=514/udp
firewall-cmd --reload


#nfs server rsyslog config
echo '*.info;mail.none;authpriv.none;cron.none    @10.128.0.4' >> /etc/rsyslog.conf
systemctl restart rsyslog.service
firewall-cmd --permanent --zone=public --add-port=514/tcp
firewall-cmd --permanent --zone=public --add-port=514/udp
firewall-cmd --reload


#ubuntu client rsyslog config
echo '*.info;mail.none;authpriv.none;cron.none    @10.138.0.2' >> /etc/rsyslog.conf
systemctl restart rsyslog.service
firewall-cmd --permanent --zone=public --add-port=514/tcp
firewall-cmd --permanent --zone=public --add-port=514/udp
firewall-cmd --reload
