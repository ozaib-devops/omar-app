#review later - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy




# IAM role for Lambda execution
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${var.name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Package the Lambda function code
data "archive_file" "app" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "${path.module}/app.zip"
}

# Lambda function
resource "aws_lambda_function" "api" {
  filename      = data.archive_file.app.output_path
  function_name = "${var.name}-api"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  code_sha256   = data.archive_file.app.output_base64sha256

  runtime = var.runtime
  timeout = 15

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [var.lambda_sg_id]
  }

  environment {
    variables = {
      DB_HOST       = var.db_address
      DB_PORT       = tostring(var.db_port)
      DB_SECRET_ARN = var.db_secret_arn
    }
  }
}
resource "aws_iam_role_policy_attachment" "vpc_access" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "aws_iam_policy_document" "secret" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [var.db_secret_arn]
  }
}

resource "aws_iam_role_policy" "secret" {
  name   = "read-db-secret"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.secret.json
}

resource "aws_cloudwatch_log_group" "api" {
  name              = "/aws/lambda/${var.name}-api"
  retention_in_days = 7
}

resource "aws_lambda_function_url" "api" {
  function_name      = aws_lambda_function.api.function_name
  authorization_type = "NONE"
}

resource "aws_lambda_permission" "url_invoke" {
  statement_id             = "AllowFunctionUrlInvoke"
  action                   = "lambda:InvokeFunction"
  function_name            = aws_lambda_function.api.function_name
  principal                = "*"
  invoked_via_function_url = true
}
