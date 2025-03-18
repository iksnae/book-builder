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
    ca-certificates \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js directly - split installation steps for better debugging
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get update && apt-get install -y nodejs && apt-get clean && rm -rf /var/lib/apt/lists/*

# Version check and npm update (separated for better error handling)
RUN node --version
RUN npm --version
RUN npm install -g npm@latest || echo "npm update failed, but continuing with build"

# Create workspace directory
WORKDIR /workspace

# Expose volume for book content
VOLUME ["/workspace"]

# Default command
CMD ["/bin/bash"]
