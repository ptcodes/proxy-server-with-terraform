provider "aws" {
  region = "us-west-2"
}

variable "ip_address" {
  description = "External IP address"
}

variable "proxy_port" {
  description = "Proxy port for incoming requests"
  default     = 8888
}

output "proxy_ip_address" {
  value       = aws_instance.tinyproxy-terraform.public_ip
  description = "Public IP address of the proxy server"
}

output "proxy_port" {
  value       = var.proxy_port
  description = "Port of the proxy server"
}

resource "aws_instance" "tinyproxy-terraform" {
  ami                    = "ami-0d1cd67c26f5fca19"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt-get install tinyproxy -y
              sudo echo "Allow ${var.ip_address}" >> /etc/tinyproxy/tinyproxy.conf
              sudo systemctl restart tinyproxy
              EOF

  tags = {
    Name = "tinyproxy"
  }
}

resource "aws_security_group" "instance" {
  name = "tinyproxy-terraform-instance"

  ingress {
    from_port   = var.proxy_port
    to_port     = var.proxy_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
