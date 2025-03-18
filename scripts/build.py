#!/usr/bin/env python3
"""
Book Builder
A script to build books in various formats using Pandoc.
"""

import argparse
import os
import sys
import yaml
import subprocess
import glob
from pathlib import Path


def load_config(config_file):
    """Load the book configuration file."""
    with open(config_file, 'r') as f:
        try:
            return yaml.safe_load(f)
        except yaml.YAMLError as e:
            print(f"Error parsing config file: {e}")
            sys.exit(1)


def create_temp_combined_markdown(config, output_file):
    """Combine all markdown files into a single temporary file."""
    combined_content = ""
    for content_file in config['content']:
        try:
            with open(content_file, 'r') as f:
                file_content = f.read()
                combined_content += f"\n\n{file_content}\n\n"
        except FileNotFoundError:
            print(f"Warning: Content file '{content_file}' not found.")
    
    with open(output_file, 'w') as f:
        f.write(combined_content)
    
    return output_file


def build_pdf(config, input_file, output_dir):
    """Build PDF using Pandoc."""
    output_file = os.path.join(output_dir, f"{config['title'].replace(' ', '_')}.pdf")
    
    command = [
        "pandoc",
        input_file,
        "-o", output_file,
        "--pdf-engine=xelatex",
        f"--variable=papersize:{config['pdf_settings']['paper_size']}",
        f"--variable=fontsize:{config['pdf_settings']['font_size']}pt",
        f"--variable=mainfont:DejaVu Serif",
        f"--variable=sansfont:DejaVu Sans",
        f"--variable=monofont:DejaVu Sans Mono",
        "--variable=geometry:margin=1in",
    ]
    
    if config['pdf_settings'].get('toc', False):
        command.append("--toc")
        command.append(f"--toc-depth={config['pdf_settings'].get('toc_depth', 3)}")
    
    if config['pdf_settings'].get('numbering', True):
        command.append("--number-sections")
    
    print(f"Building PDF: {output_file}")
    subprocess.run(command, check=True)
    return output_file


def build_epub(config, input_file, output_dir):
    """Build EPUB using Pandoc."""
    output_file = os.path.join(output_dir, f"{config['title'].replace(' ', '_')}.epub")
    
    command = [
        "pandoc",
        input_file,
        "-o", output_file,
        f"--epub-metadata=<title>{config['title']}</title><creator>{config['author']}</creator>",
        "--toc",
    ]
    
    if 'cover_image' in config['epub_settings']:
        cover_path = config['epub_settings']['cover_image']
        if os.path.exists(cover_path):
            command.append(f"--epub-cover-image={cover_path}")
    
    if 'css' in config['epub_settings']:
        css_path = config['epub_settings']['css']
        if os.path.exists(css_path):
            command.append(f"--css={css_path}")
    
    print(f"Building EPUB: {output_file}")
    subprocess.run(command, check=True)
    return output_file


def build_html(config, input_file, output_dir):
    """Build HTML using Pandoc."""
    output_file = os.path.join(output_dir, f"{config['title'].replace(' ', '_')}.html")
    
    command = [
        "pandoc",
        input_file,
        "-o", output_file,
        "--standalone",
        "--self-contained" if config['html_settings'].get('self_contained', True) else "",
    ]
    
    if config['html_settings'].get('toc', True):
        command.append("--toc")
    
    if 'css' in config['html_settings']:
        css_path = config['html_settings']['css']
        if os.path.exists(css_path):
            command.append(f"--css={css_path}")
    
    print(f"Building HTML: {output_file}")
    subprocess.run(command, check=True)
    return output_file


def main():
    parser = argparse.ArgumentParser(description="Build books in various formats using Pandoc.")
    parser.add_argument("--config", "-c", default="config/book-config.yml", help="Path to the configuration file")
    parser.add_argument("--output-dir", "-o", default="build", help="Output directory for the generated files")
    args = parser.parse_args()
    
    # Ensure output directory exists
    os.makedirs(args.output_dir, exist_ok=True)
    
    # Load configuration
    config = load_config(args.config)
    print(f"Building book: {config['title']} by {config['author']}")
    
    # Create temporary combined markdown file
    temp_file = os.path.join(args.output_dir, "temp_combined.md")
    create_temp_combined_markdown(config, temp_file)
    
    # Build each requested output format
    for fmt in config['output_formats']:
        if fmt.lower() == 'pdf':
            build_pdf(config, temp_file, args.output_dir)
        elif fmt.lower() == 'epub':
            build_epub(config, temp_file, args.output_dir)
        elif fmt.lower() == 'html':
            build_html(config, temp_file, args.output_dir)
        else:
            print(f"Warning: Unknown output format '{fmt}'")
    
    # Clean up temporary file
    os.remove(temp_file)
    
    print(f"\nBook building complete. Files are available in {os.path.abspath(args.output_dir)}")


if __name__ == "__main__":
    main()
