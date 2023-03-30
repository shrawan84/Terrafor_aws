provider "aws" {
        profile = "default"
        region = "ap-south-1"
}
resource "aws_security_group" "allow_tls" {
        name    = "allow_tls"
        description = "Allow TLS inbound traffic"
        ingress{
                description = "TLS from VPC"
                from_port   = 443
                to_port     = 443
                protocol    = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
}
        ingress {
                description = "http"
                from_port   = 80
                to_port     = 80
                protocol    = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
}
        ingress {
                description = "SSH"
                from_port   = 22
                to_port     = 22
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
                Name = "allow_tls"
}
}
resource "aws_instance" "terraform-ec2" {
        ami = "ami-000ed5810ea2ca0a0"
        instance_type = "t2.micro"
        key_name      = "abc"
        security_groups= ["${aws_security_group.allow_tls.name}"]
        availability_zone = "ap-south-1a"
        root_block_device {
                volume_type = "gp2"
                volume_size = 10
                delete_on_termination = true
}
        user_data = <<-EOF
                        #! /bin/bash
                        sudo apt-get update
                        sudo apt-get install -y apache2
                        sudo apt-get start apache2
                        sudo apt-get enable apache2
                        echo "<h1> Deployed via terraform</h1>" | sudo tee /var/www/html/index.html
                        EOF
        tags = {
        Name = "Webserver"
        }
provisioner "local-exec" {
                command = "echo ${aws_instance.terraform-ec2.public_ip} > ip.txt"
}
}
