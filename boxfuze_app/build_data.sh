#!/bin/bash
apt update -y
apt install -y maven default-jdk
cd /tmp/
git clone https://github.com/boxfuse/boxfuse-sample-java-war-hello.git
cd /tmp/boxfuze
mvn package
aws s3 cp /tmp/boxfuze/target/target-1.0.war s3://boxfuze.avasekho.test/