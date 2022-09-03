# environment.mk TEMPLATE
#   (originally created from templates/default-environment.mk)
#
# This gets copied to ~/.shellkit-environment.mk (or wherever you like, as
# long as it's independently source-controlled somewhere OUTSIDE of the
# shellkit.workspace source repo)
#
#  Then you should have a symlink from that controlled file to ./environment.mk


# workspace_packages is the set of user-installable packages being maintained in this workspace.  You can capture initial data for "workspace_members" by running "make print-subgits" in an existing workspace and removing anything that's not a publishable package.
workspace_packages:=cdpp docktools gh-help gitsmart localhist ps1-foo bcs-test shellkit-meta shellkit-pm taskrc-kit

setup_clone_urls:= \
	https://github.com/sanekits/cdpp \
	https://github.com/sanekits/docktools \
	https://github.com/Stabledog/gh-help \
	https://github.com/sanekits/gitsmart \
	https://github.com/sanekits/localhist \
	https://github.com/sanekits/ps1-foo \
	https://github.com/sanekits/shellkit-meta \
	https://github.com/sanekits/shellkit-pm \
	https://github.com/sanekits/taskrc-kit \

ShellkitWorkspace=${absdir}
