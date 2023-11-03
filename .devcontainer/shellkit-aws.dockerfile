# shellkit-aws.dockerfile
FROM <base-image-name>

RUN apt-get update -y && apt-get install -y python3.8-awscli

RUN useradd -u <uuid> -m <username>
LABEL com.sanekits.shellkit.component-name <component-name>

WORKDIR /workspace
