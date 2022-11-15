# Dockerfile for shellkit.workspace/.devcontainer

ARG http_proxy

FROM localbuilt/shellkit-test-base:latest as vsudo-base

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

RUN pkgs="curl make unzip git rsync less"; \
    which $pkgs || { \
        apt-get update \
        && apt-get install -y $pkgs;  \
    }

COPY ./ /tmp/build/

ENV https_proxy=$http_proxy
ENV http_proxy=$http_proxy

RUN https_proxy=$http_proxy http_proxy=$http_proxy /tmp/build/bin/docker-compose-install.sh

RUN yum install -y openssh-clients  \
    || { \
        DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-client ; \
    }


RUN https_proxy=$http_proxy http_proxy=$http_proxy /tmp/build/bin/py-install.sh --target-version 3.8
RUN bash -l -c 'python3.8 --version'

COPY ./bin/aws-install.sh /bin/
RUN https_proxy=$http_proxy http_proxy=$http_proxy /tmp/build/bin/aws-install.sh /bin/

COPY ./bin/gh-install.sh /bin/
RUN https_proxy=$http_proxy http_proxy=$http_proxy /tmp/build/bin/gh-install.sh


# There's a git credential helper we don't like:
RUN mv /etc/gitconfig /etc/gitconfig.bak.$$ || :


