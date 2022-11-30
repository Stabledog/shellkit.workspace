# shellkit-pytest.dockerfile

FROM <base-image-name>

RUN python3.8 -m pip install  pytest

LABEL com.sanekits.shellkit.component-name <component-name>
