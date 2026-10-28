# ADR-004: Deployment profile roots

Status: Accepted

## Context

The ecosystem plan defines three deployment profiles (static, lean, enterprise). The Phase 3 examples exercise single modules but are not complete profiles, and the reference applications could not run on the lean and enterprise targets without changes.

## Decision

Ship each profile as a composition root under `profiles/<name>/` that a project copies into its own `infra/profiles/<name>/`. Roots own providers, wiring, and tests; the library modules stay unchanged.

- **Lean API credentials:** the Lambda receives only a Secrets Manager secret ARN, and the application reads the secret at startup. This keeps credentials out of Terraform values, state, and Lambda configuration, as ADR-002 requires. The Supabase database and the secret are created by hand.
- **Enterprise API credentials:** ECS injects the RDS-managed secret as one environment variable (`POSTGRES_CREDENTIALS_JSON`). The module forbids JSON-key suffixes, so the application parses the JSON.
- **CI trust:** OIDC roles trust one GitHub environment per repository. The OIDC module rejects wildcards, so tag and branch patterns are not used.
- **Release path:** Terraform owns image digests and Cloudflare assets, so a release is a reviewed plan and apply. Separate deploy tooling (`deploy-ecs`, Lambda code updates) is not used with these roots.
- **Validation:** mocked-provider plan tests plus local builds of the reference applications. A profile is called validated offline, never deployment-ready, until a real project applies it.

## Alternatives considered

- One parameterized root for all profiles: couples unrelated providers and makes cost and blast radius unclear.
- Lambda environment variables for the Supabase password: simpler, but stores the password in state and function configuration.
- Cloudflare in front of the Lambda API with a proxied DNS record: API Gateway rejects hostnames it does not own, so it needs a custom domain first. Deferred; the web app calls the API Gateway URL directly.

## Consequences

Projects copy and adapt a profile; improvements here do not propagate automatically. The first apply of an API profile needs an ECR bootstrap step. The enterprise profile uses RDS master credentials until a least-privilege application user is added. Account IDs, owners, state locations, and costs remain `TBD`.
