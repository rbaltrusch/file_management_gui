This GUI combines three common file management tasks:

   1) Copy all selected files from a specified directory* to a new, specified directory
   2) Move all selected files from a specified directory* to a new, specified directory
   3) Delete all selected files from a specified directory* to the Recycle bin.

       * including subdirectories

The files to be used in those tasks can be selected by specifying two
filters: one for the file extension, one for the file name (labelled filter).
Standard Windows wildcard characters (* and ?) may be used. Note that the
file name filter does not work if no file extension is specified and it
defaults to .*

The directories specified (both source and destination) can be specified
either by specifying the path in the text boxes provided (From = source,
To = destination) or by selecting the relevant path using the select path
button.

The filter button searches in the folder specified and all of its
subdirectories for the files that match the specified file name filter and
file extension filter. The matched files then get displayed in the table
in the middle of the GUI. Using the filter button is not required, but
desireable to test whether the filters specified match the expected files.


The GUI also provides file renaming functionality upon moving, copying or
deleting the file to the new folder. This can be done in three ways:

   1) Add a prefix to all selected files (e.g. if prefix = hello, then a
   selected file called world.txt would be renamed helloworld.txt once
   copied/moved to the new folder.

   2) Add a suffix to all selected files (e.g. if suffix = world, then a
   selected file called hello.txt would be renamed helloworld.txt once
   copied/moved to the new folder.

   3) Find and replace a substring using regexp expressions. For example,
   if the find expression is "^h" and the replace expression is "y", all
   files starting with "h" would have that "h" changed to "y", e.g.
   help.txt --> yelp.txt


The rename duplicate files checkbox enables or disables the duplicate file
renaming functionality. If enabled, files that are moved to the new
folder that have the same name as a file that already exist in that folder
would be renamed by adding a number suffix, e.g. help.txt --> help1.txt.
If the checkbox is unchecked, then files with the same name are
overwritten, which may be undesirable if the files with the same name
contain different data.


TODO: implement error handling in the update loop
TODO: add checkbox that enables/disables recursive search of source folder

Author: Richard Baltrusch
Date: 06/11/2020
