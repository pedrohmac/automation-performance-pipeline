
# -------------Lambda function that receives data from API Gateway and stores it in S3--------------
# Create a Lambda function
resource "aws_lambda_function" "csv_api" {
  filename      = "../services/lambda/csv_api.zip" 
  function_name = "csv_api"
  role          = aws_iam_role.api_s3_role.arn
  handler       = "lambda_function.handler"
  runtime       = "python3.8"

  environment {
    variables = {
      bucket_name = aws_s3_bucket.automation_performance_bucket.bucket
    }
  }
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.glue_trigger.function_name
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${aws_api_gateway_rest_api.csv_api.execution_arn}/*"
}

# Create an IAM role for the Lambda function
resource "aws_iam_role" "api_s3_role" {
  name = "api-s3-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

 #Created Policy for IAM Role
resource "aws_iam_policy" "api_s3_policy" {
  name = "api-s3-policy"
  description = "A test policy"


      policy = <<EOF
   {
"Version": "2012-10-17",
"Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "logs:*"
        ],
        "Resource": "arn:aws:logs:*:*:*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "s3:*"
        ],
        "Resource": "arn:aws:s3:::*"
    }
]

} 
    EOF
    }

# Attach policy to the IAM role
resource "aws_iam_role_policy_attachment" "api_s3_attach" {
  role       = aws_iam_role.api_s3_role.name
  policy_arn = aws_iam_policy.api_s3_policy.arn
}


# --------------Lambda function to trigger glue job ------------------------
# IAM Role for Lambda
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# IAM Policy for invoking Glue Jobs
resource "aws_iam_policy" "lambda_glue_invocation_policy" {
  name        = "lambda_glue_invocation_policy"
  description = "IAM policy to invoke Glue jobs from Lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "glue:StartJobRun"
        ],
        Resource = "*" # Ideally, specify the ARN of the Glue job
      },
    ]
  })
}

# Attach the policy to the role
# IAM Role for Lambda
resource "aws_iam_role_policy_attachment" "lambda_glue_policy_attach" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_glue_invocation_policy.arn
}

# Lambda function
resource "aws_lambda_function" "glue_trigger_lambda" {
  function_name = "s3_trigger_glue_job"
  handler       = "index.handler" # Update depending on your runtime
  role          = aws_iam_role.lambda_execution_role.arn
  runtime       = "python3.8" # Adjust as needed

  # Adjust these paths
  filename         = "path/to/your/lambda/function.zip"
  source_code_hash = filebase64sha256("path/to/your/lambda/function.zip")

  environment {
    variables = {
      GLUE_JOB_NAME = aws_glue_job.etl_job.name
    }
  }
}

# S3 Bucket Notification for Lambda
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.automation_performance_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.glue_trigger_lambda.arn
    events              = ["s3:ObjectCreated:Put"]
    filter_prefix       = "data/" 
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_function.glue_trigger_lambda]
}

# Lambda permission to allow S3 to invoke the function
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.glue_trigger_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.automation_performance_bucket.arn
}