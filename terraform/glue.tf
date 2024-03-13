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
  name     = "automation-performance-pipeline"
  role_arn = aws_iam_role.glue_role.arn
  
  command {
    script_location = "s3://${var.bucket}/scripts/etl.py"
  }

  default_arguments = {
    "--database_user" = local.db_credentials.username
    "--database_password" = local.db_credentials.password
    "--database_host" = aws_redshift_cluster.automation_performance_cluster.endpoint
    "--bucket_name" = aws_s3_bucket.automation_performance_bucket.name
    "--file_name" = "/data/complete_customer_support_tickets.csv"
  }
}

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
      {
        Action = [
          "glue:*"
        ]
        Effect = "Allow"
        Resource = [
          "*"
        ]
      }
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

# Attach the Redshift access policy to the role
resource "aws_iam_role_policy_attachment" "glue_subnet_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_subnet_access.arn
}


# Policy for AWS Glue to describe subnets
resource "aws_iam_policy" "glue_subnet_access" {
  name        = "automation_performance_glue_subnet_describe"
  path        = "/"
  description = "Allows Glue access to subnets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:*"
        ]
        Effect = "Allow"
        Resource = "*"
      },
    ]
  })
}

