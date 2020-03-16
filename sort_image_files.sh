#! /usr/bin/env bash
#
# NAME: sort_image_files.sh
#
# BRIEF: Bash script that takes 3 command-line arguments or gives 3 prompts
# to sort photo files.
# Changes files that use download date as Creation Date, which is incorrect, to
# photo-taken date. The script also: 
# - creates subdirectories based on the Year & Month
# - places files in subdirectories
# - gives options to also create Day subdirectories or rename files with IMG in filename,
# i.e., adds the photo-taken date, to the filename, e.g., 2015-09-02_07-09_0059.jpg
#
# Note: Photo-taken date is exif:DateTimeOriginal. If no exif:DateTimeOriginal, 
# script uses date:modify.
#
# Author: Kim Lew

if [ $# -gt 3 ]; then 
  # Case of 4 or more parameters given.
  echo "Give 3 command-line arguments. Or give 0 arguments & get prompts."
  exit 1
fi

if [ $# -eq 0 ]; then # Show prompts.
  echo "Type the directory path for the files you want to sort: "
  read -r directory_path
  echo "Do you want Day sub-directories, along with the Year & Month ones? [y/n] "
  read -r day_subdir_also
  echo "Do you want to re-name the files with IMG, replacing IMG with the date? [y/n] "
  read -r rename_files_also
elif [ $# -lt 3 ]; then # Not enough command-line arguments given. Need 2 or 3.
  if [ $# -lt 2 ]; then # If given 1 command-line argument.
    echo "For parameter 2: Type y if you also want Day subdirectories."
  fi
  # If given 2 command-line arguments.
  echo "For parameter 3: Type y if you also want to re-name the files with IMG using the date."
  exit 1
else # Gave required 3 command-line arguments.
  directory_path="$1"
  day_subdir_also="$2"
  rename_files_also="$3"
fi

if [ ! -d "$directory_path" ]; then
    echo "This directory does NOT exist." 
    exit 1
fi

if ! magick identify --version > /dev/null; then
  echo "Error: You are missing the identify program that is part of the"
  echo "ImageMagick software suite. Install ImageMagick with your package manager."
  echo "Or see: https://imagemagick.org/index.php/"
  echo "Then re-run this script."
  exit 1
fi

echo "Path you gave:" "${directory_path}"
echo "Day subdirectories wanted?: " "${day_subdir_also}"
echo "Rename files?: " "${rename_files_also}"

case "${day_subdir_also}" in
  [yY] | [yY][eE][sS]) # To create year-month-day subdirectories.
    clean_day_subdir_also='y'
;;
  [nN] | [nN][oO] | '') # To create ONLY year-month subdirectories.
    clean_day_subdir_also='n'
;;
    *)
echo "Invalid input for 2nd parameter given or answer to 2nd prompt. Type y or n."
exit 1
;;
esac
case "${rename_files_also}" in
  [yY] | [yY][eE][sS]) # To create year-month-day subdirectories.
    clean_rename_files_also='y'
;;
  [nN] | [nN][oO] | '') # To create ONLY year-month subdirectories.
    clean_rename_files_also='n'
;;
    *)
echo "Invalid input for 3rd parameter given or answer to 3rd prompt. Type y or n."
exit 1
;;
esac
 
echo
echo "SORTING files..."

file_sort_counter=0

# Loop that processes entire given directory.
while read -r a_file_name; do
  echo "Looking at file:" "${a_file_name}"
  exif_date="$(identify -format '%[EXIF:DateTimeOriginal]' "$a_file_name" 2> /dev/null)" 
  modify_date="$(identify -format '%[DATE:modify]' "$a_file_name" 2> /dev/null)"
  echo -e " Exif Date is: \t\t" "${exif_date}"
  echo -e " Modify Date is: \t" "${modify_date}"
  
  if [[ "$exif_date" == '' ]] && [[ -z "${modify_date}" ]]; then
    # Give error if NO [EXIF:DateTimeOriginal] or [DATE:Modify].
    echo "Error: The file, $a_file_name"
    echo "- is missing the exif metadata, EXIF:DateTimeOriginal - so skipping this file"
    echo "Continuing with next file ..."
    continue
  elif [ "${exif_date}" ]; then
    # Change filesystem date to EXIF photo-taken date, EXIF:DateTimeOriginal.
    # Given Format:  2018:04:03 21:31:41
    # Wanted Syntax: [[CC]YY]MMDDhhmm[.SS] Wanted Format: 2015-09-02_07-09_0060.jpg
    # 1. Replace ALL occurrences of : 	With: nothing
    # 2. Replace 1st occurrence of space 	With: nothing
    # 3. Build string by deleting last 2 char at end. Then concat . & then concat 
    # last 2 char, e.g., abc12 -> abc + . + 12 => abc.12

    date_for_date_change="${exif_date//:/}"
    date_for_date_change="${date_for_date_change// /}"
    # Trim last 2 chars to remove SS so in format: [[CC]YY]MMDDhhmm[.SS]
    date_for_date_change="${date_for_date_change%??}.${date_for_date_change: -2}"

    # Prepare Filename Change that includes Date
    # Use EXIF photo-taken date, EXIF:DateTimeOriginal, change format & use in filename.
    # 1. Replace last 3 chars, e.g., :17	With: nothing
    # 2. Replace ALL : 	With: -
    # 3. Replace ALL spaces  With: _
    
    date_for_filename_change="${exif_date/${exif_date: -3}}"
    date_for_filename_change="${date_for_filename_change//:/-}"
    date_for_filename_change="${date_for_filename_change// /_}"
  
    # Build onto new_file_name. Concat to front - year & month.
    # Use: ${string:position:length}   On: 2015:09:02 07:09:03
    year="${exif_date:0:4}"
    month="${exif_date:5:2}"
  else # Use modify date when no exif date.
    # Change filesystem date to modify_date, date:modify for date change.
    # Given Format:  2018-10-09T18:42:41+00:00
    # Wanted Syntax: [[CC]YY]MMDDhhmm[.SS] Wanted Format: 202002031806
    # 1. Trim last 9 chars.
    # 2. Remove all -.
    # 3. Remove all T.
    # 4. Remove all :.
    date_for_date_change="${modify_date::-9}" # Result: 2020-02-08T16:02
    date_for_date_change="${date_for_date_change//-/}" # Result: 20200208T16:02
    date_for_date_change="${date_for_date_change//T/}" # Result: 2020020816:02
    date_for_date_change="${date_for_date_change//:/}" # Result: 202002081602
    
    # Prepare Filename Change that includes Date. Use modify_date, change format
    # & use in filename.
    # Given Format:  2018-10-09T18:42:41+00:00
    # Wanted Format: 2015-09-02_07-09_0060.jpg
    # 1. Replace last 3 chars, e.g., :17	With: nothing
    # 2. Replace ALL : 	With: -
    # 3. Replace ALL spaces  With: _
    date_for_filename_change="${modify_date::-9}" # Result: 2018-10-09T18:42
    date_for_filename_change="${date_for_filename_change//T/-}" # Result: 2018-10-09_18:42
    date_for_filename_change="${date_for_filename_change//:/_}" # Result: 2018-10-09_18_42
  
    # Build onto new_file_name. Concat to front - year & month.
    # Use: ${string:position:length}   On: 2018-10-09T18:42:41+00:00
    year="${modify_date:0:4}"
    month="${modify_date:5:2}"
  fi

  just_path=$(dirname "${a_file_name}")
  just_filename=$(basename "${a_file_name}") # For path to move files into subdirectories

  # 4 Cases for Options to Add Day & Rename Files:
  # Case 1: Add Day AND Rename files.
  # Case 2: Add Day. No Rename files.
  # Case 3: No add Day. Rename files.
  # Case 4: No add Day. No Rename files.

  day="${date_for_date_change:6:2}"
  path_with_year_month_day="${just_path}/${year}/${month}/${day}"
  path_with_year_month="${just_path}/${year}/${month}"

  if [[ "${clean_day_subdir_also}" == 'y' ]] && [[ "${clean_rename_files_also}" == 'y' ]]; then
    # Add Day subsubdirectories so Year-Month-Day AND Rename Files with IMG in them.
    path_for_subdirs_creation="${path_with_year_month_day}"
    renamed_file_and_path="${a_file_name/IMG/$date_for_filename_change}"
    just_filename=$(basename "${renamed_file_and_path}") # For path to move files into subdirectories
    new_dir_and_filename="${just_path}/${year}/${month}/${day}/${just_filename}"
  elif [ "${clean_day_subdir_also}" == 'y' ]; then # ONLY add Day subdirectories.
    path_for_subdirs_creation="${path_with_year_month_day}"
    new_dir_and_filename="${just_path}/${year}/${month}/${day}/${just_filename}"
  elif [ "${clean_rename_files_also}" == 'y' ]; then # ONLY rename files.
    # Replace IMG in filename with value in $datestring_for_filename, which is
    # in the format: YYYY-MM-DD_HH-MM, e.g., 2016-01-27_08-15.
    new_dir_and_filename="${a_file_name/IMG/$date_for_filename_change}"
    renamed_file_and_path="${a_file_name/IMG/$date_for_filename_change}"
    echo "renamed_file_and_path: " "${renamed_file_and_path}"
    path_for_subdirs_creation="${path_with_year_month}"
    
    # Get just filename from renamed_file_and_path.
    just_filename=$(basename "${renamed_file_and_path}") # For path to move files into subdirectories
    new_dir_and_filename="${just_path}/${year}/${month}/${just_filename}"
  else # ONLY make year-month subdirectories.
    path_for_subdirs_creation="${path_with_year_month}"
    new_dir_and_filename="${just_path}/${year}/${month}/${just_filename}"
  fi
  
  echo "Changing to: " "${new_dir_and_filename}"

  mkdir -p "${path_for_subdirs_creation}"
  touch -t "$date_for_date_change" "$a_file_name"
  mv "${a_file_name}" "${new_dir_and_filename}"
  file_sort_counter="$((file_sort_counter+1))"

done < <(find "${directory_path%/}" -maxdepth 1 -type f -name '*.jpg' -o -name '*.JPG' \
  -o -name '*.gif' -o -name '*.GIF' -o -name '*.tif' -o -name '*.TIF' \
  -o -name '*.png' -o -name '*.PNG')
  # Note: Redirects find back into while loop with process substitution so
  # ${file_sort_counter} is accessible vs. in a | subshell process.

echo "DONE. Number of files sorted is: " "${file_sort_counter}"

if [ "${file_sort_counter}" -eq 0 ]; then
  echo "There are no image files at the top-level of the path you typed."
fi
echo
exit 0
