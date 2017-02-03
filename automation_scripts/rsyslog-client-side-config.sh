#!/bin/bash

#rsyslog client-side configuration -- run as root
#must be run on each rsyslog client


echo "*.info;mail.none;authpriv.none;cron.none    @10.128.0.5:514" >> /etc/rsyslog.conf
service rsyslog restart                                     #ubuntu command
systemctl restart rsyslog.service                           #centos7 command
firewall-cmd --permanent --zone=public --add-port=514/tcp   #centos7 commnds -- inactive ufw on ubuntu
firewall-cmd --permanent --zone=public --add-port=514/udp
firewall-cmd --reload
