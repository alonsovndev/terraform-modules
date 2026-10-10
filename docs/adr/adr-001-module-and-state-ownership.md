# ADR-001: Library modules and consuming-root ownership

Status: Accepted

## Context

The platform needs reusable AWS and Cloudflare modules while different projects and environments retain separate credentials, state, budgets, and deployment workflows. Resources such as S3 policies have one owner and connect multiple modules.

## Decision

Library modules own reusable resources and typed contracts. Consuming roots own configured providers, backends, credentials, and cross-module policies. A root owns the single S3 bucket policy containing TLS denial and distribution-specific CloudFront permissions. Local verification uses checked-in example provider locks and plan-only provider mocks.

## Alternatives considered

- Put providers, backends, and policies inside each module: this couples account/environment choices and risks conflicting policy ownership.
- Implement deployment profiles with the modules immediately: this would claim deployment readiness without real-project validation.

## Consequences

Consumers must wire policies and configure state explicitly. Module outputs compose without reciprocal dependencies. Example compositions support local checks; live deployment profiles remain Phase 4 work.
