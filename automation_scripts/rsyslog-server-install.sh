#!/bin/bash

#rsyslog server side install script -- run as root on centos7 server

#adjust rsyslog.conf to listen for tcp, udp communication

sed -ie 's/#$ModLoad imudp/$ModLoad imudp/g' /etc/rsyslog.conf

sed -ie 's/#$UDPServerRun 514/$UDPServerRun 514/g' /etc/rsyslog.conf

sed -ie 's/#$ModLoad imtcp/$ModLoad imtcp/g' /etc/rsyslog.conf

sed -ie 's/#$InputTCPServerRun 514/$InputTCPServerRun 514/g' /etc/rsyslog.conf

#restart the rsyslog service

systemctl restart rsyslog.service

#open firewall port 514 to allow tcp, udp communication

firewall-cmd --permanent --zone=public --add-port=514/tcp
firewall-cmd --permanent --zone=public --add-port=514/udp
firewall-cmd --reload

#confirm server listening on port 514

yum -y install net-tools
netstat -antup | grep 514
