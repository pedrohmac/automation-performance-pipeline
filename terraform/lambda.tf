# Create a Lambda function
resource "aws_lambda_function" "glue_trigger" {
  filename      = "../scripts/lambda_deployment_package.zip" 
  function_name = "automation_performance_pipeline_trigger"
  role          = aws_iam_role.lambda_exec.arn
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