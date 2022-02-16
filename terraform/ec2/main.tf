terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket = "terrafrom-state-1549528"
    key = "devops/terraform.tfstate"
    region = "us-west-1"
    encrypt = true
  }

}



provider "aws" {
  profile = "default"
  region  = "us-west-1"
}

resource "aws_s3_bucket" "terrafrom-state" {
    bucket = "terrafrom-state-1549528"
    
    lifecycle {
        prevent_destroy = true
    }

    versioning {
        enabled = true
    }

    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                sse_algorithm = "AES256"
            }
        }
    }
}

resource "aws_key_pair" "deployer" {
  key_name   = "ubuntu"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCpDZr4e1vWUmaaQ5Eag48rbFLcvCl71X/tROMAi5S6ikw7Jcm0DKcjMif3S6q6IpPp/KWHqdaFQdQViSKF+Xf/v9QjipRmVY58RNyqd9tyE5DbggAD3X/lfpZ6Z4QgePW8kFV59VEHTu2zff0jE2NlMr5YsR/jMa8PMer5bfkbndxo3lLmpcpvfafkDJo6uXgp1x3cvg1bbHz8JoIhQfiFM+nFveDpTZCDZk0aEoXHj94ZfrUeUxWHJLjab6KnyxZyUIdg9IejSkqwrTVubUdQmCwDR70ISK6yNRBnvm1mSYDiDIqxpLK7y5dSDZX+QANvgdOE75hXCk8QHtjt47nRBUrmq6bDdgcKO0h4m/Y6YFrJDgXnep96IuDWYvN9GTYEv54IpwedVQN65+hMqew8NJgzDVGZ69eUlLD4Fkky0xRP7UxxfQcV4QIbeThhG+vRd+yH8cw7MtrDN7Aq9I0Mx2j/eSbKKm5bkv+Q1HqfkRag3Vnm7LVzFNT2Z0XF8YM= mboyar@DESKTOP-L6VHONF"
}

resource "aws_instance" "app_server" {
  ami           = "ami-01f87c43e618bf8f0"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.web-node.name}"]
  key_name = aws_key_pair.deployer.id

  tags = {
    Name = "Ubuntu"
  }
}

resource "aws_security_group" "web-node" {
  name = "web-node"
  description = "Web Security Group"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }    
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_instance" "jenkins_node1" {
  ami           = "ami-01f87c43e618bf8f0"
  instance_type = "t2.micro"
  key_name = aws_key_pair.deployer.id
  security_groups = ["${aws_security_group.web-node.name}"]

  tags = {
    Name = "jenkins-node1"
    }
}