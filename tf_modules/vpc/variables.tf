variable "name" {
  description = "name for our resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR range for our VPC"
  type        = string
  default     = "10.0.0.0/16"
}