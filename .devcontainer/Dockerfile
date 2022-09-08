# Dockerfile for shellkit.workspace/.devcontainer

FROM shellkit-test-base:latest as vsudo-base

SHELL ["/bin/bash", "-c"]

RUN which yum && { \
        yum update -y \
        && yum install -y sudo; \
    } || { \
       apt-get update \
        && apt-get install -y sudo; \
    }

COPY ./bin/user-build.sh /bin/

RUN test -f /bin/user-build.sh \
    && touch /.dockerenv \
    && /bin/user-build.sh \
    && echo '%sudo  ALL=(ALL:ALL) ALL' >> /etc/sudoers

FROM vsudo-base as withtools

RUN pkgs="curl make git rsync"; \
    which $pkgs || { \
        apt-get update \
        && apt-get install -y $pkgs;  \
    }

FROM withtools as withpython

RUN apt-get update && apt-get install -y python3.8


