# shellkit-aws.dockerfile
FROM <base-image-name>

RUN useradd -u <uuid> -m <username>
LABEL com.sanekits.shellkit.component-name <component-name>

WORKDIR /workspace
