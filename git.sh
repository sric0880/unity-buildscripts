. global.sh

CURRENT_GITREV=''
CURRENT_GITBRANCH=''

# Check project is git repo or not, YES return 0 or return 1
function isGitRepo()
{
	gitrepo=`pwd`
	if [ -d .git ] || git rev-parse --git-dir > /dev/null 2>&1; then
		return 0
	else
		logWarning "${gitrepo} is not git repo."
		return 1
	fi
}

# Get current git revision
function currentGitRev()
{
	CURRENT_GITREV=$(git rev-parse HEAD)
	log "current git revision is ${CURRENT_GITREV}"
}

function currentGitBranch()
{
	CURRENT_GITBRANCH=$(git rev-parse --abbrev-ref HEAD)
	log "current git branch is ${CURRENT_GITBRANCH}"
}

# update to latest revision
function gitPull()
{
	echo "git fetch origin ${1}"
	git fetch origin $1
	if (($?)); then exit 1; fi
	reslog=$(git log HEAD..origin/$1 --oneline)
	if [ ! -z "${reslog}" ]; then
		echo "Need to pull: ${reslog}"
		echo "git clean -df"
		git clean -df
		echo "git reset --hard HEAD"
		git reset --hard HEAD
		echo "git merge origin/${1}"
		git merge origin/$1
		if (($?)); then exit 1; fi
	else
		echo "Not need to pull, git is the latest"
	fi
}

function gitNewBranch()
{
	echo "git branch -d ${1}"
	git branch -d $1
	echo "git push origin --delete ${1}"
	git push origin --delete $1
	echo "git branch ${1}"
	git branch $1
	echo "git push origin ${1}"
	git push origin $1
}

function gitCheckoutBranch()
{
	echo "git clean -df"
	git clean -df
	echo "git reset --hard HEAD"
	git reset --hard HEAD
	echo "git fetch origin ${1}"
	git fetch origin $1
	if (($?)); then exit 1; fi
	echo "git checkout ${1}"
	git checkout $1
	if (($?)); then exit 1; fi
	echo "git merge origin/${1}"
	git merge origin/$1
	if (($?)); then exit 1; fi
}

#Change git rev to target rev
function changeGitRev()
{
	#Check the target rev exist or not
	if git cat-file -e $1; then
		log "${1} exists, reset --hard to it"
		git reset --hard $1
	else
		logError "${1} not exists"
		exit 1
	fi
}

# Test
# if isGitRepo; then echo '....'; else echo "..."; fi
# if isGitRepo ..; then echo '....'; else echo "..."; fi
# if isGitRepo $1; then echo '....'; else echo "..."; fi
# gitCheckoutBranch test11
