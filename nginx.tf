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

resource "aws_instance" "nginx_server" {
  ami                    = "ami-08d4ac5b634553e16"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.open_port_80.id]
  key_name               = "us-east-1-key"
  user_data              = file("user_data.sh")

  tags = {
    Name = "Nginx Server"
  }
}

resource "aws_security_group" "open_port_80" {
  name        = "allow_80_for_nginx"
  description = "Allow inbound traffic on port 80"

  ingress {
    description = "Open port for Nginx"
    from_port   = 80
    to_port     = 80
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
    Name = "allow_80_for_nginx"
  }
}