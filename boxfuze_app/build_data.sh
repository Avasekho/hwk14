#!/bin/bash
apt update -y
apt install -y maven default-jdk awscli
mkdir /home/ubuntu/.aws
mkdir /home/ubuntu/.ssh