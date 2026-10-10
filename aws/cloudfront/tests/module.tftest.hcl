mock_provider "aws" {
  source          = "../../tests/aws"
  override_during = plan
}

variables {
  name                        = "example-static"
  bucket_regional_domain_name = "example-static.s3.us-east-1.amazonaws.com"
}

run "https_signed_private_origin" {
  command = plan
  assert {
    condition     = aws_cloudfront_origin_access_control.this.signing_behavior == "always" && aws_cloudfront_origin_access_control.this.signing_protocol == "sigv4"
    error_message = "Always sign origin requests."
  }
  assert {
    condition     = one(aws_cloudfront_distribution.this.default_cache_behavior).viewer_protocol_policy == "redirect-to-https" && length(aws_cloudfront_distribution.this.custom_error_response) == 0
    error_message = "Redirect to HTTPS without enabling SPA fallback by default."
  }
  assert {
    condition     = one(aws_cloudfront_distribution.this.origin).origin_access_control_id == aws_cloudfront_origin_access_control.this.id
    error_message = "Connect the private origin to its OAC."
  }
}

run "explicit_spa_mode" {
  command = plan
  variables {
    spa_mode = true
  }
  assert {
    condition     = length(aws_cloudfront_distribution.this.custom_error_response) == 2 && alltrue([for response in aws_cloudfront_distribution.this.custom_error_response : response.response_code == 200 && response.response_page_path == "/index.html"])
    error_message = "SPA mode must map both S3 missing/private responses to index.html."
  }
}

run "custom_domain_certificate" {
  command = plan
  variables {
    aliases             = ["www.example.com"]
    acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/00000000-0000-0000-0000-000000000000"
  }
  assert {
    condition     = one(aws_cloudfront_distribution.this.viewer_certificate).acm_certificate_arn == var.acm_certificate_arn
    error_message = "Use the caller certificate."
  }
}

run "custom_alias_requires_certificate" {
  command = plan
  variables {
    aliases = ["www.example.com"]
  }
  expect_failures = [var.acm_certificate_arn]
}

run "website_origin_rejected" {
  command = plan
  variables {
    bucket_regional_domain_name = "example-static.s3-website-us-east-1.amazonaws.com"
  }
  expect_failures = [var.bucket_regional_domain_name]
}
