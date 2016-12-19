## support platform config 
declare -A PLATFORM_PREFIX
PLATFORM_PREFIX=( ["ios"]=1 ["android"]=2 ['windows']=4 )
declare -A PLATFORM_BUILD_METHOD
PLATFORM_BUILD_METHOD=( ["ios"]="BuildiOSPlayer" ["android"]="BuildAndroidPlayer" ["windows"]="BuildWindowsPlayer")
declare -A PLATFORM_BUILD_FILENAME
PLATFORM_BUILD_FILENAME=( ["ios"]="xcode_project" ["android"]="client.apk" ["windows"]="gamePc/main.exe" )

## platform tools dir root
SCRIPT_ROOT=`pwd`
export ANDROID_TOOLS=$SCRIPT_ROOT/tools/android
export IOS_TOOLS=$SCRIPT_ROOT/tools/ios
export PRODUCT_NAME='yourname'

## xcode build config
export TEAM_ID='35C78CR8GV'
export DEBUG_INFORMATION_FORMAT='dwarf-with-dsym'
##########################################################

## ios sign config
## security find-identity -v -p codesigning
export IDENTITY="16FF5B1AD030C06BFC04703A0D95C1A9626DA2D0"
export PROVISION_FILE=$IOS_TOOLS/embedded.mobileprovision
export ENTITLEMENTS_FILE=$IOS_TOOLS/entitlements.plist

## android sign config
export KEYSTORE_FILE=$ANDROID_TOOLS/keystore
export PASSWORD_FILE=$ANDROID_TOOLS/pwd
export ALIAS='ninjarun2'

## resources folders
export COMMON_FOLDERS=( "config" "lua" "bootconfig" )
export ANDROID_FOLDERS=( "Android" )
export IOS_FOLDERS=( "iOS" )