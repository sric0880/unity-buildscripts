. global.sh
XCODE_PROJECT=$1
RESOURCES=$2
CHANNEL_NAME=$3
OUTPUT=$4
VERSION_NAME=$5
VERSION_CODE=$6
getPayloadFolderName $XCODE_PROJECT
IOS_FILENAME=${PRODUCT_NAME}_${CHANNEL_NAME}_${VERSION_NAME}_${VERSION_CODE}
WORKING_HOME_DIR=build/${IOS_FILENAME}_ios
WORKING_HOME=$WORKING_HOME_DIR/Payload
if [ ! -d $WORKING_HOME_DIR ]; then
	mkdir -p $WORKING_HOME_DIR
	if (($?)); then exit 1; fi
fi
if [ ! -d $OUTPUT ]; then
	mkdir -p $OUTPUT
	if (($?)); then exit 1; fi
fi
if [ ! -f $PROVISION_FILE ]; then
	logError "$PROVISION_FILE not exists!"
fi
if [ ! -f $ENTITLEMENTS_FILE ]; then
	log "generate entitlements.plist"
	/usr/libexec/PlistBuddy -x -c "print :Entitlements " /dev/stdin <<< $(security cms -D -i $PROVISION_FILE) > $ENTITLEMENTS_FILE
	if (($?)); then logError "could not generate $ENTITLEMENTS_FILE"; exit 1; fi
fi
cp -R build/$PayloadFolderName $WORKING_HOME_DIR
mv $WORKING_HOME_DIR/$PayloadFolderName $WORKING_HOME
rm -rf $WORKING_HOME/${PRODUCT_NAME}.app/_CodeSignature
cp $PROVISION_FILE $WORKING_HOME/${PRODUCT_NAME}.app/embedded.mobileprovision

echo "change bundle version name to $VERSION_NAME"
plutil -replace CFBundleVersion -string $VERSION_NAME $WORKING_HOME/${PRODUCT_NAME}.app/Info.plist
echo "change short bundle version code to $VERSION_CODE"
plutil -replace CFBundleShortVersionString -string $VERSION_CODE $WORKING_HOME/${PRODUCT_NAME}.app/Info.plist
# plutil -replace CFBundleDisplayName -string $APP_NAME $WORKING_HOME/${PRODUCT_NAME}.app/Info.plist
# plutil -replace CFBundleIdentifier -string $BUNDLE_ID $WORKING_HOME/${PRODUCT_NAME}.app/Info.plist

## Copy resources
resources_root=$WORKING_HOME/${PRODUCT_NAME}.app/Data/Raw
echo "Copy common resources"
copyCommonResources $RESOURCES $resources_root
echo "Copy ios resources"
copyIOSResources $RESOURCES $resources_root
./resources-postprocess.sh ios $resources_root

echo "start codesign"
/usr/bin/codesign -f -s $IDENTITY --entitlements $ENTITLEMENTS_FILE $WORKING_HOME/${PRODUCT_NAME}.app
if (($?)); then logError "codesign error"; exit 1; fi
/usr/bin/codesign -vv -d $WORKING_HOME/${PRODUCT_NAME}.app
if (($?)); then logError "codesign error"; exit 1; fi
/usr/bin/codesign --verify $WORKING_HOME/${PRODUCT_NAME}.app
if (($?)); then logError "codesign error"; exit 1; fi

echo "move dSYM to ${OUTPUT}"
mv $WORKING_HOME/${PRODUCT_NAME}.app.dSYM $WORKING_HOME/${IOS_FILENAME}.app.dSYM
if [ -d $OUTPUT/${IOS_FILENAME}.app.dSYM ]; then
	rm -rf $OUTPUT/${IOS_FILENAME}.app.dSYM
fi
mv $WORKING_HOME/${IOS_FILENAME}.app.dSYM $OUTPUT
echo "start zip"
current_pwd=`pwd`
cd $WORKING_HOME_DIR
zip -r ${IOS_FILENAME}.ipa Payload -q
cd $current_pwd
mv $WORKING_HOME_DIR/${IOS_FILENAME}.ipa $OUTPUT
rm -rf $WORKING_HOME
rm -r $WORKING_HOME_DIR

##post process
./post-process.sh ios $OUTPUT ${IOS_FILENAME}.ipa
if (($?)); then exit 1; fi
./post-process.sh ios $OUTPUT ${IOS_FILENAME}.app.dSYM
if (($?)); then exit 1; fi