terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = ">=2.7.0"
        }
    }
}

provider "aws" {
    profile = "self"
    region = "ap-south-1"
}

locals {
    ec2_tag = "ec2_tag"
}

data "aws_vpc" "default" {
    default = true
}

resource "aws_security_group" "sg1" {
    name = "allow http"
    vpc_id = data.aws_vpc.default.id

    ingress  {
       description = "Allow http traffic"
       to_port = 8000
       from_port = 0
       protocol = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Allow HTTP"
    }
}

resource "aws_key_pair" "developer" {
    key_name = "ec2-key"
    public_key = "ssh-rsa "
}

resource "aws_instance" "server" {
    ami = var.ami_id
    instance_type = var.instance_type
    key_name = aws_key_pair.developer.key_name
    vpc_security_group_ids = [aws_security_group.sg1.id]
    tags = {
        Name = "${local.ec2_tag}"
    }
    provisioner "remote-exec" {
        inline = [
            "mkdir -p /home/ec2-user/html",
            "touch /home/ec2-user/html/hello.html",
            "echo \"<b>HELLO</b>\" >> /home/ec2-user/html/hello.html",
            "cd /home/ec2-user/html",
        ]
        connection {
            type = "ssh"
            host = "${self.public_ip}"
            user = "ec2-user"
            private_key = "${file("/home/vanshaj/Projects/Devops/Terraform/simple_ec2/id_rsa")}"
        }
    }
}

output "instance_ipaddr" {
    value = aws_instance.server.public_ip
}
