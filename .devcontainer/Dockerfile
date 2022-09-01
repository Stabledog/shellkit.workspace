# Dockerfile for shellkit.workspace/.devcontainer

FROM shellkit-test-base:latest

RUN yum update -y \
    && yum install -y sudo \
    && echo '%sudo  ALL=(ALL:ALL) ALL' >> /etc/sudoers

COPY bin /build-bin

RUN touch /.dockerenv \
    && /build-bin/user-build.sh
