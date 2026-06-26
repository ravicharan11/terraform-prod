# ==============================================================
# Locals - Root Module
# Defines local values used across the configuration
# ==============================================================

locals {
  # Get the current Terraform workspace name
  # This will be 'dev', 'staging', or 'prod'
  environment = terraform.workspace

  # Construct resource name prefix based on environment
  # Results in: terraweek-dev, terraweek-staging, terraweek-prod
  name_prefix = "${var.project}-${local.environment}"
}
