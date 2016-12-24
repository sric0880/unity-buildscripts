. global.sh
MAIN_APP=$1
RESOURCES=$2
CHANNEL_NAME=$3
OUTPUT=$4
VERSION_NAME=$5
VERSION_CODE=$6
FILENAME=${PRODUCT_NAME}_${CHANNEL_NAME}_${VERSION_NAME}_${VERSION_CODE}
WORKING_HOME_DIR=build/${FILENAME}_mac
if [ ! -d $WORKING_HOME_DIR ]; then
	mkdir -p $WORKING_HOME_DIR
	if (($?)); then exit 1; fi
fi
if [ ! -d $OUTPUT ]; then
	mkdir -p $OUTPUT
	if (($?)); then exit 1; fi
fi

cp -R $MAIN_APP $WORKING_HOME_DIR
MAIN_APP=`sed -e "s/\(.*\)\/\(\.*\)/\2/" <<< ${MAIN_APP}`
MAIN_APP=${WORKING_HOME_DIR}/$MAIN_APP

## Copy resources
resources_root=$MAIN_APP/Contents/Resources/Data/StreamingAssets
echo "Copy common resources"
copyCommonResources $RESOURCES $resources_root
echo "Copy Mac resources"
copyMacResources $RESOURCES $resources_root
./resources-postprocess.sh mac $resources_root

if [ -d $OUTPUT/${FILENAME}_mac ]; then rm -rf $OUTPUT/${FILENAME}_mac; fi
mv $WORKING_HOME_DIR $OUTPUT
rm -rf $WORKING_HOME_DIR

##post process
./post-process.sh mac $OUTPUT $FILENAME
if (($?)); then exit 1; fi
