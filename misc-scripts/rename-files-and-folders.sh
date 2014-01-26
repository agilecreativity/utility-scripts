#!/bin/bash
#----------------------------------#
# rename_files_and_folders.sh :beg:#
#----------------------------------#
# sample usage:
# ./rename_files_and_folders.sh ~/Pictures "*" - to change all file types
# ./rename_files_and_folders.sh ~/Pictures "*.jpg" - to change all specifi file type

EXPECTED_ARGS=2
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
    echo "Usage: `basename $0` directory \"*.pdf\" or"
    echo "Usage: `basename $0` directory \"*\""
    echo "Usage: `basename $0` directory \"*.*\""
    exit $E_BADARGS
fi

#-- Note: this have the side effect that we cleanup every directory  
#-- remove multiple spaces with one underscore for directories and files
find $1 -name "* *" -type d | rename "s/ /_/g"
find $1 -name "* *" -type f | rename "s/ /_/g"

#-- replace multiple dash with underscore as well
find $1 -name "$2" -type d | rename "s/\-{1,}/_/g"

#-- replace multiple underscore with just one
find $1 -name "$2" -type d | rename "s/\_{1,}/_/g"

#-- replace multiple dash with one underscore
find $1 -name "$2" -type f | rename "s/\-{1,}/_/g"
#-- replace multiple underscores with one underscore
find $1 -name "$2" -type f | rename "s/\_{1,}/_/g"

#----------------------------------#
# rename_files_and_folders.sh :end:#
#----------------------------------#
