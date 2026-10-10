# S3 static site

Create a private versioned S3 bucket for a CloudFront REST origin, with encryption, public-access blocking, and enforced bucket ownership.

## Usage

Example from a root two directories below the repository root. Configure the provider and backend in that consuming root; published consumers should pin the repository source to a reviewed commit or release.

```hcl
module "s3_static_site" {
  source = "../../aws/s3-static-site"
  name = var.unique_bucket_name
}
```

## Inputs

| Name | Type | Default | Meaning |
|---|---|---|---|
| `name` | `string` | Required | Globally unique S3 bucket name; dots are excluded for TLS compatibility. |
| `tags` | `map(string)` | `{}` | Tags attached to taggable AWS resources. |

## Outputs

| Name | Meaning |
|---|---|
| `bucket_name` | Bucket name. |
| `bucket_arn` | Bucket ARN for caller-owned bucket policy statements. |
| `regional_domain_name` | Regional S3 REST endpoint for a CloudFront origin. |

## Operational constraints

This module creates neither website hosting nor a bucket policy. The consuming root owns the single bucket policy, including TLS denial and distribution-specific OAC read permission; see the AWS static example. Upload built assets separately. force_destroy is disabled so content is not deleted automatically.

## Verification

Run the repository checks in [development](../../docs/development.md). Tests use plan-only provider mocks; they do not establish deployment or runtime correctness. See [deployment prerequisites](../../docs/deployment.md).
