# Makefile for shellkit.workspace

.PHONY: none \
	git-pull \
	git-push \
	git-show-push-remotes \
	git-sync \
	print-subgits \
	setup-workspace \

# See https://stackoverflow.com/a/73509979/237059
absdir:=$(dir $(realpath $(lastword $(MAKEFILE_LIST))))

# These are dependent on shellkit:
shell_kits:=$(shell ls */version | xargs -n 1 dirname )

# Some shellkit-meta items are independent of shellkit, but honor the setup protocol:
all_subgits:=$(shell ls -d */.git | xargs -n 1 dirname )


include environment.mk  # Symlink to environment-specific values, e.g. in user's ~/.shellkit-workspace-environment.mk

# Maintain top-level project lists 'all_subgits' and 'shell_kits':
all_subgits shell_kits: ${all_subgits} Makefile
	@echo all_subgits=${all_subgits} | tee all_subgits
	@echo shell_kits=${shell_kits} | tee shell_kits

git-pull:
	@echo "Pull ${PWD}:"
	git pull
	@echo all_subgits;
	for item in ${all_subgits}; \
	  do ( echo "[$${item}]" ; cd $${item} && git pull )  ;  done

git-push:
	@echo all_subgits;
	for item in ${all_subgits}; \
	  do ( echo '$$\n' "[$${item}]" ; cd $${item} && git push ; git status; echo "[End of: $$item]")  ;  done
	git push

git-sync: git-pull git-push

print-subgits:
	@echo "${all_subgits}"

${absdir}/all-push-remotes git-show-push-remotes:
	@# Show all push remotes
	@for item in ${all_subgits}; do  \
		cd ${absdir}$${item} \
		   && git remote -v \
		      | grep -E '\(push\)' \
			  | sed -e "s/[(]push[)]//" -e "s/^/$${item} /" \
			  ; \
	done

setup-workspace:
	@# workspace_members is set in environment.mk:
	@for item in ${workspace_members};  do \
		[ -d $${item} ] && { echo Done: $$item already exists ; continue ; }; \
	    git clone $$item ; \
	done
