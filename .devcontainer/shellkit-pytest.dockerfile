# shellkit-pytest.dockerfile

FROM <base-image-name>

RUN python3.8 -m pip install  pytest pudb debugpy

LABEL com.sanekits.shellkit.component-name <component-name>

WORKDIR /workspace
