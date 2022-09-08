# taskrc.mk for shellkit.workspace
#
#  TODO: add targets for your project here.  When you run
#  "tmk <target-name>", the current dir will not change but
#  this makefile will be invoked.


# See https://stackoverflow.com/a/73509979/237059
# See https://stackoverflow.com/a/73509979/237059
absdir:=$(dir $(realpath $(lastword $(MAKEFILE_LIST))))

REMAKE := $(MAKE) -f $(lastword $(MAKEFILE_LIST))
SHELL := /bin/bash

.PHONY: help
help:
	@echo "Targets in $(basename $(lastword $(MAKEFILE_LIST))):" >&2
	@$(REMAKE) -s --print-data-base --question no-such-target 2>/dev/null | \
	grep -Ev  -e '^taskrc.mk' -e '^help' -e '^(Makefile|GNUmakefile|makefile|no-such-target)' | \
	awk '/^[^.%][-A-Za-z0-9_]*:/ \
			{ print substr($$1, 1, length($$1)-1) }' | \
	sort | \
	pr --omit-pagination --width=100 --columns=3

.PHONY: grepall

grepall:
    # Search all files in git from $PWD recursively.  If grepall_pattern is set,
    # the file list will be passed to grep.  Otherwise the file list itself is printed.
	@cd $(absdir) && \
		find -type d -name '.git' \
		| grep -v '/shellkit/' \
		| cat - <(echo ./shellkit-pm/shellkit/.git ) \
		| sed -e 's^\.git$$^^' > /tmp/tmp-grepall-$$$$; \
		while read xdir; do \
			( cd $$xdir && git ls-files | sed -e "s%^%$$xdir%" ); \
		done < /tmp/tmp-grepall-$$$$ > /tmp/tmp-grepall-2-$$$$; \
		[[ -n "$(grepall_pattern)" ]] && { \
			grep -E '$(grepall_pattern)'  $$(cat /tmp/tmp-grepall-2-$$$$) 2>/dev/null; \
			true; \
		} || { \
			cat /tmp/tmp-grepall-2-$$$$; \
		}; \
		rm /tmp/tmp-grepall-$$$$ /tmp/tmp-grepall-2-$$$$ &>/dev/null; \



