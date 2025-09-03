locals {
  # AKS cluster name dynamically generated
  function_full_name = "${var.function_name}-${var.location}-${var.environment}"

}
