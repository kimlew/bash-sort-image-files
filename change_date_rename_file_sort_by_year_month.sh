#! /usr/bin/env bash
#
# Name: change_dates_rename_files.sh
#
# Brief: Command-line Bash script to change Creation Date & Modified Date, that  
# are currently download date, to photo-taken date. The script also:
# - adds the photo-taken date to the filename, e.g., 2015-09-02_07-09_0059.jpg 
# - creates directories and subdirectories based on the year and month
# - places files in associated subdirectories.
#
# These changes make file sorting easier. 
# The script takes in 1 command-line parameter, directory_path, the location of 
# the files.
#
# Note: Photo-taken date is exif:DateTimeOriginal.
# Note: Script processes only a single directory. 
#
# Author: Kim Lew

if [ $# -eq 0 ]; then
  echo "Type the directory path for the files that need changed dates & filenames: "
  read -r directory_path
elif [ $# -eq 1 ]; then
  directory_path="$1"
elif [ $# -gt 1 ]; then 
  # Case of > 1 parameter given.
  echo "Enter the directory path as the 1st command-line argument. Or give 0 arguments & get prompt."
  exit 1
fi

if [ ! -d "$directory_path" ] 
then
    echo "This directory does NOT exist." 
    exit 1
fi
echo "Path you gave: $directory_path"

if ! magick identify --version > /dev/null; then
  echo "Error: You are missing the identify program that is part of the"
  echo "ImageMagick software suite. Install ImageMagick with your package manager."
  echo "Or see: https://imagemagick.org/index.php/"
  echo "Then re-run this script."
  exit 1
fi

echo "Date changes, filename changes & sorting in progress..."

file_sort_counter=0

# Loop that processes entire given directory.
while read -r a_file_name; do
  exif_date="$(identify -format '%[EXIF:DateTimeOriginal]' "$a_file_name")"
  
  if [ "$exif_date" == '' ] > /dev/null; then
    echo "Error: The file, $a_file_name"
    echo "- is missing the exif metadata, EXIF:DateTimeOriginal - so skipping this file"
    echo "Continuing with next file ..."
    echo
    continue
  fi
  ### Filesystem/OS Date Change ###
  # Change filesystem date to EXIF photo-taken date, EXIF:DateTimeOriginal.
  # 1. Replace ALL occurrences of : 	With: nothing
  # 2. Replace 1st occurrence of space 	With: nothing
  # 3. Build string by deleting last 2 char at end. Then concat . & then concat 
  # last 2 char, e.g., abc12 -> abc + . + 12 => abc.12

  date_for_date_change="${exif_date//:/}"
  date_for_date_change="${date_for_date_change// /}"  

  # Use format: ${parameter%word} for the portion with the string to keep.
  # % - means to delete only the following stated chars & keep the rest, i.e., 
  # %${date_for_date_change: -2} - which is the 12 part of abc12 & keep abc
  date_for_date_change="${date_for_date_change%??}.${date_for_date_change: -2}"

  touch -t "$date_for_date_change" "$a_file_name"

  ### Filename Change that includes Date ###
  # Use EXIF photo-taken date, EXIF:DateTimeOriginal, change format & use in filename.
  # 1. Replace last 3 chars, e.g., :17	With: nothing
  # 2. Replace ALL : 	With: -
  # 3. Replace ALL spaces  With: _
  
  date_for_filename_change="${exif_date/${exif_date: -3}}"
  date_for_filename_change="${date_for_filename_change//:/-}"
  date_for_filename_change="${date_for_filename_change// /_}"

  # Replace IMG in filename with value in $datestring_for_filename, which is
  # in the format: YYYY-MM-DD_HH-MM, e.g., 2016-01-27_08-15.
  new_file_name="${a_file_name/IMG/$date_for_filename_change}"
 
  # Build onto new_file_name. Concat to front - year & month.
  # Test with: /Users/kimlew/Sites/bash_projects/test_mkdir-p
  # Use: ${string:position:length}   On: 2015:09:02 07:09:03
  year="${exif_date:0:4}"
  month="${exif_date:5:2}"

  just_path=$(dirname "${new_file_name}")
  path_with_subdir_year_month="${just_path}/${year}/${month}"

  mkdir -p "${path_with_subdir_year_month}"

  just_filename=$(basename "${new_file_name}")
  new_dir_and_filename="${just_path}/${year}/${month}/${just_filename}"

  mv "$a_file_name" "$new_dir_and_filename"
  file_sort_counter="$((file_sort_counter+1))"
done < <(find "${directory_path%/}" -maxdepth 1 -type f -name '*.jpg' -o -name '*.JPG' \
    -o -name '*.gif' -o -name '*.GIF' -o -name '*.tif' -o -name '*.TIF' \
    -o -name '*.png' -o -name '*.PNG')
   # Note: Redirects find back into while loop with process substitution so
   # ${file_sort_counter} is accessible vs. in a | subshell process.

echo "Done. Number of files sorted is: " "${file_sort_counter}"

if [ "${file_sort_counter}" -eq 0 ]; then
  echo "There are no image files at the top-level of the path you typed."
fi

exit 0
