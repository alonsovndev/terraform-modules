# GitHub OIDC example

Create or reuse the account's GitHub OIDC provider and grant one exact repository's `main` branch permission to list a selected S3 bucket and upload objects.

Supply `github_repository` as `owner/repository`, `bucket_arn`, and, when reusing the account provider, `create_provider=false` with `existing_provider_arn`. The permission policy is intentionally limited; deleting old objects and invalidating CloudFront need separately reviewed permissions if your deployment requires them.

For GitHub environments, use an exact environment subject and configure allowed deployment branches/reviewers in GitHub separately. This module does not configure repository settings or execute a workflow.

## Local verification

From the repository root, run `make ci`. The mocked test checks the role output contract; module tests check trust-policy audience and subject restrictions.
