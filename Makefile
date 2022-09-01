# Makefile for shellkit.workspace

.PHONY: none \
	git-pull \
	git-push \
	git-sync \

# These are dependent on shellkit:
shell_kits:=$(shell ls */version | xargs -n 1 dirname )

# Some shellkit-meta items are independent of shellkit, but honor the setup protocol:
all_subgits:=$(shell ls -d */.git | xargs -n 1 dirname )

# Maintain top-level project lists 'all_subgits' and 'shell_kits':
all_subgits shell_kits: ${all_subgits} Makefile
	@echo all_subgits=${all_subgits} | tee all_subgits
	@echo shell_kits=${shell_kits} | tee shell_kits

git-pull:
	git pull
	@echo all_subgits;
	for item in ${all_subgits}; \
	  do ( echo "[$${item}]" ; cd $${item} && git pull )  ;  done

git-push:
	@echo all_subgits;
	for item in ${all_subgits}; \
	  do ( echo '$$\n' "[$${item}]" ; cd $${item} && git push ; git status; echo "[End of: $$item]")  ;  done
	git push


