# environment.mk TEMPLATE
#   (originally created from default-environment.mk)
# See main README.md
#


# workspace_packages is the set of user-installable packages being maintained in this workspace.
workspace_packages:=\
bashics \
cdpp\
docktools\
gh-help\
gitsmart\
localhist\
looper\
prompt-command-wrap\
ps1-foo\
shellkit-meta\
shellkit-pm\
taskrc-kit\
vscode-tools\


setup_clone_urls:= \
	https://github.com/sanekits/bashics \
	https://github.com/sanekits/cdpp \
	https://github.com/sanekits/docktools \
	https://github.com/Stabledog/gh-help \
	https://github.com/sanekits/gitsmart \
	https://github.com/sanekits/localhist \
	https://github.com/sanekits/looper \
	https://github.com/sanekits/prompt-command-wrap \
	https://github.com/sanekits/ps1-foo \
	https://github.com/sanekits/shellkit-meta \
	https://github.com/sanekits/shellkit-pm \
	https://github.com/sanekits/taskrc-kit \
	https://github.com/sanekits/vscode-tools \

ShellkitWorkspace=${absdir}
# On a new environment, you must set HostHome in your custom ~/shellkit-environment.mk,
# e.g. HostHome=/home/myusername.  This gets propagated through docker-in-docker invocations
# so that inner environments can use it to map volumes into containers.
HostHome=/default/host/home/undefined
