#!/usr/bin/env python
#-*- coding: utf-8

import yaml, argparse, sys, os, shutil
from os import path

parser = argparse.ArgumentParser(description='copy resources from source to package target')
parser.add_argument('platform', help='平台名称', choices=['ios', 'android', 'windows', 'mac'])
parser.add_argument('source', help='源资源文件夹根目录')
parser.add_argument('target', help='目标包资源文件夹目录')
args = parser.parse_args()

confResourcesLocal  = 'resources-local.yaml'

configLocal  = None

with file(confResourcesLocal, 'r') as stream:
	configLocal = yaml.load(stream)

if not configLocal:
	print("config file not exists.")
	sys.exit(1)

if not path.exists(args.target):
	os.makedirs(args.target)
allFiles = configLocal['common']['files']
allIgnoreFiles = configLocal['common']['ignore']
allFiles.extend(configLocal[args.platform]['files'] or [])
allIgnoreFiles.extend(configLocal[args.platform]['ignore'] or [])
print(allFiles)
print(allIgnoreFiles)

def isIgnoreFile(file):
	for ignoreFile in allIgnoreFiles:
		if ignoreFile in file:
			print('file %s is ignored.' % file)
			return True
	return False

for f in allFiles:
	s = path.join(args.source, f)
	t = path.join(args.target, f)
	# print('copy from %s to %s' % (s, t))
	if path.isfile(s):
		shutil.copyfile(s, t)
	else:
		fileList = [path.join(root, fn).replace('\\','/') for root, dirs, files in os.walk(s) for fn in files]
		for ss in fileList:
			if isIgnoreFile(ss):
				continue
			dirname = path.dirname(ss)
			filename = path.basename(ss)
			relative = dirname[len(args.source)+1:]
			target_folder = path.join(args.target, relative)
			if not path.exists(target_folder):
				os.makedirs(target_folder)
			shutil.copyfile(ss, path.join(target_folder, filename))
