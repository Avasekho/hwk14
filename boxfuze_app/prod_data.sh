#!/bin/bash
apt update -y
apt install -y tomcat9 awscli
mkdir /home/ubuntu/.aws
mkdir /home/ubuntu/.ssh