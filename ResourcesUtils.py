#!/usr/bin/env python
#-*- coding: utf-8

import os
from os import path

def readMD5List(filename):
	with open(filename, 'r') as f:
		lines = [ x.strip('\n') for x in f.readlines()]
		count = len(lines)
		paths = lines[2:count:3]
		md5 = lines[3:count:3]
		sizes = lines[4:count:3]
		data = { x[0]:(x[1], x[2]) for x in zip(*[paths, md5, sizes]) } 
		return data

# 如果集合data1和集合data2中都有资源a
# 那么a的md5和size必须相等，否则报错
# 暂时没有用到该函数
def unionMD5List(data1, data2):
	if data1 == None and data2 == None:
		return None
	elif data1 == None:
		return data2
	elif data2 == None:
		return data1
	if data1 == data2:
		return data1

	for key,value in data1.items():
		value2 = data2.get(key)
		if value2!=None:
			if value2[0]!=value[0] or value2[1] !=value[1]:
				raise Exception("%s not match" % key)

	return dict(data1, **data2)

# 从所有资源列表中收集md5值存入set当中
def mergeMD5List(listfiles):
	ret = set()
	for f in listfiles:
		if not path.exists(f) or not path.isfile(f):
			print("Warning file %s not found" % f)
			continue
		else:
			data = readMD5List(f)
			ret = ret | set([ x[0] for _,x in data.items() ])
			print(len(ret))
	return ret