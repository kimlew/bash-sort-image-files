### Bash script to change dates, rename files & place files in created subdirectories

This Bash script, which makes file sorting easier:
- changes download date to photo-taken date (using file metadata's `exif:DateTimeOriginal`)
- adds photo-taken date to filename
- creates directories and subdirectories based on the year and month 
- places files in associated subdirectories

The script takes in 1 command-line parameter, `directory_path`, or prompts the user for one, which is the location of the files that need Creation Date change to the photo-taken date.

**Note**: Script processes only a single directory.
