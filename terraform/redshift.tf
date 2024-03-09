data "aws_secretsmanager_secret_version" "redshift_cluster_credentials" {
    secret_id = "automation_performance_redshift_cluster"
}

locals {
    db_credentials = jsondecode(
        data.aws_secretsmanager_secret_version.redshift_cluster_credentials.secret_string
    )
}

resource "aws_redshift_cluster" "automation_performance_cluster" {
  cluster_identifier = "automation-pipeline-cluster"
  database_name      = "automation_pipeline_db"
  node_type          = "dc2.large"
  number_of_nodes    = 1
  master_username    = local.db_credentials.username
  master_password    = local.db_credentials.password
}