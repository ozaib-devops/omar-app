variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-2"
}

variable "environment" {

  type        = string
  default     = "stg"
}

variable "github_repo" {

  type        = string
  default     = "ozaib-devops@98025347/omar-app@1432536164"
}
