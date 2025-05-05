FROM docker.io/pytorch/pytorch:2.2.0-cuda12.1-cudnn8-runtime

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV GDAL_VERSION=3.10.3

# Install GDAL and system tools
RUN apt-get update && apt-get install -y \
    libpq-dev \
    libpq5=12.2.4 \ 
    libpq-dev \ 
    software-properties-common \
    && add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable \
    && apt-get update && apt-get install -y \
    gdal-bin \
    python3-gdal \
    aptitutde \ 
    python3-dev \
    build-essential \
    zsh \
    git \
    curl \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN aptitude install libgdal-dev

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH="/root/.local/bin:$PATH"


# Set GDAL-related environment variables
ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal
ENV GDAL_INCLUDE_DIR=/usr/include/gdal
ENV GDAL_LIBRARY_PATH=/usr/lib/libgdal.so

# Set default shell to Zsh
SHELL ["/bin/zsh", "-c"]

# Set working directory
WORKDIR /workspace

# Poetry install will run after mount in postCreateCommand
