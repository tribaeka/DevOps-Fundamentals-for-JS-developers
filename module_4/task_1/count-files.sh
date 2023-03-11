#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Please provide at least one directory path."
    exit 1
fi

for dir in "$@"
do
    if [ ! -d "$dir" ]; then
        echo "Error: $dir is not a directory."
        continue
    fi

    num_files=$(find "$dir" -type f | wc -l)
    echo "Directory $dir has $num_files files."
done
