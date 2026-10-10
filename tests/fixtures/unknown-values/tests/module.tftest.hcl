mock_provider "aws" {
  source          = "../../aws"
  override_during = plan
}

run "new_resource_policy_and_provider_references" {
  command = plan

  assert {
    condition     = module.service.service_name == "example-api" && module.api.function_name == "example-api" && length(module.github.role_arns) == 1
    error_message = "New-resource policy and provider ARNs must not make resource counts unknown during the initial plan."
  }
}
