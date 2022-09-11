# taskrc.mk for .devcontainer
#
#  TODO: add targets for your project here.  When you run
#  "tmk <target-name>", the current dir will not change but
#  this makefile will be invoked.


# See https://stackoverflow.com/a/73509979/237059
absdir := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
SHELL := /bin/bash
REMAKE := $(MAKE) -C $(absdir) -s -f $(lastword $(MAKEFILE_LIST))

base_imgtag=shellkit-test-base:latest

.PHONY: help
help:
	@echo "Targets in $(basename $(lastword $(MAKEFILE_LIST))):" >&2
	@$(REMAKE) --print-data-base --question no-such-target 2>/dev/null | \
	grep -Ev  -e '^taskrc.mk' -e '^help' -e '^(Makefile|GNUmakefile|makefile|no-such-target)' | \
	awk '/^[^.%][-A-Za-z0-9_]*:/ \
			{ print substr($$1, 1, length($$1)-1) }' | \
	sort | \
	pr --omit-pagination --width=100 --columns=3
	@echo -e "taskrc_dir=\t$${taskrc_dir}"
	@echo -e "CURDIR=\t\t$(CURDIR)"

.flag/shellkit-test-base: Dockerfile
	imgtag=$(base_imgtag); \
	[[ -n "$(DISABLE_DOCKERHUB)" ]] && { \
		echo "WARNING: DISABLE_DOCKERHUB is set.  We're just checking for local image named $$imgtag to use as a build base." >&2; \
		docker image inspect $$imgtag >/dev/null; \
		touch .flag/shellkit-test-base; \
	} || { \
		echo "DISABLE_DOCKERHUB is not set." >&2; \
		docker pull ubuntu \
		&& docker tag ubuntu $$imgtag \
		&& touch .flag/shellkit-test-base; \
	};
	true
.PHONY: shellkit-test-base
shellkit-test-base: .flag/shellkit-test-base Dockerfile


.flag/shellkit-test-vsudo: .flag/shellkit-test-base
	@# Base image with just vscode-user + sudo powers
	docker build --target vsudo-base -t shellkit-test-vsudo:latest . \
	&& echo "shellkit-test-vsudo:latest image built OK" >&2
	touch .flag/shellkit-test-vsudo
.PHONY: shellkit-test-vsudo
shellkit-test-vsudo: .flag/shellkit-test-vsudo

.flag/shellkit-test-withtools: .flag/shellkit-test-vsudo
	@# Vsudo image with basic maintenance tools (git, curl, make)
	docker build --target withtools -t shellkit-test-withtools:latest . \
	&& echo "shellkit-test-withtools image built OK" >&2
	touch .flag/shellkit-test-withtools
.PHONY: shellkit-test-withtools
shellkit-test-withtools: .flag/shellkit-test-withtools

.PHONY: dc-up
dc-up .flag/dc-up: .flag/shellkit-test-base
	docker-compose up
	touch .flag/dc-up

.PHONY: dc-down
dc-down:
	docker-compose down
	rm .flag/dc-up

.PHONY: dc-shell
dc-shell: .flag/dc-up
	docker-compose exec -w /workspace -u vscode $(container_name) bash

.PHONY: clean
clean:
	rm .flag/*
