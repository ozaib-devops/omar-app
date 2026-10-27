variable "name" {
  type = string
}

variable "github_repo" {
  description = "owner/repo allowed to deploy"
  type        = string
}

variable "lambda_function_arn" {
  type = string
}
