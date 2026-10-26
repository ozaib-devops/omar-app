variable "name" {
  type = string
}

variable "source_dir" {
  description = "folder with node code"
  type        = string
}

variable "runtime" {
  type    = string
  default = "nodejs24.x"
}

variable "subnet_ids" {
  type = list(string)
}

variable "lambda_sg_id" {
  type = string
}

variable "db_address" {
  type = string
}

variable "db_port" {
  type = number
}

variable "db_secret_arn" {
  type = string
}