output "instance_public_ips" {
  value = aws_instance.web[*].public_ip
}

output "load_balancer_dns" {
  value = aws_lb.web_lb.dns_name
}

output "security_group_id" {
  value = aws_security_group.web_sg.id
}
