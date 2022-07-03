terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.21.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "build_server" {
  ami                    = "ami-08d4ac5b634553e16"
  instance_type          = "t2.micro"
  key_name               = "us-east-1-key"
  user_data              = file("build_data.sh")
  depends_on = [aws_s3_bucket.bucket]

  tags = {
    Name = "Build Server"
  }

  provisioner "local-exec" {
    command = <<EOT
cd /tmp/
git clone https://github.com/boxfuse/boxfuse-sample-java-war-hello.git
cd /tmp/boxfuze
mvn package
aws s3 cp /tmp/boxfuze/target/target-1.0.war s3://boxfuze.avasekho.test/
EOT
  }
}

resource "aws_instance" "prod_server" {
  ami                    = "ami-08d4ac5b634553e16"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.open_port_8080.id]
  key_name               = "us-east-1-key"
  user_data              = file("prod_data.sh")
  depends_on = [aws_s3_bucket.bucket, aws_instance.build_server]

  tags = {
    Name = "Prod Server"
  }

  provisioner "local-exec" {
    command = "aws s3 cp s3://boxfuze.avasekho.test/target-1.0.war /var/lib/tomcat9/webapps/"
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "boxfuze.avasekho.test"

  tags = {
    Name = "boxfuze bucket"
  }
}

resource "aws_security_group" "open_port_8080" {
  name        = "allow_8080_for_tomcat"
  description = "Allow inbound traffic on port 8080"

  ingress {
    description = "Open port for tomcat"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_8080_for_tomcat"
  }
}