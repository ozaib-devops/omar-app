provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = "omar-app"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}