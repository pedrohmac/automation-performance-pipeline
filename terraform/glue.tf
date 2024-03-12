data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls" {
  security_group_id = data.aws_security_group.default.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  to_port           = 65535
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = data.aws_security_group.default.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_glue_job" "etl_job" {
  glue_version = "4.0"
  name     = "automation-performance-pipeline"
  role_arn = aws_iam_role.glue_role.arn
  number_of_workers = 2
  max_retries = 0
  worker_type = "G.1X"
  timeout = "5"
  execution_class = "FLEX"
  connections = [aws_glue_connection.redshift_connection.name]
  
  command {
    script_location = "s3://${var.bucket}/scripts/etl.py"
    python_version  = "3"
  }
  default_arguments = {
    "--s3-bucket" = var.bucket
    "--redshift-cluster" = aws_redshift_cluster.automation_performance_cluster.database_name
  }
}

resource "aws_glue_connection" "redshift_connection" {
  name = "redshift_connection"

  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:redshift://${aws_redshift_cluster.automation_performance_cluster.endpoint}:${aws_redshift_cluster.automation_performance_cluster.port}/${aws_redshift_cluster.automation_performance_cluster.cluster_identifier}"
    USERNAME            = local.db_credentials.username
    PASSWORD            = local.db_credentials.password
    JDBC_ENFORCE_SSL    = false
  }

  physical_connection_requirements {
    availability_zone = "us-east-1e"
    security_group_id_list = [data.aws_security_group.default.id]
    subnet_id = data.aws_subnets.default.ids[5]
  }
}

