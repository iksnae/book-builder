# Book Builder

Docker container for building books in multiple formats (PDF, EPUB, MOBI, HTML).

## Overview

This container provides all necessary tools to convert Markdown files into various book formats, handling formatting, image inclusion, and proper metadata. It encapsulates the complexity of the book-building process, including all required dependencies.

## Features

- Generate PDFs with proper formatting and typography
- Create EPUBs with reliable image inclusion
- Convert EPUBs to MOBI format for Kindle
- Build standalone HTML versions
- All necessary tools pre-installed and configured

## Usage

### Basic Usage

```bash
docker run -v $(pwd):/workspace iksnae/book-builder ./build.sh
```

### Specific Format

```bash
docker run -v $(pwd):/workspace iksnae/book-builder ./build.sh --format pdf
```

### Advanced Options

```bash
docker run -v $(pwd):/workspace iksnae/book-builder ./build.sh \
  --config my-config.yml \
  --output ./my-books \
  --lang es
```

## Included Utilities

The container includes several specialized tools:

### `generate-epub` - Reliable EPUB Generation

This utility ensures images are properly included in EPUB files:

```bash
generate-epub --title "My Book" --cover cover.png input.md output.epub
```

Options:

- `--title` - Book title
- `--author` - Book author/creator
- `--publisher` - Book publisher
- `--cover` - Path to cover image
- `--language` - Book language code (e.g., en, es)
- `--resource-path` - Resource search paths (colon-separated)
- `--toc-depth` - Table of contents depth
- `--verbose` - Show detailed processing information

## Directory Structure

When using this container, organize your book project with this recommended structure:

```
.
├── book/
│   ├── en/              # English content
│   │   ├── chapter-01/  # Chapters
│   │   │   ├── 00-introduction.md
│   │   │   └── 01-content.md
│   │   └── images/      # English-specific images
│   ├── es/              # Spanish content
│   │   └── ...
│   └── images/          # Shared images
├── art/
│   └── cover.png        # Cover image
├── config/
│   └── book-config.yml  # Configuration
└── build.sh             # Build script
```

## Troubleshooting

If you encounter issues:

1. Use the `--verbose` flag with utilities for detailed output
2. Check image paths and ensure they're accessible
3. Verify your Markdown syntax is correct
4. Run the container with the `-it` flag to interactively debug

## Building the Image

To build this Docker image locally:

```bash
git clone https://github.com/iksnae/book-builder.git
cd book-builder
docker build -t iksnae/book-builder:latest .
```

## License

See [LICENSE](LICENSE) file.
