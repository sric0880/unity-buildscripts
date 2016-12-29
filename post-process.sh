. global.sh
. svn.sh
PLATFORM=$1
OUTPUT=$2
FILE=$3

current_path=`pwd`
cd $OUTPUT

####################################
## Custom settings

## svn commit
# svnCommitFile $FILE "Auto build"
# if (($?)); then exit 1; fi

## or rsync to another server for downloading
# rsync -avzr --progress --exclude ".DS_Store" $OUTPUT/ 127.0.0.1:/$prefix/$OUTPUT

## End custom settings
###################################

cd $current_path

