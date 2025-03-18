FROM ubuntu:22.04

LABEL maintainer="iksnae"
LABEL description="Docker image for building books in multiple formats (PDF, EPUB, MOBI, HTML)"

# Set non-interactive installation and prevent dpkg output from being blocked
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NOWARNINGS="yes"

# Install required dependencies and tools
RUN apt-get update && apt-get install -y \
    # PDF generation tools
    pandoc \
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-latex-extra \
    # EPUB/MOBI generation tools
    calibre \
    # Image processing tools
    librsvg2-bin \
    # Basic utilities
    curl \
    wget \
    git \
    zip \
    unzip \
    python3 \
    python3-pip \
    build-essential \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js directly (no NVM needed)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get update \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && npm install -g npm@latest

# Create workspace directory
WORKDIR /workspace

# Check Node.js and npm installation
RUN node --version && npm --version

# Expose volume for book content
VOLUME ["/workspace"]

# Default command
CMD ["/bin/bash"]
