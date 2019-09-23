#! /usr/bin/env bash
#
# change_dates_rename_files.sh
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
file_name="IMG_0061.jpg" # IMG_0059.jpg

# TODO: Add loop - to process entire given directory.
# while read filename; do
# date_for_date_change= 
# date_for_filename_change= 

# Change filesystem date to EXIF photo-taken date. 
identify -format '%[EXIF:DateTimeOriginal]' \
$directory_name/$file_name \
| sed -e 's/://g' -e 's/ //g' -E -e 's/(..)$/\.\1/' \
| tee $directory_name/date_manipulation/date_for_date_change.txt

# Save partial output of tee in variable, date_for_date_change.

# touch -t 201509020709.06 $test_dirname/$test_filename
# TODO: Replace with: touch -t 201509020709.03 $test_dirname\IMG_0059.jpg
# NEED: Variable with date string for date change.
# Shows OK in Finder. 
# **But in identify output: Properties: date:create: 2019-09-18T18:55:21+00:00

# Use EXIF photo-taken date, change format and use as part of filename. 
identify -format '%[EXIF:DateTimeOriginal]' \
$directory_name/$file_name \
| sed -e 's/.\{3\}$//' -e 's/:/-/g' -e 's/ /_/g' \
| tee $directory_name/date_manipulation/date_for_filename_change.txt

# TODO: Replace in filename IMG_ with $datestring_for_filename.
# NEED: Variable with date string for filename change.

# done

exit 0
