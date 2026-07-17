output "app_instance_id" {
    value = aws_instance.app.id
}

output "app_security_group_id" {
    value = aws_security_group.app.id
}

output "app_instance_public_ip" {
    value = aws_instance.app.public_ip
}

output "app_instance_private_ip" {
    value = aws_instance.app.private_ip
}

output "alb_dns_name" {
    value = aws_lb.app_alb.dns_name
}

output "alb_listener_arn" {
    value = var.enable_https ? aws_lb_listener.app_http_redirect[0].arn : aws_lb_listener.app_http_forward[0].arn
}

output "alb_target_group_arn" {
    value = aws_lb_target_group.app_tg.arn
}

output "alb_https_listener_arn" {
    value = var.enable_https ? aws_lb_listener.https[0].arn : null
}
