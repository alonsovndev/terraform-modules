# Development

Use Terraform 1.12.0, Make, POSIX sh, and Python 3. The Python checker uses only the standard library; no new Python environment or packages are required. If using a shared Python environment, activate it before running Make.

## Commands

| Command | Purpose |
|---|---|
| `make init` | Initialize every module, example, and regression fixture without backends, using checked-in provider selections |
| `make fmt` | Rewrite Terraform formatting |
| `make fmt-check` | Verify Terraform formatting without rewriting |
| `make validate` | Validate all initialized modules, examples, and regression fixtures |
| `make test` | Run all plan-only mocked-provider tests; return failure if any suite fails |
| `make docs-check` | Check Markdown headings, whitespace, and relative links |
| `make ci` | Run initialization, formatting checks, validation, tests, and documentation checks in order |

Initialization contacts the Terraform registry for approved provider packages. Set an existing `TF_PLUGIN_CACHE_DIR` if you want to reuse a local cache. Local checks do not configure a backend, use cloud credentials, or trigger remote CI.

## Versions and lock files

Library modules declare Terraform `>=1.12,<2`, AWS `>=6.68.0,<7`, or Cloudflare `~>5.27.0`. Example roots pin AWS 6.68.0 and Cloudflare 5.27.0 exactly. Their checked-in lock files provide reproducible selections for local verification.

`make init` copies the appropriate example lock into each library module's ignored local lock file and runs initialization with `-lockfile=readonly`. Profile roots under `profiles/` carry their own committed lock files, which `make init` uses read-only without copying. Consuming projects own their own lock files. Provider upgrades require an explicit change and approval; local checks do not upgrade them.

## Adding or changing a module

Keep resources, typed inputs, outputs, and tests together. Add a module README and link it from the provider index and repository README. Add architectural decisions to the [ADR log](adr/README.md). Avoid backend blocks and configured provider blocks in library modules.

Run `make ci`, then review the diff for secret exposure, IAM breadth, network exposure, resource replacement, and example wiring. Native mocked tests do not provide a line-coverage percentage; no application-code coverage gate is claimed for HCL.
