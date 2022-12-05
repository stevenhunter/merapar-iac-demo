locals {
  zipName     = "lambda_function.zip"
  handlerName = "index.handler"
  runtime     = "nodejs16.x"
  roleName    = "get-dynamic-content-lambda-role"
  policyName  = "lambda-policy"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "../functions/get-dynamic-content/index.js"
  output_path = local.zipName
}

resource "aws_lambda_function" "get-dynamic-content-lambda" {
  filename         = local.zipName
  function_name    = var.lambdaName
  role             = aws_iam_role.get-dynamic-content-lambda_iam_role.arn
  handler          = local.handlerName
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = local.runtime
  environment {
    variables = {
    DYNAMODB_TABLE_NAME = var.dynamoDbTableName }
  }
}

data "aws_iam_policy_document" "lambda-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "get-dynamic-content-lambda_iam_role" {
  name               = local.roleName
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role-policy.json
}

data "aws_iam_policy_document" "lambda-policy" {
  statement {
    actions   = ["dynamodb:GetItem"]
    effect    = "Allow"
    resources = [aws_dynamodb_table.webapp-storage-table.arn]
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = local.policyName
  role   = aws_iam_role.get-dynamic-content-lambda_iam_role.id
  policy = data.aws_iam_policy_document.lambda-policy.json
}