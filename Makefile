# Makefile for shellkit.workspace


.PHONY: none
none: print-environ
	@echo "Error --  no default target.  If you're just getting started with \
shellkit.workspace, or setting up a new dev environment, try the \"setup-workspace\" target."

	exit 1

# See https://stackoverflow.com/a/73509979/237059
absdir:=$(dir $(realpath $(lastword $(MAKEFILE_LIST))))

shellkit_codebase:=https://github.com/sanekits/shellkit.git

# Some shellkit-meta items are independent of shellkit, but honor the setup protocol:
all_subgits:=$(shell ls -d */.git 2>/dev/null | xargs -n 1 dirname -- 2>/dev/null)

devcontainer_build_deps:= \
	.devcontainer/bin/user-build.sh \
	.devcontainer/Dockerfile \
	.devcontainer/docker-compose.yaml \


include environment.mk  # Symlink to environment-specific values

DC:=docker-compose


.PHONY: list-targets
list-targets:
	@LC_ALL=C $(MAKE) -pRrq -f Makefile : 2>/dev/null | awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | tr '\n' ' '

.PHONY: print-environ
print-environ: all_subgits environment.mk
	@echo absdir=${absdir} "\n"\
	ShellkitWorkspace=${ShellkitWorkspace} "\n"\
	shellkit_codebase=${shellkit_codebase} "\n"\
	all_subgits=${all_subgits} "\n"\
	workspace_packages=${workspace_packages} "\n"\
	devcontainer_build_deps=${devcontainer_build_deps} "\n"\
	all_targets=$$( $(MAKE) -s list-targets ) "\n"\

.devcontainer/.env: environment.mk
	echo ShellkitWorkspace=${ShellkitWorkspace} > .devcontainer/.env

.PHONY: dcenv
dcenv: .devcontainer/.env

# Maintain top-level git project list 'all_subgits':
all_subgits: Makefile
	@echo all_subgits=${all_subgits} | tee all_subgits

.PHONY: git-status
git-status:
	@echo "git status -s for all_subgits:" >&2; \
	for item in ${all_subgits};  do \
	( \
		cd $$item || exit 1 ;\
		echo "$$item:" ;\
		git status -s | sed -e 's/^/   /' ;\
		echo; \
	) || exit 1; \
	done; \
	echo "git status -s for $$PWD:" >&2; \
	git status -s | sed -e 's/^/   /' ;\


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

${HOME}/.shellkit-environment.mk:
	@cp templates/default-environment.mk ~/.shellkit-environment.mk
	@echo "NOTE:  you did not have a ~/.shellkit-environment.mk, so \
I created one for you.  Now it's yours, and it's up to you to \
put it in source control and customize it and take the blame \
for whatever's in it!"
	@echo "  (You should run make again after you've done that)"
	@ln -sf ${HOME}/.shellkit-environment.mk ./environment.mk
	@echo
	@echo "Fail-exit on purpose to get the user's attention:"
	exit 1

environment.mk: ${HOME}/.shellkit-environment.mk

.PHONY: setup-workspace
setup-workspace: environment.mk
	@# setup_clone_urls is set in environment.mk:
	@for item in ${setup_clone_urls};  do \
		[ -d $$(basename $${item}) ] || { \
	    	git clone $$item ; \
		};  \
	 	(  \
			cd $$(basename -- $$item) && [ -e ./make-kit.mk ] && { \
			   [ -d ./shellkit ] || git clone ${shellkit_codebase} ./shellkit ;  \
			} \
		); \
	done; \
	true;

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



