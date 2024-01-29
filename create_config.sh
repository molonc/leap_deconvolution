#!/bin/bash

# Get the current directory path
current_dir=$(pwd)

# Name of the file to find
file_name="snakemake_metadata.csv"

# Find the file in the current directory
file_path=$(find "$current_dir" -name "$file_name" -print -quit)

# Check if the file was found
if [[ -z $file_path ]]; then
    echo "Error: '$file_name' not found in the current directory."
    exit 1
fi

# Write the content to config.yaml
cat > config.yaml << EOF
---
md: "$file_path"
LEAP_ID_MAP: "/projects/molonc/scratch/sbeatty/SCY-288/reference__data/sample_table.tsv"
SLX_table: "/projects/molonc/scratch/sbeatty/SCY-288/reference__data/SLX_table.csv"
EOF

echo "config.yaml has been created."
