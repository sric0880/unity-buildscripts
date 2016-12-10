. global.sh
SOURCE_APK_FILE=$1
RESOURCES=$2
CHANNEL_NAME=$3
OUTPUT=$4/android
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
java -jar $ANDROID_TOOLS/apktool.jar d -o $UNZIP_FOLDER $SOURCE_APK_FILE
if (($?)); then exit 1; fi

##2. copy resources
copyCommonResources $RESOURCES $UNZIP_FOLDER/assets
copyAndroidResources $RESOURCES $UNZIP_FOLDER/assets

####
##custom pack 
python onesdk.py $UNZIP_FOLDER $CHANNEL_NAME $

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
