provider "aws" {
  region = "us-east-1"
}

# SECURITY GROUPS
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Security group for web servers"

  dynamic "ingress" {
    for_each = var.security_group_rules
    content {
      from_port   = ingress.value["from_port"]
      to_port     = ingress.value["to_port"]
      protocol    = ingress.value["protocol"]
      cidr_blocks = [ingress.value["cidr"]]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# EC2
resource "aws_instance" "web" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = "mykey" # Ensure this key exists in your AWS account
  security_groups = [aws_security_group.web_sg.name]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("/Users/mahesh/.ssh/mykey.pem")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "/Users/mahesh/terraform-handson/terraform/terraform-projects/provisioners-lab/setup.sh"
    destination = "/tmp/setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup.sh",
      "sudo /tmp/setup.sh",
    ]
  }

  tags = {
    Name = "WebServer-${count.index}"
  }
}

# ALB
resource "aws_lb" "web_lb" {
  name               = "web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = var.subnets

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "web_tg" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "web_tg_attachment" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}
# NULL RESOURCE
resource "null_resource" "configure_web" {
  triggers = {
    instance_ids = join(",", aws_instance.web[*].id)
  }

  
  provisioner "file" {
    source      = "/Users/mahesh/terraform-handson/terraform/terraform-projects/provisioners-lab/setup.sh"
    destination = "/tmp/setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup.sh",
      "sudo /tmp/setup.sh",
    ]
  }
}
