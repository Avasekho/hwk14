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
  vpc_security_group_ids = [aws_security_group.open_port_22_8080.id]
  depends_on             = [aws_s3_bucket.bucket]

  tags = {
    Name = "Build Server"
  }

  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("/home/avasekho/us-east-1-key.pem")
    host     = self.public_ip
  }
  provisioner "file" {
    source      = "/root/.aws/credentials"
    destination = "/home/ubuntu/credentials"
  }
    provisioner "file" {
    source      = "/root/.ssh/id_rsa"
    destination = "/home/ubuntu/id_rsa"
  }
    provisioner "file" {
    source      = "/root/.ssh/config"
    destination = "/home/ubuntu/config"
  }
    provisioner "file" {
    source      = "provision_build.sh"
    destination = "/tmp/provision_build.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision_build.sh",
      "/tmp/provision_build.sh",
    ]
  }
}

resource "aws_instance" "prod_server" {
  ami                    = "ami-08d4ac5b634553e16"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.open_port_22_8080.id]
  key_name               = "us-east-1-key"
  depends_on             = [aws_s3_bucket.bucket, aws_instance.build_server]

  tags = {
    Name = "Prod Server"
  }

  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("/home/avasekho/us-east-1-key.pem")
    host     = self.public_ip
  }
  provisioner "file" {
    source      = "/root/.aws/credentials"
    destination = "/home/ubuntu/credentials"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision_prod.sh",
      "/tmp/provision_prod.sh",
    ]
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "boxfuze.avasekho.test"

  tags = {
    Name = "boxfuze bucket"
  }
}

resource "aws_security_group" "open_port_22_8080" {
  name        = "allow_8080_for_tomcat"
  description = "Allow inbound traffic on port 8080"

  ingress {
    description = "Open port for tomcat"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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