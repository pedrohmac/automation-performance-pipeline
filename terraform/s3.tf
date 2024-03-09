resource "aws_s3_bucket_ownership_controls" "aws_s3_bucket_ownership_controls" {
    bucket  = aws_s3_bucket.automation_performance_bucket.id
    rule {
        object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "aws_s3_bucket_acl" {
    depends_on  = [aws_s3_bucket_ownership_controls.aws_s3_bucket_ownership_controls]
    bucket      = aws_s3_bucket.automation_performance_bucket.id
    acl         = "private"
}

resource "aws_s3_bucket" "automation_performance_bucket" {
    bucket          = var.bucket
    force_destroy   = true
}