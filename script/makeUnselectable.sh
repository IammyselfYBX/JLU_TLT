#!/bin/sh

# Check if input file is provided
if [ $# -eq 0 ]; then
    echo "Error: No input file provided."
    echo "Usage: $0 <pdf_file>"
    exit 1
fi

# Check if input file exists
if [ ! -f "$1" ]; then
    echo "Error: PDF file '$1' not found."
    exit 1
fi

# Check if input is a PDF file
if [ "${1##*.}" != "pdf" ]; then
    echo "Error: Input file must be a PDF file."
    exit 1
fi

GS=gs

# Check if ghostscript is available
if ! command -v $GS > /dev/null 2>&1; then
    echo "Error: Ghostscript (gs) not found. Please install Ghostscript."
    exit 1
fi

echo "Processing PDF file: $1"
$GS -sDEVICE=ps2write -dNOCACHE -sOutputFile="${1%%.*}-rst.ps" -q -dBATCH -dNOPAUSE "$1" -c quit 

if [ $? -eq 0 ]; then
    echo "Step 1/2: PS file created successfully"
    ps2pdf "${1%%.*}-rst.ps" "${1%%.*}-rst.pdf"
    if [ $? -eq 0 ]; then
        echo "Step 2/2: PDF conversion completed"
        echo "Output written to ${1%%.*}-rst.pdf"
        # Clean up temporary PS file
        rm -f "${1%%.*}-rst.ps"
        echo "Temporary PS file cleaned up"
    else
        echo "Error: Failed to convert PS to PDF"
        exit 1
    fi
else
    echo "Error: Failed to convert PDF to PS using Ghostscript"
    exit 1
fi

