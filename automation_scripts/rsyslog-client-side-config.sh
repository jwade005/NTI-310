#!/bin/bash

#rsyslog client-side configuration -- run as root
#must be run on each rsyslog client


echo '*.info;mail.none;authpriv.none;cron.none    @10.128.0.3' >> /etc/rsyslog.conf
systemctl restart rsyslog.service
firewall-cmd --permanent --zone=public --add-port=514/tcp
firewall-cmd --permanent --zone=public --add-port=514/udp
firewall-cmd --reload
