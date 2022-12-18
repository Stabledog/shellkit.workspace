# shellkit-bashup.dockerfile
FROM <base-image-name>

RUN useradd -u <uuid> -m <username>
LABEL com.sanekits.shellkit.component-name <component-name>

RUN apt-get update && apt-get install -y bash-completion

WORKDIR /workspace
