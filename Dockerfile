FROM ghcr.io/osgeo/gdal:ubuntu-small-latest

# Avoid interactive prompts during package installs
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:$PATH"

# Add deadsnakes PPA and install Python 3.11 + dependencies
RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y \
    
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    python3-gdal \
    
    libhdf5-dev \
    libnetcdf-dev \
    build-essential \
    libffi-dev \
    libssl-dev \
    zlib1g-dev \
    libproj-dev \
    proj-data \
    proj-bin \
    libgeos-dev \
    curl \
    git \
    bash \
    zsh \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.11 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# Create and activate a virtualenv
ENV VIRTUAL_ENV=/opt/venv
RUN python -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install Poetry using Python 3.11
RUN curl -sSL https://install.python-poetry.org | python3.11 -
ENV PATH="/root/.local/bin:$PATH"
ENV POETRY_PYTHON=/usr/bin/python3.11

# Set working directory
WORKDIR /workspace

# Copy only dependency files to leverage Docker cache
COPY pyproject.toml poetry.lock* ./

# Set Poetry to use in-project virtualenvs
RUN poetry config virtualenvs.in-project false

# Lock dependencies (optional if poetry.lock already exists)
RUN poetry lock

# Install dependencies
RUN poetry install --no-interaction --no-ansi

# Install Python GDAL bindings (closest match for GDAL 3.12.0dev)
RUN $VIRTUAL_ENV/bin/pip install --no-cache-dir gdal==3.10.3
RUN $VIRTUAL_ENV/bin/pip install --no-cache-dir geoviews[recommended]

# Register Jupyter kernel
RUN poetry run python3 -m ipykernel install --user --name=devcontainer --display-name 'Python (DevContainer)'
# Optional: switch to zsh



SHELL ["/bin/zsh", "-c"]
