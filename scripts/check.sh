#!/bin/sh
set -eu

check_mode=${1:?Usage: check.sh init|validate|test}
failed_checks=0
case "$check_mode" in
  init|validate|test) ;;
  *) printf 'Unsupported check: %s\n' "$check_mode" >&2; exit 2 ;;
esac

for module_directory in aws/* cloudflare/* examples/* tests/fixtures/*; do
  [ -d "$module_directory" ] || continue
  printf '\n%s: %s\n' "$check_mode" "$module_directory"
  case "$check_mode" in
    init)
      case "$module_directory" in
        aws/*|tests/fixtures/*) cp examples/aws-static/.terraform.lock.hcl "$module_directory/.terraform.lock.hcl" ;;
        cloudflare/*) cp examples/cloudflare-static/.terraform.lock.hcl "$module_directory/.terraform.lock.hcl" ;;
      esac
      terraform -chdir="$module_directory" init -backend=false -input=false -lockfile=readonly -no-color
      ;;
    validate) terraform -chdir="$module_directory" validate -no-color ;;
    test)
      if ! terraform -chdir="$module_directory" test -no-color; then
        failed_checks=1
      fi
      ;;
  esac
done
exit "$failed_checks"
