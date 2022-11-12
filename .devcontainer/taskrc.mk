# taskrc.mk for .devcontainer
#

# See https://stackoverflow.com/a/73509979/237059
absdir := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
SHELL := /bin/bash
REMAKE := $(MAKE) -C $(absdir) -s -f $(lastword $(MAKEFILE_LIST))

base_imgtag=shellkit-test-base:latest
metabase_bb=artprod.dev.bloomberg.com/bbgo/golang:ubuntu20

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

.flag/metabase:
	docker pull $(metabase_bb)
	docker tag $(metabase_bb) localbuilt/$(base_imgtag)

.flag/shellkit-test-base: Dockerfile .flag/metabase
	imgtag=localbuilt/$(base_imgtag); \
	[[ -n "$(DISABLE_DOCKERHUB)" ]] && { \
		echo "WARNING: DISABLE_DOCKERHUB is set.  We're just checking for local image named $$imgtag to use as a build base." >&2; \
		docker image inspect $$imgtag >/dev/null; \
		touch .flag/shellkit-test-base; \
	} || { \
		echo "DISABLE_DOCKERHUB is not set." >&2; \
		BUILDKIT_PROGRESS=plain docker pull ubuntu \
		&& docker tag ubuntu $$imgtag \
		&& touch .flag/shellkit-test-base; \
	};
	true
.PHONY: shellkit-test-base
shellkit-test-base: .flag/shellkit-test-base Dockerfile


.flag/shellkit-test-vsudo: .flag/shellkit-test-base
	@# Base image with just vscode-user + sudo powers
	BUILDKIT_PROGRESS=plain docker build --target vsudo-base \
		-t localbuilt/shellkit-test-vsudo:latest . \
	&& echo "localbuilt/shellkit-test-vsudo:latest image built OK" >&2
	touch .flag/shellkit-test-vsudo
.PHONY: shellkit-test-vsudo
shellkit-test-vsudo: .flag/shellkit-test-vsudo

.flag/shellkit-test-withtools: .flag/shellkit-test-vsudo
	@# Vsudo image with basic maintenance tools (git, curl, make)
	[[ -f ~/.gh-helprc ]] && cp ~/.gh-helprc ./
	set -x; BUILDKIT_PROGRESS=plain docker build \
		--build-arg https_proxy=$$https_proxy \
		--target withtools \
		-t localbuilt/shellkit-test-withtools:latest . \
	&& echo "localbuilt/shellkit-test-withtools image built OK" >&2
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
