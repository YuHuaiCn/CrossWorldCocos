
from os import listdir
from os.path import exists, isdir
import os
return
def getAllFloderNames(path):
	existFloders = []
	for floderName in listdir(path):
		if isdir(path + '\\' + floderName):
			existFloders.append(floderName)
	return existFloders

def simpleName(path):
	allFloder = getAllFloderNames(path)
	for floder in allFloder:
		for i in range(len(floder) - 1, -1, -1):
			if ord(floder[i]) >= ord('A') and ord(floder[i]) < ord('Z'):
				if not exists(path + '\\' + floder[i:]):
					os.rename(path + '\\' + floder, path + '\\' + floder[i:])
				break

subFloder = getAllFloderNames('.')
for floder in subFloder:
	if floder != 'unused':
		simpleName('.\\' + floder)
