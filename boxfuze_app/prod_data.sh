#!/bin/bash
apt update -y
apt install -y tomcat9
aws s3 cp s3://boxfuze.avasekho.test/target-1.0.war /var/lib/tomcat9/webapps/