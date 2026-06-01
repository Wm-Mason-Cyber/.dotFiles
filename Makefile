# Small convenience Makefile
.PHONY: install symlink-install dry-run lint test

install:
	./install.sh

copy-install:
	./install.sh --copy

dry-run:
	./install.sh --dry-run

lint:
	# Requires shellcheck installed locally
	shellcheck install.sh standard-apps.sh scripts/mason-cyber-* || true

test:
	@echo "Running tests..."
	./tests/verify_prompt.sh
	./tests/verify_standard_apps.sh
	./tests/verify_install.sh
	./tests/verify_scripts.sh
	@echo "All tests passed"
