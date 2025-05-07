FROM ghcr.io/osgeo/gdal:alpine-small-latest@sha256:2e579408a14e5ed72d843293993730ed1b1a35fe3efbebf7dbb2ff7c1cba71ea


# Avoid interactive prompts
# ENV DEBIAN_FRONTEND=noninteractive
# ENV GDAL_VERSION=3.10.3

# Install GDAL and system tools
RUN apk add --no-cache \
      bash \
      zsh \
      git \
      curl \
      sudo \
      build-base \         
      python3-dev        
# RUN aptitude install libgdal-dev

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH="/root/.local/bin:$PATH"


# # Set GDAL-related environment variables
# ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
# ENV C_INCLUDE_PATH=/usr/include/gdal
# ENV GDAL_INCLUDE_DIR=/usr/include/gdal
# ENV GDAL_LIBRARY_PATH=/usr/lib/libgdal.so

# Set default shell to Zsh
SHELL ["/bin/zsh", "-c"]

# Set working directory
WORKDIR /workspace

# Poetry install will run after mount in postCreateCommand
