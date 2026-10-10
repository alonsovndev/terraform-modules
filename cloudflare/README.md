# Cloudflare modules

Configure the Cloudflare provider and state in a consuming root. Supply its API token through the provider environment, never through Terraform inputs or committed files.

- [Owned-domain zones](domain/README.md)
- [DNS records](dns/README.md)
- [Workers static sites](static-site/README.md)

See the [Cloudflare example](../examples/cloudflare-static/README.md). Registrar changes, domain purchases, and external DNS activation are outside this repository's automation.
