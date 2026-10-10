.PHONY: init fmt fmt-check validate test docs-check ci

init:
	sh scripts/check.sh init

fmt:
	terraform fmt -recursive

fmt-check:
	terraform fmt -check -recursive

validate:
	sh scripts/check.sh validate

test:
	sh scripts/check.sh test

docs-check:
	python3 scripts/check_docs.py

ci:
	$(MAKE) init
	$(MAKE) fmt-check
	$(MAKE) validate
	$(MAKE) test
	$(MAKE) docs-check
