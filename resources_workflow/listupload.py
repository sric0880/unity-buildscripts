#!/usr/bin/env python
#-*- coding: utf-8
## upload files that needed for hotfix
import os
import shutil
import zipfile
import yaml
import time
import ResourcesUtils
from os import path

def listupload(confReourcesUpload, platform, source, target, channelName):

	'''generate resources list file for hotfix'''

	confHotfixServer  = None

	with file(confReourcesUpload, 'r') as stream:
		confHotfixServer = yaml.load(stream)

	if not confHotfixServer:
		print("config file not exists.")
		sys.exit(1)

	uploadLogFolder = confHotfixServer['logDir']
	outputFolderName = confHotfixServer['localDir']
	hotfixServerIP = confHotfixServer['ip']
	hotfixServerDir = confHotfixServer['remoteDir']

	if hotfixServerIP == None or hotfixServerDir == None:
		print("there is no hotfix server to upload.")
		return

	serverResListDict = ResourcesUtils.readMD5List(path.join(source, 'reslist.dat'))
	localResListDict = ResourcesUtils.readMD5List(path.join(target, 'reslist.dat'))

	if not path.exists(outputFolderName):
		os.makedirs(outputFolderName)
	if not path.exists(uploadLogFolder):
		os.makedirs(uploadLogFolder)
	for filename, value in serverResListDict.items():
		targetFile = path.join(outputFolderName, value[0])
		if path.exists(targetFile):
			continue
		if filename in localResListDict:
			sourceFile = path.join(target, filename)
		else:
			sourceFile = path.join(source, filename)
		## zip target file
		with zipfile.ZipFile(targetFile, 'w', zipfile.ZIP_DEFLATED) as myzip:
			myzip.write(sourceFile, 'file')
	shutil.copy(path.join(source, 'reslist.dat'), path.join(outputFolderName, 'reslist_%s_%s.dat' % (platform, channelName)))

	## delete resource that not needed for hotfix any more
	allfiles = os.listdir(outputFolderName)
	listfiles = filter(lambda x:path.isfile(x) and x.endswith('.dat'), [ path.join(outputFolderName, x) for x in allfiles ])
	resfiles = filter(lambda x:path.isfile(x) and not x.endswith('.dat'), allfiles)
	md5Set = ResourcesUtils.mergeMD5List(listfiles)
	for res in resfiles:
		if res not in md5Set:
			print('remove resource file: %s' % res)
			os.remove(res)

	## rsync to hotfix server dir
	now = int(time.time())
	timestamp = time.localtime(now)
	timeformat = time.strftime("%Y.%m.%d.%H.%M.%S", timestamp)
	cmd = 'rsync -avzr --progress --exclude ".DS_Store" --delete %s/ %s:%s > %s/upload-%s.log' % (outputFolderName, hotfixServerIP, hotfixServerDir, uploadLogFolder, timeformat)
	if os.system(cmd) != 0:
		raise Exception('Error rysnc to hotfix server')
	else:
		print('Success rsync to hotfix server')
