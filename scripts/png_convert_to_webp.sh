#!/bin/bash

set -e

IMAGES_DIRECTORY="website/assets/img/posts"
POSTS_DIRECTORY="website/_posts"

print_wide_string() {
  local string="$1"
  local terminal_width=$(tput cols)
  local string_length=${#string}
  local remaining_width=$((terminal_width - string_length))

  # Print the string followed by '#' characters to fill the remaining width
  printf "%s" "$string "
  for ((i = 1; i < remaining_width; i++)); do
    printf "#"
  done
  printf "\n"
}

# Find all PNG files
png_files=$(find $IMAGES_DIRECTORY -type f -name '*.png')

# Iterate over each PNG file
for file in $png_files; do
    print_wide_string "Processing file: $file"

    # Extract file and parent folder name
    parent_folder=$(basename "$(dirname "$file")")
    png_file_path=$file
    png_file_name=$(basename "$file")
    webp_file_path="${png_file_path%.png}.webp"
    webp_file_name="${png_file_name%.png}.webp"

    # Convert PNG to WebP
    printf "%s" "- converting file to webp..."
    cwebp -q 100 "$png_file_path" -o "$webp_file_path" 2> /dev/null
    printf "%s\n" " [ok]"

    printf "%s" "- updating references in markdown file..."
    sed -i "s/$png_file_name/$webp_file_name/g" "$POSTS_DIRECTORY/$parent_folder.md"
    printf "%s\n" " [ok]"

    printf "%s" "- removing original file..."
    rm "$png_file_path"
    printf "%s\n" " [ok]"

    echo ""
done