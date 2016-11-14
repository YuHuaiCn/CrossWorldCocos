from   os import listdir, mkdir
from   os.path import isdir
import shutil, os

simPath = '.\\simulator\\win32\\'

def getAllFloderNames(path):
	existFloders = []
	for floderName in listdir(path):
		if isdir(path + '\\' + floderName):
			existFloders.append(floderName)
	return existFloders

def allFiles(path):
	allFile = []
	for file in listdir(path):
		if not isdir(path + '\\' + file):
			allFile.append(file)
	return allFile

def moveToSimulator(path):
	existFloder = getAllFloderNames(path)
	allFile = allFiles(path)
	# copy files in current path
	tarPath = simPath + path[2:]
	for file in allFile:
		oldGifPath = path + '\\' + file
		if os.path.exists(tarPath):
			shutil.copy(oldGifPath, tarPath)
		else:
			os.makedirs(tarPath)
			shutil.copy(oldGifPath, tarPath)
	# copy files in sub path
	for floder in existFloder:
		moveToSimulator(path + '\\' + floder)

#moveToSimulator('.\\res')
moveToSimulator('.\\src')
os.system('simulator\\win32\CrossWorld.exe')
