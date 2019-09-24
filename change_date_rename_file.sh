#! /usr/bin/env bash
#
# change_dates_rename_files.sh - You MUST have sudo permissions & run
# this script with sudo.
#
# Command-line bash script to change download date to photo-taken date & 
# add photo-taken date to filename. Takes in 1 command-line parameter, 
# directory_path, the location where the files than need change of Creation Date  
# & Modified Date to the photo-taken date.
#
# directory_path is then referred to as $1 - which refers to the 1st argument
# passed from the command line.
#
# Note: Photo-taken date is exif:DateTimeOriginal.
# Note: Script processes only a single directory. 
#
# Kim Lew

echo "Type the directory path for the files that need changed dates & filenames: "
read directory_path
echo "You typed: " $directory_path

#original_path=/Users/kimlew/Documents/PHOTOS/2019/iPhone_photos_2019-Jan-01-Jul-30
directory_name="/Users/kimlew/Sites/bash_projects/test_run"
file_name="IMG_0059.jpg" # IMG_0061.jpg

# TODO: Add loop - to process entire given directory.
# while read filename; do

# Change filesystem date to EXIF photo-taken date.
# Save command chain output in variable, date_for_date_change.
date_for_date_change=$(identify -format '%[EXIF:DateTimeOriginal]' \
$directory_name/$file_name \
| sed -e 's/://g' -e 's/ //g' -E -e 's/(..)$/\.\1/' \
| tee $directory_name/date_manipulation/date_for_date_change.txt)
# TODO: Remove tee command when done project. Only for Kim's confirmation.

touch -t $date_for_date_change $directory_name/$file_name

# Use EXIF photo-taken date, change format and use as part of filename.
# Save  command chain output in variable, date_for_filename_change.
date_for_filename_change=$(identify -format '%[EXIF:DateTimeOriginal]' \
$directory_name/$file_name \
| sed -e 's/.\{3\}$//' -e 's/:/-/g' -e 's/ /_/g' \
| tee $directory_name/date_manipulation/date_for_filename_change.txt)
# TODO: Remove tee command when done project. Only for Kim's confirmation.

# TODO: Replace in filename IMG_ with $datestring_for_filename.

# done

exit 0
