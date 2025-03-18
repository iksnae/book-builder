#!/bin/bash
# Reliable EPUB generation script for book-builder Docker image
# This script handles image inclusion in EPUBs consistently

set -e

# Display help if needed
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  echo "Usage: generate-epub [options] INPUT_FILE OUTPUT_FILE"
  echo ""
  echo "Options:"
  echo "  --title TITLE           Book title"
  echo "  --author AUTHOR         Book author/creator"
  echo "  --publisher PUBLISHER   Book publisher"
  echo "  --cover COVER_IMAGE     Path to cover image"
  echo "  --language LANG         Book language code (e.g., en, es)"
  echo "  --resource-path PATHS   Resource search paths (colon-separated)"
  echo "  --toc-depth DEPTH       Table of contents depth (default: 2)"
  echo "  --verbose               Show detailed processing information"
  echo ""
  echo "Examples:"
  echo "  generate-epub --title \"My Book\" --cover cover.png input.md output.epub"
  echo "  generate-epub --resource-path \".:images:build/images\" input.md output.epub"
  exit 0
fi

# Default values
TITLE="Book"
AUTHOR="Author"
PUBLISHER="Publisher"
COVER_IMAGE=""
LANGUAGE="en"
RESOURCE_PATH="."
TOC_DEPTH=2
VERBOSE=false
TEMP_DIR=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --title)
      TITLE="$2"
      shift 2
      ;;
    --author)
      AUTHOR="$2"
      shift 2
      ;;
    --publisher)
      PUBLISHER="$2"
      shift 2
      ;;
    --cover)
      COVER_IMAGE="$2"
      shift 2
      ;;
    --language)
      LANGUAGE="$2"
      shift 2
      ;;
    --resource-path)
      RESOURCE_PATH="$2"
      shift 2
      ;;
    --toc-depth)
      TOC_DEPTH="$2"
      shift 2
      ;;
    --verbose)
      VERBOSE=true
      shift
      ;;
    *)
      if [ -z "$INPUT_FILE" ]; then
        INPUT_FILE="$1"
      elif [ -z "$OUTPUT_FILE" ]; then
        OUTPUT_FILE="$1"
      else
        echo "Error: Unknown argument $1"
        exit 1
      fi
      shift
      ;;
  esac
done

# Check required arguments
if [ -z "$INPUT_FILE" ] || [ -z "$OUTPUT_FILE" ]; then
  echo "Error: Input and output files are required"
  echo "Run 'generate-epub --help' for usage information"
  exit 1
fi

# Make sure input file exists
if [ ! -f "$INPUT_FILE" ]; then
  echo "Error: Input file $INPUT_FILE does not exist"
  exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Set up temp directory
TEMP_DIR=$(mktemp -d -t epub-gen-XXXXXXXXXX)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Verbose output if requested
if [ "$VERBOSE" = true ]; then
  echo "Generating EPUB with the following settings:"
  echo "  Input: $INPUT_FILE"
  echo "  Output: $OUTPUT_FILE"
  echo "  Title: $TITLE"
  echo "  Author: $AUTHOR"
  echo "  Publisher: $PUBLISHER"
  echo "  Language: $LANGUAGE"
  echo "  Cover image: $COVER_IMAGE"
  echo "  Resource path: $RESOURCE_PATH"
  echo "  Temp directory: $TEMP_DIR"
fi

# Create a metadata file
METADATA_FILE="$TEMP_DIR/metadata.yaml"
cat > "$METADATA_FILE" << EOF
---
title: "$TITLE"
creator: "$AUTHOR"
publisher: "$PUBLISHER"
rights: "Copyright © $(date +%Y) $AUTHOR"
language: "$LANGUAGE"
---
EOF

# Copy input file to temp directory
TEMP_INPUT="$TEMP_DIR/content.md"
cp "$INPUT_FILE" "$TEMP_INPUT"

# Adjust image paths if needed
if [ -n "$RESOURCE_PATH" ]; then
  # Copy all possible images to temp directory
  mkdir -p "$TEMP_DIR/images"
  IFS=':' read -ra PATHS <<< "$RESOURCE_PATH"
  for path in "${PATHS[@]}"; do
    if [ -d "$path" ]; then
      find "$path" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" -o -name "*.svg" \) -exec cp {} "$TEMP_DIR/images/" \; 2>/dev/null || true
    fi
  done
  
  # Process cover image
  if [ -n "$COVER_IMAGE" ] && [ -f "$COVER_IMAGE" ]; then
    cp "$COVER_IMAGE" "$TEMP_DIR/cover$(basename "$COVER_IMAGE")"
    COVER_IMAGE="$TEMP_DIR/cover$(basename "$COVER_IMAGE")"
  fi
  
  # List images found
  if [ "$VERBOSE" = true ]; then
    echo "Images found:"
    ls -la "$TEMP_DIR/images/"
  fi
fi

# Build command with proper options
PANDOC_CMD=("pandoc" "$TEMP_INPUT" "-o" "$OUTPUT_FILE" "--metadata-file=$METADATA_FILE" "--toc" "--toc-depth=$TOC_DEPTH")

# Add cover image if available
if [ -n "$COVER_IMAGE" ] && [ -f "$COVER_IMAGE" ]; then
  PANDOC_CMD+=("--epub-cover-image=$COVER_IMAGE")
fi

# Add resource path
PANDOC_CMD+=("--resource-path=$TEMP_DIR:$TEMP_DIR/images:$RESOURCE_PATH")

# Add extract media option
PANDOC_CMD+=("--extract-media=$TEMP_DIR/media")
PANDOC_CMD+=("--self-contained")

# Execute the command
if [ "$VERBOSE" = true ]; then
  echo "Running: ${PANDOC_CMD[*]}"
fi

"${PANDOC_CMD[@]}"

# Check result
if [ -f "$OUTPUT_FILE" ]; then
  # Get file size
  FILE_SIZE=$(du -k "$OUTPUT_FILE" | cut -f1)
  
  if [ "$VERBOSE" = true ]; then
    echo "EPUB file created: $OUTPUT_FILE ($FILE_SIZE KB)"
  fi
  
  # Warn if file is suspiciously small (likely missing images)
  if [ "$FILE_SIZE" -lt 100 ]; then
    echo "Warning: EPUB file is very small ($FILE_SIZE KB). Images may be missing."
    echo "Try running with --verbose for more information."
  else
    echo "✓ EPUB generated successfully."
    exit 0
  fi
else
  echo "Error: Failed to create EPUB file."
  exit 1
fi
