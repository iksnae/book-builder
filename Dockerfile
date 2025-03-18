FROM ubuntu:20.04

LABEL maintainer="iksnae"
LABEL description="Docker image for building books"

# Set non-interactive installation and prevent dpkg output from being blocked
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NOWARNINGS="yes"

# Install required dependencies for book building
RUN apt-get update && apt-get install -y \
    pandoc \
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-latex-extra \
    curl \
    git \
    build-essential \
    python3 \
    python3-pip \
    wget \
    unzip \
    default-jre \
    calibre \
    librsvg2-bin \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js directly instead of using NVM
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

# Set working directory
WORKDIR /workspace

# Copy package.json and install dependencies if they exist
COPY package*.json ./
RUN if [ -f "package.json" ]; then npm install; fi

# Copy the rest of the files
COPY . /workspace/

# Make build script executable
RUN if [ -f "build.sh" ]; then chmod +x build.sh; fi

# Default command
CMD ["/bin/bash"]
