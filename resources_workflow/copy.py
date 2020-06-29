#!/usr/bin/env python
#-*- coding: utf-8

import yaml, sys, os, shutil
from os import path

def copy(confResourcesLocal, platform, source, target):

	'''copy resources from source to package target'''

	configLocal  = None
	with open(confResourcesLocal, 'r') as stream:
		configLocal = yaml.safe_load(stream)

	if not configLocal:
		print("config file not exists.")
		sys.exit(1)

	if not path.exists(target):
		os.makedirs(target)

	doCopy(configLocal['common']['files'], configLocal['common']['ignore'], source, target)
	doCopy(configLocal[platform]['files'], configLocal[platform]['ignore'], source, target)

def isIgnoreFile(file, ignoreFiles):
	if ignoreFiles is None:
		return False
	for ignoreFile in ignoreFiles:
		if ignoreFile in file:
			print('file %s is ignored.' % file)
			return True
	return False

def doCopy(includeFiles, ignoreFiles, source, target):
	print("Copy Files: ", includeFiles)
	print("Ingored Files: ", ignoreFiles)
	if includeFiles is None:
		return
	for f in includeFiles:
		s = path.join(source, f)
		t = path.join(target, f)
		# print('copy from %s to %s' % (s, t))
		if path.isfile(s):
			shutil.copyfile(s, t)
		else:
			fileList = [path.join(root, fn).replace('\\','/') for root, dirs, files in os.walk(s) for fn in files]
			for ss in fileList:
				if isIgnoreFile(ss, ignoreFiles):
					continue
				dirname = path.dirname(ss)
				filename = path.basename(ss)
				relative = dirname[len(source)+1:]
				target_folder = path.join(target, relative)
				if not path.exists(target_folder):
					os.makedirs(target_folder)
				shutil.copyfile(ss, path.join(target_folder, filename))