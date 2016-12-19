function svnCommitFile()
{
	svn add --parents --force $1
	if (($?)); then exit 1; fi
	svn ci -m "${2}"
	if (($?)); then exit 1; fi
}