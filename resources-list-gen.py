#!/usr/bin/env python
#-*- coding: utf-8
import yaml, argparse, os, hashlib
from os import path

parser = argparse.ArgumentParser(description='generate resources list file for hotfix')
parser.add_argument('platform', help='平台名称', choices=['ios', 'android', 'windows', 'mac'])
parser.add_argument('source', help='源资源文件夹根目录')
parser.add_argument('target', help='目标包资源文件夹目录')
args = parser.parse_args()

confResourcesUpdate = 'resources-update.yaml'

configUpdate = None

with file(confResourcesUpdate, 'r') as stream:
	configUpdate = yaml.load(stream)

if not configUpdate:
	print("config file not exists.")
	sys.exit(1)

allFiles = configUpdate['common']['files']
allIgnoreFiles = configUpdate['common']['ignore']
allFiles.extend(configUpdate[args.platform]['files'] or [])
allIgnoreFiles.extend(configUpdate[args.platform]['ignore'] or [])
print(allFiles)
print(allIgnoreFiles)

def isIgnoreFile(file):
	for ignoreFile in allIgnoreFiles:
		if ignoreFile in file:
			print('file %s is ignored.' % file)
			return True
	return False

def genResList(root):
	fileMd5List = {}
	for f in allFiles:
		res = path.join(root, f)
		if path.isfile(res):
			fileMd5List[f] = (hash(res), path.getsize(res))
		elif path.isdir(res):
			for parent, dirnames, filenames in os.walk(res):
				for name in filenames:
					filepath = path.join(parent, name)
					if isIgnoreFile(filepath):
						continue
					relative_path = filepath[len(root)+1:]
					fileMd5List[relative_path] = (hash(filepath), path.getsize(filepath))
		else:
			print('res %s not found' % res)

	return fileMd5List

def writeResList(root, Md5List):
	content = '\n'.join(['%s\n%s\n%s'%(f, value[0], value[1]) for f,value in Md5List.items()])
	contentMD5 = hashstr(content)

	with open(path.join(root, 'reslist.dat'), 'w') as f:
		f.write(contentMD5)
		f.write('\n')
		f.write('%d'%len(Md5List))
		f.write('\n')
		f.write(content)

def hash(filepath):
	m = hashlib.md5()
	with open(filepath, "rb") as f:
		str = f.read(8096)
		while str:
			m.update(str)
			str = f.read(8096)
		strMd5 = m.hexdigest()
	return strMd5

def hashstr(str):
	m = hashlib.md5()
	m.update(str)
	return m.hexdigest()

innerFileMd5List = genResList(args.source) # inner package
serverFileMd5List = genResList(args.target) # upload to server

## 服务器允许比本地列表多某些资源（只供热更新下载）
for f,value in serverFileMd5List.items():
	if f in innerFileMd5List:
		innerValue = innerFileMd5List[f]
		if value[0] != innerValue[0]:
			serverFileMd5List[f] = (innerValue[0], innerValue[1])

writeResList(args.source, innerFileMd5List)
writeResList(args.target, serverFileMd5List)
