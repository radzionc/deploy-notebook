variable "aws_access_key" {
  default = "<AWS_ACCESS_KEY>"
}

variable "aws_secret_key" {
  default = "<AWS_SECRET_KEY>"
}

variable "region" {
  default = "<DEFAULT_REGION>"
}

variable "account_id" {
  default = "<AWS_ACCOUNT_ID>"
}

variable "bucket_name" {
  default = "tf-lambdas"
}

variable "bucket_object_name" {
  default = "function.zip"
}

variable "handler" {
  default = "main.handler"
}

variable "memory_size" {
  default = "512"
}


provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}

resource "aws_api_gateway_rest_api" "function" {
  name        = "tf-lambdas"
}

resource "aws_s3_bucket" "function" {
  bucket = "${var.bucket_name}"
  policy = <<EOF
{
  "Id": "bucket_policy_site",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "bucket_policy_site_main",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.bucket_name}/*",
      "Principal": "*"
    }
  ]
}
EOF
}

resource "aws_s3_bucket_object" "function" {
  bucket  = "${var.bucket_name}"
  key     = "${var.bucket_object_name}"
  source  = "./${var.bucket_object_name}"
}

resource "aws_lambda_function" "function" {
  depends_on = ["aws_s3_bucket_object.function"]
  
  function_name = "tf-lambda"

  s3_bucket     = "${var.bucket_name}"
  s3_key        = "${var.bucket_object_name}"

  handler       = "${var.handler}"
  runtime       = "python3.6"
  timeout       = "30"
  memory_size   = "${var.memory_size}"
  role          = "${aws_iam_role.function.arn}"
}

resource "aws_iam_role" "function" {
  name                = "tf-function"

  assume_role_policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_api_gateway_resource" "function" {
  rest_api_id = "${aws_api_gateway_rest_api.function.id}"
  parent_id   = "${aws_api_gateway_rest_api.function.root_resource_id}"
  path_part   = "function"
}

resource "aws_api_gateway_method" "function" {
  rest_api_id   = "${aws_api_gateway_rest_api.function.id}"
  resource_id   = "${aws_api_gateway_resource.function.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "function" {
  rest_api_id             = "${aws_api_gateway_rest_api.function.id}"
  resource_id             = "${aws_api_gateway_resource.function.id}"
  http_method             = "${aws_api_gateway_method.function.http_method}"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.function.invoke_arn}"
  integration_http_method = "POST"
}
resource "aws_api_gateway_method_response" "function" {
  rest_api_id = "${aws_api_gateway_rest_api.function.id}"
  resource_id = "${aws_api_gateway_resource.function.id}"
  http_method = "${aws_api_gateway_integration.function.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
}

resource "aws_api_gateway_integration_response" "function" {
  rest_api_id = "${aws_api_gateway_rest_api.function.id}"
  resource_id = "${aws_api_gateway_resource.function.id}"
  http_method = "${aws_api_gateway_method_response.function.http_method}"
  status_code = "${aws_api_gateway_method_response.function.status_code}"

  response_templates = {
    "application/json" = ""
  }
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
}

resource "aws_lambda_permission" "function" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  function_name = "${aws_lambda_function.function.function_name}"

  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.function.id}/*/${aws_api_gateway_integration.function.integration_http_method}${aws_api_gateway_resource.function.path}"
}

module "cors" {
  source = "github.com/carrot/terraform-api-gateway-cors-module"
  resource_id = "${aws_api_gateway_resource.function.id}"
  rest_api_id = "${aws_api_gateway_rest_api.function.id}"
}

resource "aws_api_gateway_deployment" "function" {
  depends_on = ["aws_api_gateway_integration.function", "module.cors"]
  rest_api_id = "${aws_api_gateway_rest_api.function.id}"
  stage_name  = "example"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.function.invoke_url}"
}