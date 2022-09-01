# Makefile for shellkit.workspace

.PHONY: none
none:
	@echo Error --  no default target
	exit 1

# See https://stackoverflow.com/a/73509979/237059
absdir:=$(dir $(realpath $(lastword $(MAKEFILE_LIST))))

# These are dependent on shellkit:
shell_kits:=$(shell ls */version 2>/dev/null | xargs -n 1 dirname )

# Some shellkit-meta items are independent of shellkit, but honor the setup protocol:
all_subgits:=$(shell ls -d */.git 2>/dev/null | xargs -n 1 dirname )

devcontainer_build_deps:= \
	.devcontainer/bin/user-build.sh \
	.devcontainer/Dockerfile \
	.devcontainer/docker-compose.yaml \

include environment.mk  # Symlink to environment-specific values, e.g. in user's ~/.shellkit-workspace-environment.mk

DC:=docker-compose

.PHONY: print-environ
print-environ:
	@echo absdir=${absdir}
	@echo ShellkitWorkspace=${ShellkitWorkspace}

.devcontainer/.env: environment.mk
	echo ShellkitWorkspace=${ShellkitWorkspace} > .devcontainer/.env

.PHONY: dcenv
dcenv: .devcontainer/.env

# Maintain top-level project lists 'all_subgits' and 'shell_kits':
.PHONY: all_subgits shell_kits
all_subgits shell_kits: ${all_subgits} Makefile
	@echo all_subgits=${all_subgits} | tee all_subgits
	@echo shell_kits=${shell_kits} | tee shell_kits

.PHONY: git-pull
git-pull:
	@echo "Pull ${PWD}:"
	git pull
	@echo all_subgits;
	for item in ${all_subgits}; \
	  do ( echo "[$${item}]" ; cd $${item} && git pull )  ;  done

.PHONY: git-push
git-push:
	@echo all_subgits;
	for item in ${all_subgits}; \
	  do ( echo '$$\n' "[$${item}]" ; cd $${item} && git push ; git status; echo "[End of: $$item]")  ;  done
	git push

.PHONY: git-sync
git-sync: git-pull git-push

.PHONY: print-subgits
print-subgits:
	@echo "${all_subgits}"

.PHONY: git-show-push-remotes
${absdir}/all-push-remotes git-show-push-remotes:
	@# Show all push remotes
	@for item in ${all_subgits}; do  \
		cd ${absdir}$${item} \
		   && git remote -v \
		      | grep -E '\(push\)' \
			  | sed -e "s/[(]push[)]//" -e "s/^/$${item} /" \
			  ; \
	done

environment.mk:
	@echo ERROR: You need to create a symlink named .environment.mk which defines
	@echo basic information
	exit 1

.PHONY: setup-workspace
setup-workspace: environment.mk
	@# setup_clone_urls is set in environment.mk:
	@for item in ${setup_clone_urls};  do \
		[ -d $$(basename $${item}) ] && { echo Done: $$item already exists ; continue ; }; \
	    git clone $$item || exit 1; \
	done

.PHONY: shellkit-test-base-exists
shellkit-test-base-exists:
	@docker image ls | grep shellkit-test-base

.PHONY: devcontainer-vscode-user
devcontainer-vscode-user: shellkit-test-base-exists dcenv
	@ ( cd .devcontainer \
		&&  $(DC)  run --rm shellkit-dev ls /home/vscode ) \
		|| {  \
			echo "No vscode user in shellkit-dev" ; \
			make devcontainer-vscode-user-add ; \
		}

.devcontainer/build-semaphore: ${devcontainer_build_deps} dcenv
	@# Build the devcontainer
	@cd .devcontainer \
		&& $(DC)  build
	touch .devcontainer/build-semaphore



.PHONY: devcontainer-build
devcontainer-build: .devcontainer/build-semaphore


.PHONY: devcontainer-run
devcontainer-run: .devcontainer/build-semaphore dcenv
	@# For testing inside the raw container (temp)
	@cd .devcontainer && \
		$(DC)  run --rm shellkit-dev bash

.PHONY: devcontainer-config
devcontainer-config: dcenv
	@cd .devcontainer && \
		$(DC) config

.PHONY: devcontainer-ps
devcontainer-ps: dcenv
	@cd .devcontainer && \
		$(DC)  ps

.PHONY: devcontainer-up
devcontainer-up: .devcontainer/build-semaphore dcenv
	@# devcontainer-up ensures the container is up or starts it if not
	@cd .devcontainer \
		&& $(DC) ps shellkit-dev | grep ' Up ' \
		|| { \
		  $(DC)  up -d shellkit-dev; \
		  sleep 3; \
		  $(DC)  exec shellkit-dev true ; \
		}

.PHONY: devcontainer-exec
devcontainer-exec: devcontainer-up dcenv
	@# For testing inside the running container
	@cd .devcontainer && \
		 $(DC) exec shellkit-dev bash

.PHONY: devcontainer-down
devcontainer-down: dcenv
	@# Bring the devcontainer down if its running
	@cd .devcontainer \
		&& { \
			$(DC)  ps shellkit-dev | grep ' Up ' \
			&& $(DC)  down  ; \
		} || true

.PHONY: devcontainer-bin-installed
devcontainer-bin-installed:
	@# Check to see if the Microsoft 'devcontainer' tool is installed
	which  devcontainer >/dev/null \
		|| { \
			echo "ERROR: install devcontainer tool first" >&2; \
			exit 1; \
		}

.PHONY: code-devcontainer-build
code-devcontainer-build: shellkit-test-base-exists devcontainer-bin-installed dcenv
	@# Launch vscode using the devcontainer --open command
	devcontainer build

.PHONY: code-devcontainer-open
code-devcontainer-open: code-devcontainer-build dcenv
	@# Launch vscode using the devcontainer --open command
	devcontainer open



