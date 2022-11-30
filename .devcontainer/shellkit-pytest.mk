# shellkit-pytest.mk

Component=shellkit-pytest
SHELL=/bin/bash
Baseimg=$(shell bin/get_metabase.sh $(Component) )


.PHONY: image
image:
	sed \
		-e "s|<component-name>|$(Component)|" \
		-e "s|<base-image-name>|$(Baseimg)|" \
		$(Component).dockerfile \
		|  \
		BUILDKIT_PROGRESS=plain docker build -t $(Component) -

.PHONY: run
run:
	@docker run $$Volumes --rm -it $(Component):latest $$Cmdline


