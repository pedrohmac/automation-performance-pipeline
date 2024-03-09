# IAM Role for AWS Glue
# This role allows Glue to access AWS resources

resource "aws_iam_role" "glue_role" {
  name = "automation_performance_glue_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      },
    ]
  })
}

# Policy to allow Glue access to S3 Bucket 
resource "aws_iam_policy" "glue_s3_access" {
  name        = "automation_performance_glue_s3_access"
  path        = "/"
  description = "Allows Glue access to S3 buckets for raw data"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
            "${aws_s3_bucket.automation_performance_bucket.arn}",
            "${aws_s3_bucket.automation_performance_bucket.arn}/*"
        ]
      },
    ]
  })
}


# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "glue_s3_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_s3_access.arn
}

# Policy for AWS Glue to access Redshift
resource "aws_iam_policy" "glue_redshift_access" {
  name        = "automation_performance_glue_redshift_access"
  path        = "/"
  description = "Allows Glue access to Redshift"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "redshift:Get*",
          "redshift:Describe*",
          "redshift:CreateClusterUser"
        ]
        Effect = "Allow"
        Resource = "*"
      },
    ]
  })
}

# Attach the Redshift access policy to the role
resource "aws_iam_role_policy_attachment" "glue_redshift_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_redshift_access.arn
}
