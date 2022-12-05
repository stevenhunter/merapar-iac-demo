resource "aws_api_gateway_rest_api" "api" {
  name = var.apiName
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy-method" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.proxy.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "lambda-integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_method.proxy-method.resource_id
  http_method = aws_api_gateway_method.proxy-method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get-dynamic-content-lambda.invoke_arn
}

resource "aws_api_gateway_method" "proxy-root" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_rest_api.api.root_resource_id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "lambda-root" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_method.proxy-root.resource_id
  http_method = aws_api_gateway_method.proxy-root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get-dynamic-content-lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "api-deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda-integration,
    aws_api_gateway_integration.lambda-root,
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = var.apiStageName
}

resource "aws_lambda_permission" "apigw-permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get-dynamic-content-lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_usage_plan" "apigw-usageplan" {
  name = "usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_deployment.api-deployment.stage_name
  }
}

resource "aws_api_gateway_api_key" "apigw-key" {
  name  = "cloudfront-key"
  value = var.cloudfront-custom-header-key-value
}

resource "aws_api_gateway_usage_plan_key" "apigw-usageplan-key" {
  key_id        = aws_api_gateway_api_key.apigw-key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.apigw-usageplan.id
}