# Dockerfile for shellkit.workspace/.devcontainer

FROM shellkit-test-base:latest

COPY ./bin/user-build.sh /bin/

RUN test -f /bin/user-build.sh

RUN yum update -y \
    && yum install -y sudo \
    || apt-get update \
    && apt-get install -y sudo 

RUN echo '%sudo  ALL=(ALL:ALL) ALL' >> /etc/sudoers 


RUN ls / 

RUN touch /.dockerenv \
    && /bin/user-build.sh
