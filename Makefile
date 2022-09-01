# Makefile for shellkit.workspace

.PHONY: none
none:
	@echo Error --  no default target
	exit 1

# See https://stackoverflow.com/a/73509979/237059
absdir:=$(dir $(realpath $(lastword $(MAKEFILE_LIST))))

# These are dependent on shellkit:
shell_kits:=$(shell ls */version | xargs -n 1 dirname )

# Some shellkit-meta items are independent of shellkit, but honor the setup protocol:
all_subgits:=$(shell ls -d */.git | xargs -n 1 dirname )

devcontainer_build_deps= \
	.devcontainer/bin/user-build.sh \
	.devcontainer/Dockerfile \
	.devcontainer/docker-compose.yaml \

include environment.mk  # Symlink to environment-specific values, e.g. in user's ~/.shellkit-workspace-environment.mk



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

.PHONY: setup-workspace
setup-workspace:
	@# workspace_members is set in environment.mk:
	@for item in ${workspace_members};  do \
		[ -d $${item} ] && { echo Done: $$item already exists ; continue ; }; \
	    git clone $$item ; \
	done

.PHONY: shellkit-test-base-exists
shellkit-test-base-exists:
	@docker image ls | grep shellkit-test-base

.PHONY: devcontainer-vscode-user
devcontainer-vscode-user: shellkit-test-base-exists
	@ ( cd .devcontainer \
		&& docker-compose run --rm shellkit-dev ls /home/vscode ) \
		|| {  \
			echo "No vscode user in shellkit-dev" ; \
			make devcontainer-vscode-user-add ; \
		}

.devcontainer/build-semaphore: ${devcontainer_build_deps}
	@# Build the devcontainer
	@cd .devcontainer \
		&& docker-compose build
	touch .devcontainer/build-semaphore



.PHONY: devcontainer-build
devcontainer-build: .devcontainer/build-semaphore


.PHONY: devcontainer-run 
devcontainer-run: .devcontainer/build-semaphore
	@# For testing inside the raw container (temp)
	@cd .devcontainer && \
		docker-compose run --rm shellkit-dev bash

.PHONY: devcontainer-config 
devcontainer-config:
	@cd .devcontainer && \
		docker-compose config

.PHONY: devcontainer-ps 
devcontainer-ps:
	@cd .devcontainer && \
		docker-compose ps

.PHONY: devcontainer-up
devcontainer-up: .devcontainer/build-semaphore
	@# devcontainer-up ensures the container is up or starts it if not
	@cd .devcontainer \
		&& docker-compose ps shellkit-dev | grep ' Up ' \
		|| { \
		  docker-compose up -d shellkit-dev; \
		  sleep 3; \
		  docker-compose exec shellkit-dev true ; \
		}

.PHONY: devcontainer-exec
devcontainer-exec: devcontainer-up
	@# For testing inside the running container
	@cd .devcontainer && \
		docker-compose exec shellkit-dev bash 

.PHONY: devcontainer-down
devcontainer-down:
	@# Bring the devcontainer down if its running
	@cd .devcontainer \
		&& { \
			docker-compose ps shellkit-dev | grep ' Up ' \
			&& docker-compose down  ; \
		} || true


