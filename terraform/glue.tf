resource "aws_glue_catalog_database" "db" {
  name = "automation_performance_db"
}

resource "aws_glue_job" "etl_job" {
  name     = "automation-performance-pipeline"
  role_arn = aws_iam_role.glue_role.arn
  
  command {
    script_location = "s3://automation-performance-dev-0-siena/scripts/etl.py"
    python_version  = "3"
  }
}
