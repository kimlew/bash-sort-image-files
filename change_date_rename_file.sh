#! /usr/bin/env bash
#
# change_dates_rename_files.sh
#
# Command-line Bash script to change Creation Date & Modified Date that are 
# currently download date to photo-taken date. The script also adds
# photo-taken date to the filename. These changes will make file sorting  
# easier. Takes in 1 command-line parameter, directory_path, the location of 
# the files.
#
# Note: Photo-taken date is exif:DateTimeOriginal.
# Note: Script processes only a single directory. 
#
# Kim Lew

echo "Type the directory path for the files that need changed dates & filenames: "
read directory_path
echo "You typed: " $directory_path

#original_path=/Users/kimlew/Documents/PHOTOS/2019/iPhone_photos_2019-Jan-01-Jul-30
#directory_name="/Users/kimlew/Sites/bash_projects/test_run"
#file_name="IMG_0059.jpg" # IMG_0061.jpg

# Loop that processes entire given directory.
find $directory_path -type f |
while read a_file_name; do
  ### Filesystem/OS Date Change ###
  # Change filesystem date to EXIF photo-taken date, EXIF:DateTimeOriginal.
  # Save command chain output in variable, date_for_date_change.
  date_for_date_change=$(identify -format '%[EXIF:DateTimeOriginal]' \
  $a_file_name \
  | sed -e 's/://g' -e 's/ //g' -E -e 's/(..)$/\.\1/' \
  | tee $directory_path/date_manipulation/date_for_date_change.txt)
  # TODO: Remove tee command when done project. Only for Kim's confirmation.

  # Test with: echo touch -t $date_for_date_change $directory_path/$file_name
  touch -t $date_for_date_change $a_file_name

  ### Filename Change that includes Date ###
  # Use EXIF photo-taken date, EXIF:DateTimeOriginal, change format & use in filename.
  # Save command chain output in variable, date_for_filename_change.
  date_for_filename_change=$(identify -format '%[EXIF:DateTimeOriginal]' \
  $a_file_name \
  | sed -e 's/.\{3\}$//' -e 's/:/-/g' -e 's/ /_/g' \
  | tee $directory_path/date_manipulation/date_for_filename_change.txt)
  # TODO: Remove tee command when done project. Only for Kim's confirmation.

  # Replace IMG_ in filename with value in $datestring_for_filename, which is
  # in the format: YYYY-MM-DD_HH-MM, e.g., 2016-01-27_08-15.
  #echo "date_for_filename_change is: " $date_for_filename_change
  #echo sed "s/IMG/$date_for_filename_change/" "$a_file_name"
  new_file_name=$(echo "$a_file_name" | sed "s/IMG/$date_for_filename_change/")
  mv $a_file_name $new_file_name 

#echo 'Given file_name is: ' $file_name 
#echo 'new_file_name is: ' $new_file_name
done
echo "Done."

exit 0
