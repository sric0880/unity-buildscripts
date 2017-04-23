#!/usr/bin/env python
#-*- coding: utf-8

import yaml, sys, os, shutil
from os import path

confResourcesLocal  = '/usr/local/unitybuild/resources-local.yaml'

def copy(platform, source, target):

	'''copy resources from source to package target'''

	configLocal  = None
	with file(confResourcesLocal, 'r') as stream:
		configLocal = yaml.load(stream)

	if not configLocal:
		print("config file not exists.")
		sys.exit(1)

	if not path.exists(target):
		os.makedirs(target)

	allFiles = configLocal['common']['files']
	if allFiles:
		allFiles.extend(configLocal[platform]['files'] or [])
	else:
		allFiles = configLocal[platform]['files']

	allIgnoreFiles = configLocal['common']['ignore']
	if allIgnoreFiles:
		allIgnoreFiles.extend(configLocal[platform]['ignore'] or [])
	else:
		allIgnoreFiles = configLocal[platform]['ignore']

	if not allFiles:
		print('no resources to copy')
		return
	
	print(allFiles)
	print(allIgnoreFiles)

	def isIgnoreFile(file):
		for ignoreFile in allIgnoreFiles:
			if ignoreFile in file:
				print('file %s is ignored.' % file)
				return True
		return False

	for f in allFiles:
		s = path.join(source, f)
		t = path.join(target, f)
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
				relative = dirname[len(source)+1:]
				target_folder = path.join(target, relative)
				if not path.exists(target_folder):
					os.makedirs(target_folder)
				shutil.copyfile(ss, path.join(target_folder, filename))
