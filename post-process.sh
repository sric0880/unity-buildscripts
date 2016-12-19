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

## End custom settings
###################################

cd $current_path

