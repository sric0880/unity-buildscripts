function svnCommitFile()
{
	svn add --parents --force $1
	if (($?)); then exit 1; fi
	svn ci -m "${2}"
	if (($?)); then exit 1; fi
}

function isSvnRepo()
{
	svnrepo=`pwd`
	if [ -d .svn ]; then
		return 0
	else
		logWarning "${svnrepo} is not svn repo."
		return 1
	fi
}

CURRENT_SVNREV=''
function currentSvnRev()
{
	CURRENT_SVNREV=`svn info | grep "Last Changed Rev"| sed -e "s/Last Changed Rev: \(.*\)/\1/"`
	log "current svn revision is ${CURRENT_SVNREV}"
}

function changeSvnRev()
{
	echo "svn update -r ${1}"
	svn update -r $1
	if (($?)); then exit 1; fi
}

function svnNewBranch()
{
	svn_root_url=$(svn info | sed -n 's/^Repository Root: //p')
	echo "svn rm -m "" ${svn_root_url}/branches/${2}"
	svn rm -m "" ${svn_root_url}/branches/${2}
	echo "svn copy -m "" ${svn_root_url}/${1} ${svn_root_url}/branches/${2}"
	svn copy -m "new branch from ${1}" ${svn_root_url}/${1} ${svn_root_url}/branches/${2}
	if (($?)); then exit 1; fi
}

function svnCheckoutBranch()
{
	svn_root_url=$(svn info | sed -n 's/^Repository Root: //p')
	echo "svn switch ${svn_root_url}/branches/${1}"
	svn switch ${svn_root_url}/branches/${1} --accept tf
	if (($?)); then exit 1; fi
	svn info
}