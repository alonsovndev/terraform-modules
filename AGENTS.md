# Agent instructions

This repository contains reusable Terraform modules, example roots, native Terraform tests, and Markdown documentation. It has no application deployment automation.

## Commands

Run commands from the repository root:

```bash
make init
make fmt-check
make validate
make test
make docs-check
make ci
```

`make fmt` intentionally rewrites Terraform formatting. Validation uses pinned example lock files and backend-disabled initialization. Tests must use mocked providers and `command = plan`; never contact cloud accounts during local checks.

## Changes

- Read the module, its tests, and consuming examples before editing.
- Keep provider configuration and backends out of library modules.
- Update the module README when its inputs, outputs, or behavior change.
- Record architectural decisions in a new local ADR and update its index.
- Preserve stable resource addresses; document any future migration before changing them.
- Run `make ci` and local Terraform/code review before declaring a nontrivial change complete.
- Do not install or upgrade tools/providers without explaining the need and obtaining approval.

## Safety and Git

- Never read unsanitized variable files, state, or credentials. Never commit credentials, state, saved plans, or real variable files.
- Require explicit target-environment approval before apply, destroy, imports, state operations, backend migration, or provider upgrades.
- Keep deployment permissions separate from validation. Do not trigger pipelines or contact third-party cloud accounts without approval.
- Work on a named branch. Do not commit, push, or discard changes unless explicitly requested. Never commit or push on `main`, `master`, `dev`, or a detached HEAD.
- Use Conventional Commits without AI attribution when a commit is requested.

## Documentation

Use one H1, sentence-case headings, relative Markdown links, and placeholders for account/domain values. Do not write machine-specific paths, credentials, or unverified deployment claims. Mark unknown owners, costs, and deployment facts `TBD`.
