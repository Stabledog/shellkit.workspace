# README for `shellkit.workspace/.devcontainer`

## Processes:

- Check image status:

    `tkr; tmk check-image-status`

- Build the main image: *(~ 10 min)*

    `tkr; tmk clean shellkit-test-withtools`

- Run the container in shell:

    `tkr; tmk tc-up && tmk dc-shell`

- Reset make state: *(Does not remove images or containers)*

    `tkr; tmk clean`

### Docker-in-docker support:
TODO write this content

## Components:

### `bin/get_metabase.sh`
- This does a network probe to select the available upstream base image, either `bbgo/golang:ubuntu20` or internet `golang:1.19-bullseye`

- Output of this is `stdout`, as it is invoked from [taskrc.mk]

### `taskrc.mk`:
- This builds  `localbuilt/shellkit-test-withtools`

### `localbuilt/shellkit-test-base:latest`:
- This is the most thoroughly tooled image in the stack, includes `python3`,`openssh`, `aws`, `gh/ghe`, `curl`,`make`,`unzip`,`git`,`rsync`,`less`
- This is the best dev environment for most kit work
- This supports docker-in-docker: e.g. automated tests owned by kits can run in this and still invoke docker on their SUT.  See `docker-in-docker` above.
