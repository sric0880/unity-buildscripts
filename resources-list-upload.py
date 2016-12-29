#!/usr/bin/env python
#-*- coding: utf-8
## upload files that needed for hotfix
import argparse, os, shutil, ResourcesUtils, zipfile, yaml, time
from os import path

parser = argparse.ArgumentParser(description='generate resources list file for hotfix')
parser.add_argument('platform', help='平台名称', choices=['ios', 'android', 'windows', 'mac'])
parser.add_argument('source', help='源资源文件夹根目录')
parser.add_argument('target', help='目标包资源文件夹目录')
parser.add_argument('channelName', help='渠道名称')
args = parser.parse_args()

confHotfixServer  = None

with file('resources-hotfix-server.yaml', 'r') as stream:
	confHotfixServer = yaml.load(stream)

if not confHotfixServer:
	print("config file not exists.")
	sys.exit(1)

uploadLogFolder = confHotfixServer['logDir']
outputFolderName = confHotfixServer['localDir']
hotfixServerIP = confHotfixServer['ip']
hotfixServerDir = confHotfixServer['remoteDir']

serverResListDict = ResourcesUtils.readMD5List(path.join(args.source, 'reslist.dat'))
localResListDict = ResourcesUtils.readMD5List(path.join(args.target, 'reslist.dat'))

if not path.exists(outputFolderName):
	os.makedirs(outputFolderName)
if not path.exists(uploadLogFolder):
	os.makedirs(uploadLogFolder)
for filename, value in serverResListDict.items():
	targetFile = path.join(outputFolderName, value[0])
	if path.exists(targetFile):
		continue
	if filename in localResListDict:
		sourceFile = path.join(args.target, filename)
	else:
		sourceFile = path.join(args.source, filename)
	## zip target file
	with zipfile.ZipFile(targetFile, 'w', zipfile.ZIP_DEFLATED) as myzip:
		myzip.write(sourceFile, 'file')
shutil.copy(path.join(args.source, 'reslist.dat'), path.join(outputFolderName, 'reslist_%s_%s.dat' % (args.platform, args.channelName)))

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
