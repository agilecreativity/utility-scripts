#/bin/bash
#-------------------------------------#
#-- script:rename-extension.sh:beg: --#
#-------------------------------------#

#-- see: http://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash
#-- and  http://www.cyberciti.biz/tips/handling-filenames-with-spaces-in-bash.html
#-- clean version using find command

EXPECTED_ARGS=2
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
   echo "Usage: `basename $0` old_extension new_extension"
   echo "e.g. : `basename $0` htm html"
   exit $E_BADARGS
fi

old_ext=$1
new_ext=$2

find . -name "*.$old_ext" -type f -print0 | while read -d $'\0' original_filename 
do
  f_ext=${original_filename##*.}
  f_name=${original_filename%.*}

  #-- for debugging uncomment the next two lines
  #echo "File name : $f_name"
  #echo "Extension : $f_ext"

  #-- rename the file to new extension
  echo "rename $original_filename to $f_name.$2"
  mv "$original_filename" "$f_name.$2"

done

#-------------------------------------#
#-- script:rename-extension.sh:end: --#
#-------------------------------------#
