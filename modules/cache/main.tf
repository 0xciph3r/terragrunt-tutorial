resource "aws_security_group" "cache_sg" {
  name        = "cache_security_group"
  description = "Security group for cache instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    security_groups = [var.allowed_app_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "cache_security_group"
    Environment = var.environment
    Tier        = "data"
  }
}

resource "aws_elasticache_subnet_group" "cache_subnet_group" {
  name       = "cache-subnet-group"
  subnet_ids = var.data_subnet_ids

  tags = {
    Name        = "cache-subnet-group"
    Environment = var.environment
    Tier        = "data"
  }
}

resource "aws_elasticache_replication_group" "cache_replication_group" {
    description = "Replication group for cache instances"
    replication_group_id = "${var.environment}-cache-replication-group"
    engine = "redis"
    engine_version = var.engine_version
    node_type = var.node_type
    num_cache_clusters = 1
    at_rest_encryption_enabled = true
    transit_encryption_enabled = true
    subnet_group_name             = aws_elasticache_subnet_group.cache_subnet_group.name
    security_group_ids            = [aws_security_group.cache_sg.id]

  tags = {
    Name        = "cache-replication-group"
    Environment = var.environment
    Tier        = "data"
  }
}
