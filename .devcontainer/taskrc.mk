# taskrc.mk for shellkit.workspace/.devcontainer
#


absdir:=$(taskrc_dir)
REMAKE := $(MAKE) -C $(absdir) -s -f $(lastword $(MAKEFILE_LIST))
container_name = shellkit-dev

.PHONY: help
help:
	@echo "Targets in $(basename $(lastword $(MAKEFILE_LIST))):" >&2
	@$(REMAKE) --print-data-base --question no-such-target 2>/dev/null | \
	grep -Ev  -e '^taskrc.mk' -e '^help' -e '^(Makefile|GNUmakefile|makefile|no-such-target)' | \
	awk '/^[^.%][-A-Za-z0-9_]*:/ \
			{ print substr($$1, 1, length($$1)-1) }' | \
	sort | \
	pr --omit-pagination --width=100 --columns=3
	@echo "taskrc_dir=$(taskrc_dir)"
	@echo "CURDIR=$(CURDIR)"

.PHONY: shellkit-test-base
shellkit-test-base .semaphore/shellkit-test-base: Dockerfile
	docker pull ubuntu
	docker tag ubuntu shellkit-test-base:latest
	touch .semaphore/shellkit-test-base

.PHONY: shellkit-test-vsudo
shellkit-test-vsudo .semaphore/shellkit-test-vsudo: .semaphore/shellkit-test-base
	@# Base image with just vscode-user + sudo powers
	docker build --target vsudo-base -t shellkit-test-vsudo:latest . \
	&& echo "shellkit-test-vsudo:latest image built OK" >&2
	touch .semaphore/shellkit-test-vsudo

.PHONY: shellkit-test-withtools
shellkit-test-withtools .semaphore/shellkit-test-withtools: .semaphore/shellkit-test-vsudo
	@# Vsudo image with basic maintenance tools (git, curl, make)
	docker build --target withtools -t shellkit-test-withtools:latest . \
	&& echo "shellkit-test-withtools image built OK" >&2
	touch .semaphore/shellkit-test-withtools

.PHONY: dc-up
dc-up .semaphore/dc-up: .semaphore/shellkit-test-base
	docker-compose up
	touch .semaphore/dc-up

.PHONY: dc-down
dc-down:
	docker-compose down
	rm .semaphore/dc-down

.PHONY: dc-shell
dc-shell: .semaphore/dc-up
	docker-compose exec -w /workspace -u vscode $(container_name) bash

.PHONY: clean
clean:
	rm .semaphore/*
