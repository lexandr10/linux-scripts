resource "aws_rds_cluster" "main" {
  count = var.use_aurora ? 1 : 0

  cluster_identifier = "${var.name_prefix}-aurora-cluster"

  engine         = var.engine == "postgres" ? "aurora-postgresql" : "aurora-mysql"
  engine_version = var.engine_version
  engine_mode    = "provisioned"

  database_name   = var.database_name
  master_username = var.master_username
  master_password = var.master_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_cluster_parameter_group_name = local.parameter_group_name

  backup_retention_period = var.backup_retention_period
  preferred_backup_window  = var.backup_window
  preferred_maintenance_window = var.maintenance_window

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name_prefix}-aurora-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  storage_encrypted = var.storage_encrypted

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-aurora-cluster"
    }
  )
}

resource "aws_rds_cluster_instance" "writer" {
  count = var.use_aurora ? 1 : 0

  identifier         = "${var.name_prefix}-aurora-writer"
  cluster_identifier = aws_rds_cluster.main[0].id
  instance_class     = var.instance_class

  engine         = aws_rds_cluster.main[0].engine
  engine_version = aws_rds_cluster.main[0].engine_version

  publicly_accessible = var.publicly_accessible

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-aurora-writer"
    }
  )
}

