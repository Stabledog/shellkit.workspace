# shellkit-component.mk

Component:=$(undefined you must supply Component setting on the command line to make)
SHELL:=/bin/bash

Baseimg:=$(shell bin/get_metabase.sh $(Component) )
# You can override Runas if you want to be root in the container:
Runas:=-u $(shell id -u)

.PHONY: sanity-check
sanity-check:
	@[[ -n "$(Component)" ]] || { echo "Error: Component not defined" ; exit 1; }
	@[[ -n "$(Baseimg)" ]] || { echo "Error Baseimg not defined for $(Component)"; exit 1; }
	@true


.PHONY: image
image: sanity-check
	sed \
		-e "s|<component-name>|$(Component)|" \
		-e "s|<base-image-name>|$(Baseimg)|" \
		$(Component).dockerfile \
		|  \
		BUILDKIT_PROGRESS=plain docker build -t $(Component) -

.PHONY: run
run: sanity-check
	@# e.g. make -f shellkit-component.mk Component=shellkit-pytest Volumes="-v xxx:/yyy" Command="python3.8 -m pytest /yyy"
	docker run $(Runas) $(Volumes) --rm -it $(Component):latest bash -c "$(Command)"


