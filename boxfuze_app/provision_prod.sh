#!/bin/bash
sudo apt update -y
sudo apt install -y tomcat9 awscli
mkdir -p /home/ubuntu/.aws/
mv /home/ubuntu/credentials /home/ubuntu/.aws/credentials
sudo chmod 777 /var/lib/tomcat9/webapps/
/usr/bin/aws s3 cp s3://boxfuze.avasekho.test/hello-1.0.war /var/lib/tomcat9/webapps/hello-1.0.war