### Bash script that sorts image files into Year/Month subdirectories

Filename: `sort_image_files.sh`

This script:
- takes 3 command-line arguments or gives 3 prompts to sort photo files
- changes files that use download date as Creation Date, which is incorrect, to photo-taken date

The script also:
- creates subdirectories based on the Year & Month
- places files in subdirectories
- gives options to also create Day subdirectories or rename files with IMG in filename,
i.e., adds the photo-taken date, to the filename, e.g., 2015-09-02_07-09_0059.jpg 

**Note**: Photo-taken date is exif:DateTimeOriginal. If no exif:DateTimeOriginal, script uses date:modify.
