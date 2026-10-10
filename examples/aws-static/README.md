# AWS static hosting example

Compose a private S3 bucket, CloudFront OAC/distribution, and one root-owned bucket policy with TLS denial and distribution-specific read access.

Supply a globally unique `bucket_name`. The default CloudFront hostname needs no custom certificate. Upload built assets and establish cache invalidation outside Terraform. See [deployment prerequisites](../../docs/deployment.md).

## Local verification

From the repository root, run `make ci`. This example's mocked test checks TLS denial and CloudFront policy scope without provisioning a bucket.
