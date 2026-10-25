locals {
  name = "omar-${var.environment}"
}

module "vpc" {
  source = "../tf_modules/vpc"
  name   = local.name
}