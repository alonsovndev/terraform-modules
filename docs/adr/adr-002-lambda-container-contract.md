# ADR-002: FastAPI Lambda container contract

Status: Accepted

## Context

The ecosystem plan needs a Lambda FastAPI module. Lambda packaging is undecided in the handbook, and the existing FastAPI template's Docker image serves HTTP without a Lambda runtime adapter.

## Decision

The module accepts a prebuilt private ECR image pinned by digest and compatible with AWS Lambda Web Adapter. It configures the application port/readiness path and integrates with API Gateway HTTP API v2 events. The application image supplies the adapter and HTTP server, uses one matching architecture, and supports Lambda's read-only filesystem. Application authentication and runtime secret retrieval remain explicit application concerns.

## Alternatives considered

- ZIP package with an ASGI adapter: introduces a separate packaging/handler contract.
- Build application images inside Terraform: couples infrastructure planning to application packaging and artifact publication.

## Consequences

Artifact builds and ECR publication happen before Lambda deployment. The ordinary FastAPI template image needs a separate compatible packaging step. Mock tests prove Terraform settings, not application runtime compatibility. This local decision does not modify the handbook; real-project packaging validation remains follow-up work.
