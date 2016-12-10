#####################################
# --------- sric0880 ----------------
# --------- 2016/11/26 --------------
#####################################
. global.sh
checkBashVersion
commandInstalled Unity
gnugetopt
. config.sh
###################################################################################
CHANNELS=()
VERSION_NAME=''
VERSION_CODE=''
UNITY_PROJECT=''
RESOURCES=''
BRANCH=''
CHECKOUT=false
GIT_REV=''
SVN_REV=''
RELEASE=false
OUTPUT=''
PREBUILD=''
POSTBUILD=''
###################################################################################
function usage()
{
echo -e "The following options are available:
-h, --help\t\toptional, 显示帮助并退出
-c, --channels\t\t[ios-inhouse,ios-laohu,android-baidu,android-360,windows-ff,...]
\t\t\tSDK channel names seperated by ',' with the format of {platform}-{channelName}
--version-name\t\t[1.1.0] {main}.{major}.{minor}
--version-code\t\t[1001] build number
--unity-project\t\tpath of the target unity project, managed by git
--resources\t\tpath of the game resources, managed by svn
-b, --branch\t\tgit and svn branch, both have the same name
-o, --output\t\toutput path for final build package
--checkout\t\toptional, checkout git and svn to new branch or not.
\t\t\tBranch name has version-name as its suffix.
\t\t\tCheckout if need to backup the version, like release version.
--git-rev\t\toptional, use the target git revision to build, default the latest revision
--svn-rev\t\toptional, use the target svn revision to build, default the latest revision
-r, --release\t\toptional, unity build with release mode, without development mode. default false 
--prebuild\t\toptional, [prebuild.sh] excute this shell before unity build
--postbuild\t\toptional, [postbuild.sh] excute this shell after unity build
"
exit 0
}
args=`getopt -u -o hc:b:o:r -l help,channels:,version-name:,version-code:,unity-project:,resources:,branch:,output:,checkout,git-rev:,svn-rev:,release,prebuild:,postbuild: -n 'unitybuild.sh' -- $*`
if (($?)); then exit -1; fi
set -- $args

while true 
do
    case "$1" in
        -h|--help) 
						usage
            shift;;
        -c|--channels)
            CHANNELS=(${2//,/ })
            shift 2;;
        --version-name)
						VERSION_NAME=$2
            shift 2;;
        --version-code)
						VERSION_CODE=$2
            shift 2;;
				--unity-project)
						UNITY_PROJECT=$2
            shift 2;;
				--resources)
						RESOURCES=$2
            shift 2;;
				-b|--branch)
						BRANCH=$2
            shift 2;;
        -o|--output)
						OUTPUT=$2
            shift 2;;
				--checkout)
						CHECKOUT=true
            shift;;
				--git-rev)
						GIT_REV=$2
            shift 2;;
				--svn-rev)
						SVN_REV=$2
            shift 2;;
				-r|--release)
						RELEASE=true
            shift;;
				--prebuild)
						PREBUILD=$2
            shift 2;;
				--postbuild)
						POSTBUILD=$2
            shift 2;;
        --)
						shift; break;;
        *)
						usage
            ;;
    esac
done
if [ ${#CHANNELS[@]} -eq 0 ]; then logError "need -c,--channels option";  usage; fi
parseChannels CHANNELS[@]
if [ -z $VERSION_NAME ]; then logError "need --version-name option"; usage; fi
	if [[ ! $VERSION_NAME =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then logError "version-name format wrong"; usage; fi
if [ -z $VERSION_CODE ]; then logError "need --version-code option"; usage; fi
	if [[ ! $VERSION_CODE =~ ^[0-9]+$ ]]; then logError "version-code format wrong"; usage; fi
if [ -z $UNITY_PROJECT ]; then logError "need --unity-project option"; usage; fi
	if [ ! -d $UNITY_PROJECT ]; then logError "$UNITY_PROJECT not exists"; exit 1; fi
if [ -z $RESOURCES ]; then logError "need --resources option"; usage; fi
	if [ ! -d $RESOURCES ]; then logError "$RESOURCES not exists"; exit 1; fi
if [ -z $BRANCH ]; then logError "need -b,--branch option"; usage; fi
if [ -z $OUTPUT ]; then logError "need -o,--output option"; usage; fi
	if [ ! -d $OUTPUT ]; then mkdir -p $OUTPUT; fi
	if [ ! -d $OUTPUT ]; then logError "create output path $OUTPUT failed"; exit 1; fi
###################################################################################
temp_build_folder=$SCRIPT_ROOT/build
if [ ! -d $temp_build_folder ]; then mkdir $temp_build_folder; fi
build_log_file=$temp_build_folder/lastbuild.log
for p in ${!PLATFORM_PREFIX[@]}; do
	if hasPlatform $p; then
		target_build_path=${temp_build_folder}/${PLATFORM_BUILD_FILENAME[$p]}
		if $RELEASE; then
			args="Dev=False;Path=$target_build_path"
		else
			args="Dev=True;Path=$target_build_path"
		fi
		# Unity -batchmode -nographics -quit -logFile $build_log_file -projectPath $UNITY_PROJECT -executeMethod Build.${PLATFORM_BUILD_METHOD[$p]} -CustomArgs $args
		# if (($?)); then printUnityLogError $build_log_file; exit 1; fi
		# if [ $p == 'ios' ]; then xcodeBuild $target_build_path; fi  ### ios needs to build xcode project to produce .app
	fi
done
###################################################################################
for channel in ${CHANNELS[@]}; do
	{
		if [[ $channel =~ ^(..*)-(..*)$ ]]; then
			p=${BASH_REMATCH[1]}
			channelName=${BASH_REMATCH[2]}
			log "pid $BASHPID : start pack $p with channel $channelName"
			./pack-$p.sh ${temp_build_folder}/${PLATFORM_BUILD_FILENAME[$p]} $RESOURCES $channelName $OUTPUT $VERSION_NAME $VERSION_CODE
		fi
	} &
done

for pid in $(jobs -p); do
	wait $pid
	if (($?)); then
		logError "pid $pid : pack failed"
	fi
done
