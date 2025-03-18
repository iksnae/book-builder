# Book Builder

A Docker image for building books in GitHub workflows.

## Overview

`iksnae/book-builder` is a Docker image designed to build and publish books from Markdown sources. The image contains all necessary tools for generating books in PDF, EPUB, MOBI, and HTML formats, with a focus on use in GitHub Actions workflows.

## Key Components

- **Pandoc** - For markdown conversion to various formats
- **LaTeX (TexLive)** - For high-quality PDF generation
- **Calibre** - For MOBI (Kindle) conversion
- **Node.js** - For JavaScript-based build scripts

## Using in GitHub Workflows

The primary use case for this image is in GitHub Actions workflows:

```yaml
name: Build Book

on:
  push:
    branches: [main]
    paths:
      - 'book/**'
      - 'art/**'
      - 'templates/**'
      - 'build.sh'
  workflow_dispatch:

permissions:
  contents: write  # Required for creating releases

jobs:
  build:
    runs-on: ubuntu-latest

    container:
      image: iksnae/book-builder:latest

    steps:
      - uses: actions/checkout@v4

      - name: Set version and date
        id: version
        run: |
          VERSION=$(date +'v%Y.%m.%d-%H%M')
          echo "VERSION=$VERSION" >> $GITHUB_ENV
          echo "DATE=$(date +'%B %d, %Y')" >> $GITHUB_ENV

      - name: Create build directories
        run: mkdir -p build

      - name: Build book
        run: |
          chmod +x build.sh
          ./build.sh

      # Additional steps for artifacts, releases, etc.
```

## Supported Project Structures

This image supports common book project structures:

```
my-book-project/
├── book/               # Main content directory
│   ├── en/             # English content
│   │   ├── chapter-1/  # Chapter directories
│   │   └── chapter-2/
│   └── es/             # Spanish content (optional)
├── art/                # Cover images and other artwork
├── templates/          # LaTeX or other templates
├── tools/              # Custom build scripts (Node.js)
└── build.sh            # Build script
```

For an example of the expected structure, see the [rise-and-code](https://github.com/iksnae/rise-and-code) or [actual-intelligence](https://github.com/iksnae/actual-intelligence) repositories.

## Build Features

- Multi-language book generation
- Cover image support
- PDF generation with LaTeX templates
- EPUB and MOBI generation for e-readers
- HTML generation for web publishing
- GitHub Pages deployment support
- Release creation with assets

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
