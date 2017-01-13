#!/bin/bash

echo "Installing apache server..."
sudo yum -y install httpd

echo "Enabling apache server..."
sudo systemctl enable httpd.service

echo "Starting apache server..."
sudo systemctl start httpd.service

echo "Make sure to check the boxes in Google Compute Engine allowing HTTP and HTTPS traffic."
