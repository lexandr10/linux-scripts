resource "aws_db_subnet_group" "main" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-db-subnet-group"
    }
  )
}

resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-rds-sg"
  description = "Security group for RDS database"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Database access from VPC"
    from_port      = var.engine == "postgres" ? 5432 : 3306
    to_port        = var.engine == "postgres" ? 5432 : 3306
    protocol       = "tcp"
    cidr_blocks    = [var.vpc_cidr]
    security_groups = var.allowed_security_group_ids
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-rds-sg"
    }
  )
}

resource "aws_db_parameter_group" "postgres" {
  count  = var.engine == "postgres" ? 1 : 0
  family = var.use_aurora ? "aurora-postgresql${replace(var.engine_version, "/^([0-9]+\\.[0-9]+).*$/", "$1")}" : "postgres${replace(var.engine_version, "/^([0-9]+\\.[0-9]+).*$/", "$1")}"

  name = "${var.name_prefix}-postgres-params"

  parameter {
    name  = "max_connections"
    value = var.parameter_max_connections
  }

  parameter {
    name  = "log_statement"
    value = var.parameter_log_statement
  }

  parameter {
    name  = "work_mem"
    value = var.parameter_work_mem
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-postgres-params"
    }
  )
}

resource "aws_db_parameter_group" "mysql" {
  count  = var.engine == "mysql" ? 1 : 0
  family = var.use_aurora ? "aurora-mysql${replace(var.engine_version, "/^([0-9]+\\.[0-9]+).*$/", "$1")}" : "mysql${replace(var.engine_version, "/^([0-9]+\\.[0-9]+).*$/", "$1")}"

  name = "${var.name_prefix}-mysql-params"

  parameter {
    name  = "max_connections"
    value = var.parameter_max_connections
  }

  parameter {
    name  = "general_log"
    value = var.parameter_log_statement == "all" ? "1" : "0"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-mysql-params"
    }
  )
}

locals {
  parameter_group_name = var.engine == "postgres" ? aws_db_parameter_group.postgres[0].name : aws_db_parameter_group.mysql[0].name
}

