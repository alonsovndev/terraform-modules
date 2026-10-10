# AWS Lambda example

Compose ECR, a function/account-scoped repository retrieval policy, Lambda Web Adapter settings, and API Gateway HTTP API.

Supply a prebuilt `image_uri` digest from the `example-api` repository in `us-east-1`. The image must include Lambda Web Adapter and match the selected architecture. Bootstrap the ECR repository and publish the image before the complete application deployment. See [deployment prerequisites](../../docs/deployment.md).

The endpoint is public. The real application must implement authentication, authorization, and runtime retrieval of any secrets it needs. The example does not configure Supabase or claim compatibility with the ordinary FastAPI template image.

## Local verification

From the repository root, run `make ci`. The example's mocked test checks repository retrieval policy scope. The Lambda module tests check adapter settings and API wiring, not runtime startup.
