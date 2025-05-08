FROM ghcr.io/osgeo/gdal:ubuntu-small-latest-arm64

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:$PATH"

# Install system tools and add deadsnakes PPA for Python 3.11
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    git \
    bash \
    zsh \
    build-essential \
    libffi-dev \
    libssl-dev \
    zlib1g-dev \
    libproj-dev \
    proj-data \
    proj-bin \
    libgeos-dev \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.11 as default for python and pip
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 \
 && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
 && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

RUN apt-get update && apt-get install -y \
libhdf5-dev \
libnetcdf-dev \
&& rm -rf /var/lib/apt/lists/*

# Install Python-level dependencies with pip (not Poetry)

# Create and activate a virtual environment
ENV VIRTUAL_ENV=/opt/venv
RUN python -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN $VIRTUAL_ENV/bin/pip install --no-cache-dir h5netcdf h5py
RUN $VIRTUAL_ENV/bin/pip install --no-cache-dir "hvplot[recommended]"

# Install Poetry with Python 3.11
RUN curl -sSL https://install.python-poetry.org | python3.11 -

# Poetry env vars
ENV POETRY_PYTHON=/usr/bin/python3.11
ENV PATH="/root/.local/bin:$PATH"

# Set working directory
WORKDIR /workspace

# Copy only dependency files to leverage Docker cache
COPY pyproject.toml poetry.lock* ./

# Set Poetry to use in-project virtualenvs
RUN poetry config virtualenvs.in-project true

# Lock dependencies (optional if poetry.lock already exists)
RUN poetry lock

# Install dependencies
RUN poetry install --no-interaction --no-ansi

# Register Jupyter kernel
RUN poetry run python3 -m ipykernel install --user --name=devcontainer --display-name 'Python (DevContainer)'
# Optional: switch to zsh as default shell
# Enable widget extensions locally (fix for offline CDN errors)
ENV JUPYTERLAB_DIR=/opt/venv/share/jupyter/lab
# RUN poetry add notebook ipywidgets
# RUN poetry run jupyter nbextension enable --py widgetsnbextension --sys-prefix

SHELL ["/bin/zsh", "-c"]
