locals {
  name = "omar-${var.environment}"
}

module "vpc" {
  source = "../tf_modules/vpc"
  name   = local.name
}

module "rds" {
  source     = "../tf_modules/rds"
  name       = local.name
  subnet_ids = module.vpc.private_subnet_ids
  db_sg_id   = module.vpc.db_sg_id
}
module "github_oidc" {
  source              = "../tf_modules/github_oidc"
  name                = local.name
  github_repo         = var.github_repo
  lambda_function_arn = module.lambda.function_arn
}
