# Dockerfile for shellkit.workspace/.devcontainer

FROM shellkit-test-base:latest as vsudo-base

SHELL ["/bin/bash", "-c"]

RUN set -x; which yum && { \
        yum update -y \
        && yum install -y sudo; \
    } || { \
        echo "No yum, trying apt-get:"; \
        apt-get update -y \
        && apt-get install -y sudo locales \
        && locale-gen "en_US.UTF-8" ; \
    }

COPY ./bin/user-build.sh /bin/

RUN test -f /bin/user-build.sh \
    && touch /.dockerenv \
    && /bin/user-build.sh \
    && echo '%sudo  ALL=(ALL:ALL) ALL' >> /etc/sudoers

FROM vsudo-base as withtools

RUN pkgs="curl make git rsync less"; \
    which $pkgs || { \
        apt-get update \
        && apt-get install -y $pkgs;  \
    }

RUN yum install -y openssh-clients docker \
    || { \
        DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-client docker; \
    }


FROM withtools as withpython

RUN apt-get update && apt-get install -y python3.8


