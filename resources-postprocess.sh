. global.sh
## TODO ...
PLATFORM=$1
RESOURCES_ROOT=$2

# perl -pi -e "s/(?<=[(branches)|(ffyd)]\/)\w*(?=\/)/${Branch}/g" $Update

# echo 'enable use external autoupdate'
# perl -pi -e 's/<use_home_update_urls>.*<\/use_home_update_urls>/<use_home_update_urls>false<\/use_home_update_urls>/g' $Update

# if [ $Update == 'on' ]; then
# 	echo AutoUpdate On
# 	perl -pi -e 's/<auto_update_res>.*<\/auto_update_res>/<auto_update_res>true<\/auto_update_res>/g' $Boot
# elif [ $Update == 'off' ]; then
# 	echo AutoUpdate Off
# 	perl -pi -e 's/<auto_update_res>.*<\/auto_update_res>/<auto_update_res>false<\/auto_update_res>/g' $Boot
# else
# 	echo Do nothing
# fi

# if [ $Switch == 'on' ]; then
#         echo Console On
#         perl -pi -e 's/<show_console>\d/<show_console>1/g' $Systemconst
# elif [ $Switch == 'off' ]; then
#         echo Console Off
#         perl -pi -e 's/<show_console>\d/<show_console>0/g' $Systemconst
# else
#         echo Do nothing
# fi

# sed -i '.bck' "s/<locale>.*<\/locale>/<locale>${Locale}<\/locale>/" $Boot
# rm ${Boot}.bck