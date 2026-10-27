
output "github_deploy_role_arn" {
  value = module.github_oidc.deploy_role_arn
}

output "lambda_function_name" {
  value = module.lambda.function_name
}
