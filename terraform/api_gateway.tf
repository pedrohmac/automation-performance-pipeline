# Create an API Gateway
resource "aws_api_gateway_rest_api" "csv_api" {
  name        = "csv-api"
  description = "API to upload CSV file"
}

# Create a method for the API Gateway
resource "aws_api_gateway_resource" "csv_resource" {
  rest_api_id = aws_api_gateway_rest_api.csv_api.id
  parent_id   = aws_api_gateway_rest_api.csv_api.root_resource_id
  path_part   = "upload"
}

# Create a POST method for the resource
resource "aws_api_gateway_method" "csv_method" {
  rest_api_id   = aws_api_gateway_rest_api.csv_api.id
  resource_id   = aws_api_gateway_resource.csv_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Create integration between API Gateway and Lambda function
resource "aws_api_gateway_integration" "csv_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.csv_api.id
  resource_id             = aws_api_gateway_resource.csv_resource.id
  http_method             = aws_api_gateway_method.csv_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.csv_api.invoke_arn
}

# Deploy the API
resource "aws_api_gateway_deployment" "csv_deployment" {
  depends_on = [aws_api_gateway_integration.csv_lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.csv_api.id
  stage_name  = "prod"
}

# Create an API key
resource "aws_api_gateway_api_key" "csv_api_key" {
  name = "csv-api-key"
}

# Associate the API key with the deployed API
resource "aws_api_gateway_usage_plan" "csv_usage_plan" {
  name             = "csv-usage-plan"
  api_stages {
    api_id = aws_api_gateway_rest_api.csv_api.id
    stage  = aws_api_gateway_deployment.csv_deployment.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "csv_usage_plan_key" {
  key_id        = aws_api_gateway_api_key.csv_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.csv_usage_plan.id
}

# Output the API endpoint and API key
output "api_endpoint" {
  value = aws_api_gateway_deployment.csv_deployment.invoke_url
}

output "api_key" {
  value = aws_api_gateway_api_key.csv_api_key.value
  sensitive = true
}
