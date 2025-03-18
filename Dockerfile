FROM ubuntu:22.04

LABEL maintainer="iksnae"
LABEL description="Docker image for building books"

# Set non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install basic dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    python3 \
    python3-pip \
    texlive-full \
    pandoc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip3 install --no-cache-dir \
    jupyter \
    nbconvert \
    markdown \
    pyyaml

# Set working directory
WORKDIR /book

# Default command
CMD ["/bin/bash"]
