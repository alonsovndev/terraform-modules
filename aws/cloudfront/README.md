# CloudFront

Create a CloudFront distribution with a signed private S3 origin, HTTPS redirect, and security response headers.

## Usage

Example from a root two directories below the repository root. Configure the provider and backend in that consuming root; published consumers should pin the repository source to a reviewed commit or release.

```hcl
module "cloudfront" {
  source = "../../aws/cloudfront"
  name = "example-static"
  bucket_regional_domain_name = module.bucket.regional_domain_name
}
```

## Inputs

| Name | Type | Default | Meaning |
|---|---|---|---|
| `name` | `string` | Required | Resource name prefix; use lowercase letters, digits, and hyphens. |
| `tags` | `map(string)` | `{}` | Tags attached to taggable AWS resources. |
| `bucket_regional_domain_name` | `string` | Required | Private S3 bucket regional REST hostname, not an S3 website endpoint. |
| `aliases` | `set(string)` | `[]` | Optional custom hostnames covered by the supplied ACM certificate. |
| `acm_certificate_arn` | `string` | `null` | Validated ACM certificate in us-east-1; required exactly when custom aliases are supplied. |
| `spa_mode` | `bool` | `false` | Opt into serving index.html with HTTP 200 for S3 403/404 responses. |

## Outputs

| Name | Meaning |
|---|---|
| `distribution_id` | Distribution ID for deployment invalidations. |
| `distribution_arn` | Distribution ARN for the caller-owned S3 bucket policy. |
| `domain_name` | CloudFront distribution hostname. |
| `hosted_zone_id` | CloudFront hosted zone ID for DNS aliases. |

## Operational constraints

Use the S3 regional REST hostname, not a website endpoint. The caller must install the bucket policy shown in the AWS static example; otherwise origin requests receive access-denied responses. Custom aliases require a validated ACM certificate in us-east-1 and separate DNS setup. The default CloudFront hostname uses its service certificate. SPA mode explicitly converts S3 403 and 404 responses to index.html; do not enable it for ordinary content sites. Cache behavior uses AWS managed CachingOptimized. Review cache headers and invalidation requirements for each application.

## Verification

Run the repository checks in [development](../../docs/development.md). Tests use plan-only provider mocks; they do not establish deployment or runtime correctness. See [deployment prerequisites](../../docs/deployment.md).
