## checkout the bash version
function checkBashVersion()
{
	if [[ $BASH_VERSION =~ ^4.*$ ]]; then
		echo "Bash version $BASH_VERSION is OK"
	else
		echo "Bash version $BASH_VERSION is too old"
		echo "Update bash..."
		. install-bash.sh
		exit 0
	fi
}
# Black       0;30     Dark Gray     1;30
# Blue        0;34     Light Blue    1;34
# Green       0;32     Light Green   1;32
# Cyan        0;36     Light Cyan    1;36
# Red         0;31     Light Red     1;31
# Purple      0;35     Light Purple  1;35
# Brown       0;33     Yellow        1;33
# Light Gray  0;37     White         1;37
# background colors, the num is 40 to 47
function logError()
{
	echo "--------------------------------------------------"
	echo -e "\e[1;31mError:\e[0m $1"
	echo "--------------------------------------------------"
}
function logWarning()
{
	echo "--------------------------------------------------"
	echo -e "\e[1;33mWarning:\e[0m $1"
	echo "--------------------------------------------------"
}
function log()
{
	echo "--------------------------------------------------"
	echo -e "\e[1;32mLog:\e[0m $1"
	echo "--------------------------------------------------"
}
function parseChannels()
{
	channels=("${!1}")
	for channel in ${channels[@]}; do
		if [[ $channel =~ ^(..*)-(..*)$ ]]; then
			p=${BASH_REMATCH[1]}
			flag=${PLATFORM_PREFIX[$p]}
			if [ -z $flag ]; then
				logError "Unsupport platform '$p'"
				exit 1
			fi
			PLATFORM=$(($PLATFORM|$flag))
		else
			logError "channel '${channel}' doesn't format {platform}-{channelName}, see usage:"
			usage
		fi
	done
}
## return 0 if not has then return above 0
function hasPlatform()
{
	[[ $(($PLATFORM&${PLATFORM_PREFIX[$1]})) -gt 0 ]] && return 0 || return 1
}
function commandInstalled()
{
	if ! type $1 &> /dev/null; then
		logError "command $1 not installed, install and set PATH."
		exit 1
	fi
}
function gnugetopt()
{
	commandInstalled getopt
	o=`getopt -T`
	if (( $? != 4 )) && [[ -n $o ]]; then
		logError "not GNU getopt, BSD getopt cannot parse long options"
		echo "please do: brew install gnu-getopt, then set getopt to PATH"
		exit 1
	fi
}
function printUnityLogError()
{
	if [ -f $1 ]; then
		grep 'error' $1
	fi
}
## build xcode project to Payload/
function getPayloadFolderName()
{
	PayloadFolderName=`sed -e "s/\([a-zA-Z\/_-]*\)\(\.*[0-9a-zA-Z]*\)/Payload\2/" <<< ${1}`
	# log "Payload folder name is ${PayloadFolderName}"
}
function xcodeBuild()
{
	current_path=`pwd`
	if [ ! -d $1 ]; then logError "$1 folder not exists"; exit 1; fi
	getPayloadFolderName $1
	cd $1

	sdk_root=`/usr/bin/xcodebuild -sdk -version | grep "^Path.*iPhoneOS.platform" | grep -o "/.*"`
	/usr/bin/xcodebuild -target Unity-iPhone -configuration Release clean build CONFIGURATION_BUILD_DIR=../$PayloadFolderName CODE_SIGN_RESOURCE_RULES_PATH="$sdk_root/ResourceRules.plist" PRODUCT_NAME=$PRODUCT_NAME DEPLOYMENT_POSTPROCESSING=YES DEBUG_INFORMATION_FORMAT=$DEBUG_INFORMATION_FORMAT DEVELOPMENT_TEAM="$TEAM_ID"
	if (($?)); then exit 1; fi
	cd $current_path
}
function copyCommonResources()
{
	if [ ! -d $2 ]; then
		mkdir $2
	fi
	COMMON_FOLDERS=( "config" "lua" "bootconfig" $APP_METADATA )
	for f in ${COMMON_FOLDERS[@]}; do
		cp -R $1/$f $2
	done
}
function copyAndroidResources()
{
	if [ ! -d $2 ]; then
		mkdir $2
	fi
	ANDROID_FOLDERS=( "Android" )
	for f in ${ANDROID_FOLDERS[@]}; do
		cp -R $1/$f $2
	done
}
function copyIOSResources()
{
	if [ ! -d $2 ]; then
		mkdir $2
	fi
	IOS_FOLDERS=( "iOS" )
	for f in ${IOS_FOLDERS[@]}; do
		cp -R $1/$f $2
	done
}
function copyWindowsResources()
{
	if [ ! -d $2 ]; then
		mkdir $2
	fi
	IOS_FOLDERS=( "StandaloneWindows" )
	for f in ${IOS_FOLDERS[@]}; do
		cp -R $1/$f $2
	done
}
function copyMacResources()
{
	if [ ! -d $2 ]; then
		mkdir $2
	fi
	IOS_FOLDERS=( "StandaloneOSXIntel64" )
	for f in ${IOS_FOLDERS[@]}; do
		cp -R $1/$f $2
	done
}