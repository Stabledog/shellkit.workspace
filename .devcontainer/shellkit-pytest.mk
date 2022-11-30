# shellkit-pytest.mk

Component=shellkit-pytest
SHELL=/bin/bash
Baseimg=$(shell bin/get_metabase.sh $(Component) )

.PHONY: image
image:
	docker build -t $(Component) - \
		< <( sed -e "s|<component-name>|$(Component)|" -e "s|<base-image-name>|$(Baseimg)|" $(Component).dockerfile )
