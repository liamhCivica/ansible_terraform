output "ip" {
    value = aws_instance.demo1.public_ip
}

output "lb" {
    value = aws_lb.test.dns_name
}
