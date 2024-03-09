resource "aws_glue_catalog_database" "db" {
  name = "automation_performance_db"
}

resource "aws_glue_job" "etl_job" {
  name     = "automation-performance-pipeline"
  role_arn = aws_iam_role.glue_role.arn
  
  command {
    script_location = "s3://${var.bucket}/scripts/etl.py"
    python_version  = "3"
  }
}