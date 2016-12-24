. global.sh
MAIN_EXE=$1
RESOURCES=$2
CHANNEL_NAME=$3
OUTPUT=$4
VERSION_NAME=$5
VERSION_CODE=$6
FILENAME=${PRODUCT_NAME}_${CHANNEL_NAME}_${VERSION_NAME}_${VERSION_CODE}
WORKING_HOME_DIR=build/${FILENAME}_windows
if [ ! -d $WORKING_HOME_DIR ]; then
	mkdir -p $WORKING_HOME_DIR
	if (($?)); then exit 1; fi
fi
if [ ! -d $OUTPUT ]; then
	mkdir -p $OUTPUT
	if (($?)); then exit 1; fi
fi

cp $MAIN_EXE $WORKING_HOME_DIR
Data_Folder=`sed -e "s/\(.*\)\(\.exe\)/\1_Data/" <<< ${MAIN_EXE}`
cp -R $Data_Folder $WORKING_HOME_DIR
Data_Folder=`sed -e "s/\(.*\)\/\(\.*\)/\2/" <<< ${Data_Folder}`
Data_Folder=${WORKING_HOME_DIR}/$Data_Folder

## Copy resources
echo "Copy common resources"
copyCommonResources $RESOURCES $Data_Folder/StreamingAssets
echo "Copy Windows resources"
copyWindowsResources $RESOURCES $Data_Folder/StreamingAssets

if [ -d $OUTPUT/${FILENAME}_windows ]; then rm -rf $OUTPUT/${FILENAME}_windows; fi
mv $WORKING_HOME_DIR $OUTPUT
rm -rf $WORKING_HOME_DIR

##post process
./post-process.sh windows $OUTPUT $FILENAME
if (($?)); then exit 1; fi
