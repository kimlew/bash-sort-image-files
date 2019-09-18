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

test_path=/Users/kimlew/Documents/PHOTOS/2019/iPhone_photos_2019-Jan-01-Jul-30

echo "Type the directory path for the files that need changed dates & filenames: "
read dirname
echo "You typed: " $dirname

# while read filename; do
# datestring_for_filename = 
# datestring_for_date = 

identify -format '%[EXIF:DateTimeOriginal]' \
$test_path/IMG_0059.jpg \
| sed -e 's/.\{3\}$//' -e 's/:/-/g' -e 's/ /_/g' \
| tee $test_path/date_manipulation/DateTimeOriginalForFilename.txt

identify -format '%[EXIF:DateTimeOriginal]' \
$test_path/IMG_0059.jpg \
| sed -e 's/://g' -e 's/ //g' -E -e 's/(..)$/\.\1/' \
| tee $test_path/date_manipulation/DateTimeOriginalForDate.txt

# TODO
# touch -t 201509020709 IMG_0059.jpg
# touch -t 20150902070903 IMG_0059.jpg

# done

exit 0
