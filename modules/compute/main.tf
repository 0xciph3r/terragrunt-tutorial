resource "aws_security_group" "app" {
    name = "${var.environment}-app-sg"
    description = "Security group for application instances"
    vpc_id = var.vpc_id

    ingress{
        
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [var.allowed_ssh_cidr]
    }

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = [aws_security_group.alb_ingress.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name        = "${var.environment}-app-sg"
        Environment = var.environment
        Tier       = "app"
    }
}


resource "aws_instance" "app" {
    ami           = var.ami_id
    instance_type = var.instance_type
    subnet_id     = var.subnet_id
    vpc_security_group_ids = [aws_security_group.app.id]

    metadata_options {
      http_tokens = "required"
    }
    root_block_device {
        encrypted   = true
    }
    associate_public_ip_address = false

    tags = {
        Name        = "${var.environment}-app-server"
        Environment = var.environment
        Tier       = "app"
    }
}

resource "aws_security_group" "alb_ingress" {
    name             = "${var.environment}-alb-ingress"
    description      = "Allow ALB to access app instances"
    vpc_id           = var.vpc_id

    ingress {
        
        from_port   = 80
        to_port     = 80
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
        Name        = "${var.environment}-alb-ingress-sg"
        Environment = var.environment
        Tier       = "app"
    }
}

resource "aws_lb" "app_alb" {
    name               = "${var.environment}-app-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.alb_ingress.id]
    subnets            = var.public_subnet_ids
    
    enable_deletion_protection = true

    tags = {
        Name        = "${var.environment}-app-alb"
        Environment = var.environment
        Tier       = "app"
    }
}

resource "aws_lb_target_group" "app_tg" {
    name     = "${var.environment}-app-tg"
    port     = 80
    protocol = "HTTP"
    vpc_id   = var.vpc_id


    health_check {
        path                = "/health"
        interval            = 15
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
        matcher             = "200-299"
    }



    tags = {
        Name        = "${var.environment}-app-tg"
        Environment = var.environment
        Tier       = "app"
    }
}

resource "aws_lb_listener" "app_listener" {
    load_balancer_arn = aws_lb.app_alb.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.app_tg.arn
    }

      /* TODO: PRODUCTION REDIRECT ACTION (Uncomment when enable_https = true)
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  */
}

resource "aws_lb_target_group_attachment" "app_tg_attachment" {
    target_group_arn = aws_lb_target_group.app_tg.arn
    target_id        = aws_instance.app.id
    port             = 80
}

# HTTPS Listener - Conditional scaffold, only creates if enable_https = true
resource "aws_lb_listener" "https" {
  count             = var.enable_https ? 1 : 0
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06" # Modern, secure TLS policy
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}