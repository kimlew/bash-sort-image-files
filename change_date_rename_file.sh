#! /usr/bin/env bash
#
# Name: change_dates_rename_files.sh
#
# Brief: Command-line Bash script to change Creation Date & Modified Date that  
# are currently download date to photo-taken date. The script also adds
# photo-taken date to the filename, e.g., 2015-09-02_07-09_0059.jpg.
# These changes will make file sorting easier. Takes in 1 command-line 
# parameter, directory_path, the location of the files.
#
# Note: Photo-taken date is exif:DateTimeOriginal.
# Note: Script processes only a single directory. 
#
# Author: Kim Lew

echo "Type the directory path for the files that need changed dates & filenames: "
read directory_path
echo "You typed: " $directory_path

if [ ! -d $directory_path ] 
then
    echo "This directory does NOT exist." 
    exit 9999 # die with error code 9999
fi

if ! which identify > /dev/null; then
  echo "Error: You are missing the identify program that is part of the"
  echo "ImageMagick software suite. Install ImageMagick with your package manager."
  echo "Or see: https://imagemagick.org/index.php/"
  echo "Then re-run this script."
  exit 9999 # die with error code 9999
fi

echo "Date changes and filename changes in progress..."
echo "..."

# Loop that processes entire given directory.
find $directory_path -type f |
while read a_file_name; do
  exif_date=$(identify -format '%[EXIF:DateTimeOriginal]' $a_file_name)

  ### Filesystem/OS Date Change ###
  # Change filesystem date to EXIF photo-taken date, EXIF:DateTimeOriginal.
  # 1. Replace ALL occurrences of : 	With: nothing
  # 2. Replace 1st occurrence of space 	With: nothing
  # 3. Replace last 2 char at end	  With: A literal . plus last 2 char at end.
  
  date_for_date_change="${exif_date//:/}"
  date_for_date_change="${date_for_date_change/ /}"
  date_for_date_change="${date_for_date_change/${date_for_date_change: -2}/\.${date_for_date_change: -2}}"

  touch -t $date_for_date_change $a_file_name

  ### Filename Change that includes Date ###
  # Use EXIF photo-taken date, EXIF:DateTimeOriginal, change format & use in filename.
  # 1. Replace last 3 chars, e.g., :17	With: nothing
  # 2. Replace ALL : 	With: -
  # 3. Replace ALL spaces  With: _
  # | sed -e 's/.\{3\}$//' -e 's/:/-/g' -e 's/ /_/g')
    
  date_for_filename_change="${exif_date/${exif_date: -3}}"
  date_for_filename_change="${date_for_filename_change//:/-}"
  date_for_filename_change="${date_for_filename_change/ /_}"

  # Replace IMG in filename with value in $datestring_for_filename, which is
  # in the format: YYYY-MM-DD_HH-MM, e.g., 2016-01-27_08-15.
  new_file_name="${a_file_name/IMG/$date_for_filename_change}"
  mv $a_file_name $new_file_name
done
echo "Done."

exit 0
