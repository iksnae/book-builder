# Book Builder

A Docker image for building and publishing books in multiple formats (PDF, EPUB, MOBI, HTML).

## Overview

`iksnae/book-builder` is a Docker image that contains tools and dependencies for building books in various formats, powered by Pandoc, LaTeX, and Node.js. It's designed to simplify the process of creating professional-quality books from Markdown sources.

## Features

- **Multiple Output Formats:** Generate PDF, EPUB, MOBI, and HTML from the same source files
- **Customizable Templates:** Use the included templates or provide your own
- **Language Support:** Build books in multiple languages
- **Automated Workflows:** Includes GitHub Actions workflow for automated builds
- **Complete Environment:** All required dependencies are included in the Docker image

## Usage

### Pull the Docker Image

```bash
docker pull iksnae/book-builder:latest
```

### Basic Usage

1. Mount your book directory to the container:

```bash
docker run -v $(pwd):/workspace iksnae/book-builder ./build.sh
```

### Configuration

Create a `book-config.yml` file in your project's `config` directory. See the example in [config/book-config.yml](config/book-config.yml).

### Command Line Options

The `build.sh` script accepts several options:

```
Options:
  -c, --config FILE    Specify configuration file (default: config/book-config.yml)
  -o, --output DIR     Specify output directory (default: build)
  -l, --lang LANG      Specify language code (default: en)
  -f, --format FORMAT  Build only specific format (pdf, epub, html, mobi)
  -h, --help           Show this help message
```

Example:
```bash
docker run -v $(pwd):/workspace iksnae/book-builder ./build.sh --config mybook.yml --output ./output --lang es
```

## Repository Structure

```
book-builder/
├── .github/workflows/    # GitHub Actions workflows
├── config/               # Configuration files
├── scripts/              # Build scripts
├── templates/            # Templates for book content
│   ├── chapters/         # Chapter templates
│   ├── frontmatter/      # Title page, copyright, etc.
│   └── styles/           # CSS styles for output formats
├── Dockerfile            # Docker image definition
├── build.sh              # Main build script
└── README.md             # Documentation
```

## GitHub Actions Integration

This repository includes a GitHub Actions workflow that builds and publishes the Docker image to Docker Hub and GitHub Container Registry. To use it, set up the following secrets in your repository:

- `DOCKERHUB_USERNAME`: Your Docker Hub username
- `DOCKERHUB_TOKEN`: A Docker Hub access token

## Building the Image Locally

```bash
git clone https://github.com/iksnae/book-builder.git
cd book-builder
docker build -t iksnae/book-builder .
```

## Using with Your Own Book Project

1. Set up your book project with the following structure:

```
my-book/
├── book/
│   ├── chapters/
│   │   ├── 01-introduction.md
│   │   ├── 02-main-content.md
│   │   └── 03-conclusion.md
│   └── images/
│       └── cover.png
├── config/
│   └── book-config.yml
└── build.sh (optional)
```

2. Run the container:

```bash
docker run -v $(pwd):/workspace iksnae/book-builder ./build.sh
```

3. Find your outputs in the `build` directory.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
