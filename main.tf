provider "aws" {
    access_key = var.access_key
    secret_key = var.secret_key
    region = var.region
}

provider "tls" {
}

provider "local" {
}

resource "tls_private_key" "rsa4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "newkey" {
    key_name           = var.newkeyname
    public_key         = tls_private_key.rsa4096.public_key_openssh
}

resource "local_file" "file" {
  content  = tls_private_key.rsa4096.private_key_pem 
  filename = var.keyfilename
  file_permission = "400"
}

resource "aws_instance" "demo1" {
    ami = var.ami
    instance_type = var.type

    associate_public_ip_address = true
    key_name = aws_key_pair.newkey.key_name

    subnet_id = var.subneta
    vpc_security_group_ids = [aws_security_group.test.id] 

}

resource "aws_instance" "demo2" {
    ami = var.ami
    instance_type = var.type

    associate_public_ip_address = true
    key_name = aws_key_pair.newkey.key_name
    subnet_id = var.subnetb

    vpc_security_group_ids = [aws_security_group.test.id] 

}

resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [var.subneta, var.subnetb]
}

resource "aws_lb_target_group" "front_end" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpcid
}

resource "aws_lb_target_group_attachment" "testa" {
  target_group_arn = aws_lb_target_group.front_end.arn
  target_id        = aws_instance.demo1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "testb" {
  target_group_arn = aws_lb_target_group.front_end.arn
  target_id        = aws_instance.demo2.id
  port             = 80
}

resource "aws_lb_listener" "test" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }
}

resource "aws_security_group" "lb_sg" {
  name        = "allow_http"
  description = "Allow TLS inbound traffic"

  ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "test" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

}

resource "local_file" "inventory" {
  content  = <<FILE
all:
  children:
    vm1:
      hosts:
        ${aws_instance.demo1.public_ip}:
      vars:
        ansible_user: ubuntu
        ansible_host_key_checking: false
        ansible_ssh_private_key_file: ./${var.keyfilename}
    vm2:
      hosts:
        ${aws_instance.demo2.public_ip}:
      vars:
        ansible_user: ubuntu
        ansible_host_key_checking: false
        ansible_ssh_private_key_file: ./${var.keyfilename}
FILE
  filename = "inventory.yaml"
}