resource "aws_security_group" "database_sg" {
  name        = "${var.environment}-database-sg"
  description = "Security group for the database module"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [var.app_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "database-${var.environment}-sg"
    Environment = var.environment
    Tier        = "data"
  }
}

resource "aws_db_subnet_group" "database_subnet_group" {
  name       = "${var.environment}-database-subnet-group"
  subnet_ids = var.data_subnet_ids

  tags = {
    Name        = "database-${var.environment}-subnet-group"
    Environment = var.environment
    Tier        = "data"
  }
}

resource "aws_db_instance" "database_instance" {
  identifier              = "${var.environment}-database-instance"
  allocated_storage       = var.allocated_storage
  engine                  = "postgres"
  engine_version          = "13.4"
  instance_class          = var.instance_class
  username                = var.db_username
  password                = var.db_password
   backup_retention_period = 7
   backup_window           = "03:00-04:00"
   maintenance_window      = "sun:04:00-sun:05:00"
   auto_minor_version_upgrade = true
   copy_tags_to_snapshot   = true
  publicly_accessible     = false
  storage_encrypted        = true
  deletion_protection = true
  db_subnet_group_name    = aws_db_subnet_group.database_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.database_sg.id]
  skip_final_snapshot     = true

  tags = {
    Name        = "database-${var.environment}-instance"
    Environment = var.environment
    Tier        = "data"
  }
}