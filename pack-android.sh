. global.sh
SOURCE_APK_FILE=$1
RESOURCES=$2
CHANNEL_NAME=$3
OUTPUT=$4
VERSION_NAME=$5
VERSION_CODE=$6
TARGET_APK_FILE=${PRODUCT_NAME}_${CHANNEL_NAME}_${VERSION_NAME}_${VERSION_CODE}
SIGNED_APK_FILE=build/${TARGET_APK_FILE}.apk
UNSIGNED_APK_FILE=build/${TARGET_APK_FILE}_unsigned.apk
UNZIP_FOLDER=build/$TARGET_APK_FILE
if [ ! -d $OUTPUT ]; then
	mkdir -p $OUTPUT;
	if (($?)); then exit 1; fi
fi
##1. unzip apk
if [ -d $UNZIP_FOLDER ]; then
	rm -rf $UNZIP_FOLDER
fi
java -jar $ANDROID_TOOLS/apktool.jar d -o $UNZIP_FOLDER $SOURCE_APK_FILE
if (($?)); then exit 1; fi

##2. change version name and version code
echo "Change version name to $VERSION_NAME"
sed -i '.bak' "s/versionName: '[0-9.]*'/versionName: '${VERSION_NAME}'/" $UNZIP_FOLDER/apktool.yml
echo "Change version code to $VERSION_CODE"
sed -i '.bak' "s/versionCode: '[0-9]*'/versionCode: '${VERSION_CODE}'/" $UNZIP_FOLDER/apktool.yml
rm $UNZIP_FOLDER/apktool.yml.bak

##2. copy resources
echo "Copy common resources"
copyCommonResources $RESOURCES $UNZIP_FOLDER/assets
echo "Copy android resources"
copyAndroidResources $RESOURCES $UNZIP_FOLDER/assets

####
##onesdk workflow
echo "Pack onesdk"
onesdk $CHANNEL_NAME android $UNZIP_FOLDER ../unity-onesdk/app.conf ../unity-onesdk/onesdk.conf ../unity-onesdk/sdks
if (($?)); then exit 1; fi
####

##3. zip apk
java -jar $ANDROID_TOOLS/apktool.jar b -o $UNSIGNED_APK_FILE $UNZIP_FOLDER
if (($?)); then
	exit 1
else
	rm -rf $UNZIP_FOLDER
fi

##4. sign apk
jarsigner -verbose -digestalg SHA1 -sigalg MD5withRSA -keystore $KEYSTORE_FILE -storepass:file $PASSWORD_FILE -signedjar $SIGNED_APK_FILE $UNSIGNED_APK_FILE $ALIAS
if (($?)); then
	exit 1
else
	rm $UNSIGNED_APK_FILE
	mv $SIGNED_APK_FILE $OUTPUT
fi

##5. post process
./post-process.sh android $OUTPUT $SIGNED_APK_FILE
if (($?)); then exit 1; fi