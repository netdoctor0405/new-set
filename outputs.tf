output "private_ip_web01" {
  value       = aws_instance.test_web01.private_ip
  description = "The private IP of the Instance"
}

output "private_ip_web02" {
  value       = aws_instance.test_web02.private_ip
  description = "The private IP of the Instance"
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = aws_lb.frontend.dns_name
}

output "alb_zeta4_shop_dns_name" {
  description = "The DNS name of the alb.zeta4.shop Route 53 record"
  value       = aws_route53_record.alb_alias_record.fqdn
}

output "pub_dns" {
  value       = aws_instance.example.public_dns
  description = "The public DNS of the Instance"
}
