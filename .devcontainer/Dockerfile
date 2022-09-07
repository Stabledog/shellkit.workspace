# Dockerfile for shellkit.workspace/.devcontainer

FROM shellkit-test-base:latest as vsudo-base

RUN yum update -y \
    && yum install -y sudo \
    || apt-get update \
    && apt-get install -y sudo

COPY ./bin/user-build.sh /bin/

RUN test -f /bin/user-build.sh \
    && touch /.dockerenv \
    && /bin/user-build.sh \
    && echo '%sudo  ALL=(ALL:ALL) ALL' >> /etc/sudoers

FROM vsudo-base as withtools

RUN which curl && which make && which git || { \
     apt-get install -y curl git make;  \
}



