# Shellkit maintenance environment


## Setup
- Clone shellkit.workspace into WSL, e.g. `~/projects/shellkit.workspace`
- If you have a custom `shellkit-environment.mk`, symlink it to `$HOME/shellkit-environment.mk`
- Run `make setup-workspace`
- Run `cd .devcontainer && make -f taskrc.mk shellkit-test-withtools` to build the development environment image
- Open VSCode and do `Reopen in container`

## Maintenance tasks

### Git sync
- `make git-status` in the root to see all changes
- `make git-pull && make git-push` to sync

## Key components

### `./Makefile`:
- This is the primary tool for launch/build/environment setup
- This depends on `./environment.mk`, which is always a symlink customized for the host

### `./environment.mk`:
- This is included by `./Makefile`
- It is alway a symlink to ~/shellkit-environment.mk, which should be preserved outside the shellkit workspace
- If you run the `setup-workspace` target without a `~/shellkit-workspace.mk`, then a new default environment is generated from `./default-environment.mk`
- This symlink is automatically updated when entering docker environment to deal with `/host_home` indirection.

### `./default-environment.mk`:
- Only used if there's no `./environment.mk`
- New public kits should be added here *(changes must be manually replicated into your custom version if it exists)*

### `$ShellkitWorkspace`:
- This maps to the parent of all the shellkits, such that `ls */version` would list all version files, etc.
- Should be set independently of anything in the shellkit workspace *(e.g. the host's ~/.bashrc)*  if you don't like the value that comes in `./default-environment.mk`
- Value is propagated to inner instances of `docker`, `docker-compose` so they can produce correct volume mappings during docker-in-docker invocations.

### `$HostHome`:
- Refers to the host environment's HOME tree, which provides the ultimate anchor for volume mounting of shared stuff.  In a docker-in-docker env, this would still say /home/your-real-username.

### `<Kit>/shellkit-ref`:
- Per-kit optional config file
- Specifies the shellkit branch or ref to check out for the embedded `./shellkit/` node of the kit tree
- This permits kits to "pin" to specific (e.g. older or newer) variants of shellkit shared code.
- Supported in primary `make` workflow
- If not present, implies `main` branch
