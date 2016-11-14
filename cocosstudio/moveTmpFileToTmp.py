
from os import listdir, mkdir
from os.path import isdir
import shutil, os

# get all gif names(with .gif) in path
def getAllGifNames(path):
	existGifs = []
	for fileName in listdir(path):
		try:
			fileName.index('.gif')
			existGifs.append(fileName)
		except ValueError:
			continue
	return existGifs

def getAllFloderNames(path):
	existFloders = []
	for floderName in listdir(path):
		if isdir(path + '\\' + floderName):
			existFloders.append(floderName)
	return existFloders

def moveTmpFileToTmp(path):
	existGifs = getAllGifNames(path)
	existFloder = getAllFloderNames(path)
	allItem = listdir(path)
	tarPath = '.\\tmp\\' + path[2:]
	# move gifs in current path
	for gif in existGifs:
		oldGifPath = path + '\\' + gif
		if os.path.exists(tarPath):
			shutil.move(oldGifPath, tarPath)
		else:
			os.makedirs(tarPath)
			shutil.move(oldGifPath, tarPath)
	# move config.txt and tar png
	pngName = ''
	pathList = path.split('\\')
	pathLength = len(pathList)
	if 'config.txt' in allItem:
		# move config.txt to tarPath
		print(path + '\\' + 'config.txt')
		if os.path.exists(tarPath):
			shutil.move(path + '\\' + 'config.txt', tarPath)
		else:
			os.makedirs(tarPath)
			shutil.move(path + '\\' + 'config.txt', tarPath)
		curPath = pathList[pathLength - 1]
		fatherPath = pathList[pathLength - 2]
		if curPath == '.' or fatherPath == '.':
			print("CurrentPath and FatherPath can't be '.'")
		else:
			if fatherPath == 'Levels':
				# in 'Levels' floder the png is in same name with curPath
				# 'Levels' is the fatherPath of tar png
				pngName = curPath
			elif curPath == 'Weapon':
				# in the 'Weapon' floder the tar png's name is 'Weapon.png'
				pngName = curPath
			else:
				# the tar png is named by fatherPath and curPath
				pngName = fatherPath + '_' + curPath
			# move tar png to tarPath
			if pngName + '.png' in allItem:
				shutil.move(path + '\\' + pngName + '.png', tarPath)
			else:
				print(pngName + '.png' + ' is not in ' + path)

	# move files in sub path
	for floder in existFloder:
		if floder != 'tmp':
			moveTmpFileToTmp(path + '\\' + floder)

moveTmpFileToTmp('.')
