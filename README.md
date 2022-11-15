# Shellkit maintenance environment


## Setup
- Clone shellkit.workspace into WSL, e.g. `~/projects/shellkit.workspace`
- If you have a custom `shellkit-environment.mk`, symlink it to `$HOME/shellkit-environment.mk`
- Run `make setup-workspace`
- Run `cd .devcontainer && make -f taskrc.mk shellkit-test-withtools` to build the development environment image
- Open VSCode and do `Reopen in container`

## Key components

### `./Makefile`:
- This is the primary tool for launch/build/environment setup
- This depends on `./environment.mk`, which may be customized for the host

### `./environment.mk`:
- This is included by `./Makefile`
- It is intended to be a symlink to ~/shellkit-environment.mk, and ultimately may point outside of the shellkit workspace
- There's a Makefile target which creates this 2-level indirection via HOME, using `./default-environment.mk` as the final target

### `./default-environment.mk`:
- Only used if there's no `./environment.mk`
- New public kits should be added here *(changes must be manually replicated into your custom version if it exists)*

### `$ShellkitWorkspace`:
- This maps to the parent of all the shellkits, such that `ls */version` would list all version files, etc.
- Should be set independently of anything in the shellkit workspace *(e.g. the host's ~/.bashrc)*  if you don't like the value that comes in `./default-environment.mk`
- Value is propagated to inner instances of `docker`, `docker-compose` so they can produce correct volume mappings during docker-in-docker invocations.
