#!/bin/bash
# Book Builder Script
# Automates the process of building books in various formats

set -e

# Default configuration
CONFIG_FILE="config/book-config.yml"
OUTPUT_DIR="build"
LANGUAGE="en"

# Display help
function show_help {
    echo "Book Builder - Build books in various formats"
    echo ""
    echo "Usage: ./build.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -c, --config FILE    Specify configuration file (default: config/book-config.yml)"
    echo "  -o, --output DIR     Specify output directory (default: build)"
    echo "  -l, --lang LANG      Specify language code (default: en)"
    echo "  -f, --format FORMAT  Build only specific format (pdf, epub, html, mobi)"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Example:"
    echo "  ./build.sh --config mybook.yml --output ./output --lang es"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -c|--config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -l|--lang)
            LANGUAGE="$2"
            shift 2
            ;;
        -f|--format)
            FORMAT="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file '$CONFIG_FILE' not found."
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo "===== Book Builder ====="
echo "Configuration file: $CONFIG_FILE"
echo "Output directory: $OUTPUT_DIR"
echo "Language: $LANGUAGE"
echo "======================="

# Get title from config file (assuming YAML format)
if command -v python3 &>/dev/null; then
    BOOK_TITLE=$(python3 -c "import yaml; print(yaml.safe_load(open('$CONFIG_FILE'))['title'])" 2>/dev/null || echo "book")
    BOOK_AUTHOR=$(python3 -c "import yaml; print(yaml.safe_load(open('$CONFIG_FILE'))['author'])" 2>/dev/null || echo "Unknown Author")
else
    BOOK_TITLE="book"
    BOOK_AUTHOR="Unknown Author"
fi

# Generate sanitized filename
FILENAME=$(echo "$BOOK_TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')

echo "Building '$BOOK_TITLE' by $BOOK_AUTHOR"
echo "Output filename: $FILENAME"

# Run Python build script if available
if [ -f "scripts/build.py" ]; then
    echo "Using Python build script..."
    python3 scripts/build.py --config "$CONFIG_FILE" --output-dir "$OUTPUT_DIR"
else
    # Otherwise use basic Pandoc commands
    echo "Using direct Pandoc commands..."
    
    # Find all content files from config
    if command -v python3 &>/dev/null; then
        CONTENT_FILES=$(python3 -c "import yaml; print(' '.join(yaml.safe_load(open('$CONFIG_FILE'))['content']))" 2>/dev/null || echo "")
    else
        # Fallback to looking for markdown files
        CONTENT_FILES=$(find book -name "*.md" | sort)
    fi
    
    if [ -z "$CONTENT_FILES" ]; then
        echo "Error: No content files found."
        exit 1
    fi
    
    echo "Found content files: $CONTENT_FILES"
    
    # Create temporary combined markdown file
    TEMP_MD="$OUTPUT_DIR/temp_${FILENAME}.md"
    cat $CONTENT_FILES > "$TEMP_MD"
    
    # Build PDF if requested or if no specific format
    if [ -z "$FORMAT" ] || [ "$FORMAT" = "pdf" ]; then
        echo "Building PDF..."
        pandoc "$TEMP_MD" -o "$OUTPUT_DIR/${FILENAME}.pdf" \
            --pdf-engine=xelatex \
            --toc \
            --toc-depth=3 \
            --variable=papersize:letter \
            --variable=geometry:margin=1in
        
        echo "✅ PDF created: $OUTPUT_DIR/${FILENAME}.pdf"
    fi
    
    # Build EPUB if requested or if no specific format
    if [ -z "$FORMAT" ] || [ "$FORMAT" = "epub" ]; then
        echo "Building EPUB..."
        pandoc "$TEMP_MD" -o "$OUTPUT_DIR/${FILENAME}.epub" \
            --toc \
            --epub-metadata=<(echo -e "<dc:title>$BOOK_TITLE</dc:title>\n<dc:creator>$BOOK_AUTHOR</dc:creator>")
        
        echo "✅ EPUB created: $OUTPUT_DIR/${FILENAME}.epub"
    fi
    
    # Build HTML if requested or if no specific format
    if [ -z "$FORMAT" ] || [ "$FORMAT" = "html" ]; then
        echo "Building HTML..."
        pandoc "$TEMP_MD" -o "$OUTPUT_DIR/${FILENAME}.html" \
            --standalone \
            --toc \
            --self-contained
        
        echo "✅ HTML created: $OUTPUT_DIR/${FILENAME}.html"
    fi
    
    # Build MOBI if requested or if no specific format and calibre is installed
    if ([ -z "$FORMAT" ] || [ "$FORMAT" = "mobi" ]) && command -v ebook-convert &>/dev/null; then
        echo "Building MOBI..."
        ebook-convert "$OUTPUT_DIR/${FILENAME}.epub" "$OUTPUT_DIR/${FILENAME}.mobi"
        
        echo "✅ MOBI created: $OUTPUT_DIR/${FILENAME}.mobi"
    elif [ "$FORMAT" = "mobi" ]; then
        echo "⚠️ MOBI conversion requires Calibre's ebook-convert, which is not installed"
    fi
    
    # Clean up temporary file
    rm "$TEMP_MD"
fi

echo "Book building complete!"
echo "Files are available in $OUTPUT_DIR"
