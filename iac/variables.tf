variable "bucketName" {
  default = "merapar-iac-webapp"
  type    = string
}

variable "dynamoDbTableName" {
  default = "merapar-iac-storage"
  type = string
}

variable "apiName" {
  default = "merapar-iac-api"
  type = string
}

variable "s3OriginId" {
  default = "merapar-s3-origin"
  type = string
}

variable "apiGatewayOriginId" {
  default = "merapar-apigw-origin"
  type = string
}

variable "apiStageName" {
  default = "demo"
  type = string
}

variable "lambdaName" {
  default = "get-dynamic-content-lambda"
  type = string
}

variable "cloudfront-custom-header-key-value" {
  default = "74c829fc-4afd-435d-b7b3-5b26dc0f409f"
  type = string
}
