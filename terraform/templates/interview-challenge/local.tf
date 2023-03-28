locals {
  name_suffix = "jcc-${var.environment}-${module.azure_region.location_short}"
  alphanumeric_name_suffix = "jcc${var.environment}${module.azure_region.location_short}"
}
