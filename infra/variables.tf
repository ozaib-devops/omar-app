variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-2"
}

variable "environment" {
  description = "adding env name to resources"
  type        = string
  default     = "stg"
}
variable "github_repo" {
  type    = string
  default = "ozaib-devops/omar-app"
}
