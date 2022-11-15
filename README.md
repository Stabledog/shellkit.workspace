# Shellkit maintenance environment


## Setup

## Understanding key components

### `./Makefile`:
- This is the primary tool for launch/build/environment setup
- This depends on `./environment.mk`, which may be customized for the host

### `./environment.mk`:
- This is included by `./Makefile`
- It is intended to be a symlink to ~/.shellkit-environment.mk, and ultimately may point outside of the shellkit workspace
- There's a Makefile target which creates this 2-level indirection via HOME, using `./default-environment.mk` as the final target

### `./default-environment.mk`:
- Only used if there's no `./environment.mk`
- New public kits should be added here

### `$ShellkitWorkspace`:
- This maps to the parent of all the shellkits, such that `ls */version` would list all version files, etc.
- Should be set **independently of anything in the shellkit workspace**, e.g. the host's ~/.bashrc or something
- Inherited by inner instances of `docker`, `docker-compose` so they can produce correct volume mappings
