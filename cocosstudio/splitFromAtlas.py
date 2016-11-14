# split pngs from Atlas using config.txt recursively.
from PIL import Image
from os import listdir
from os.path import isdir
from string import split, atoi

class info:
	def __init__(self):
		self.name = ''          # png name
		self.size = [-1, -1]    # png size
		self.offset = [-1, -1]  # png offset
	def infoPrint(self):
		print('name: ' + self.name)
		print('size: (%d*%d)' % (self.size[0], self.size[1]))
		print('offset: (%d, %d)' % (self.offset[0], self.offset[1]))

# parse from config file	
def parseConfigFile(config):
	infoList = []
	file = open(config)
	lines = file.readlines()
	nL = len(lines)
	# remove space and tab in lines
	for i in range(0, nL - 1):
		lines[i] = lines[i].replace(' ', '')
		lines[i] = lines[i].replace('\t', '')
	i = 0
	while i < nL:
		pngInfo = info()
		try:
			# parse one png info
			while lines[i][0] != '\n':
				if lines[i][0] >= '0' and lines[i][0] <= '9':
					inx = lines[i].find('*')
					if inx >= 0:
						# size
						w = atoi(lines[i][0 : inx])
						h = atoi(lines[i][inx + 1 : -1])
						pngInfo.size[0] = w
						pngInfo.size[1] = h
					else:
						# offset
						inx = lines[i].find(',')
						if inx < 0:
							print(config + " error")
							i += 1
							continue
						x = atoi(lines[i][0 : inx])
						# config.txt's last line maybe end with '\n' or a number
						# may case number parse error without this if 
						if lines[i][len(lines[i]) - 1] != '\n':
							y = atoi(lines[i][inx + 1 :])
						else:
							y = atoi(lines[i][inx + 1 : -1])
						pngInfo.offset[0] = x
						pngInfo.offset[1] = y
				elif lines[i][0] >= 'A' and lines[i][0] <= 'z':
					# name
					pngInfo.name = lines[i].strip('\n')
				i += 1
		except IndexError:
			# if config.txt file is not end with '\n' may cause this exception
			pass
		# save pngInfo to infoList
		if pngInfo.name != '':
			if pngInfo.size[0] < 0 or pngInfo.size[1] < 0 or \
			   pngInfo.offset[0] < 0 or pngInfo.offset[1] < 0:
			   print(config + " pngInfo error.")
			else:
				infoList.append(pngInfo)
		i += 1
	return infoList

def createPngsFromInfoList(png, infoList):
	im = Image.open(png)
	pathList = png.split('\\')
	nItem = len(pathList)
	pngNameLen = len(pathList[nItem - 1])
	# curPath is not end with '\'
	curPath = png[: -(pngNameLen + 1)]
	for info in infoList:
		# (x1, y1, x2, y2) == (upLeft, bottomRight)
		curPngName = curPath + '\\' + info.name + '.png'
		rect = (info.offset[0], info.offset[1], \
		        info.offset[0] + info.size[0], info.offset[1] + info.size[1])
		currPng = im.crop(rect)
		currPng.save(curPngName)
		print('split ' + curPngName + ' success.')

def createPngs(png, config):
	print('spliting ' + png)
	infoList = parseConfigFile(config)
	createPngsFromInfoList(png, infoList)
	print('\n')
	# for info in infoList:
	# 	info.infoPrint()
	# 	print('')

def getAllFloderNames(path):
	existFloders = []
	for floderName in listdir(path):
		if isdir(path + '\\' + floderName):
			existFloders.append(floderName)
	return existFloders

def splitFromAtlas(path):
	allItem = listdir(path)
	allFloder = getAllFloderNames(path)
	pathList = path.split('\\')
	pathLength = len(pathList)

	if 'config.txt' in allItem:
		try:
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

				# create pngs from atlas
				if pngName + '.png' in allItem:
					createPngs(path + '\\' + pngName + '.png', path + '\\' + 'config.txt')
				else:
					print(pngName + '.png' + ' is not in ' + path)
		except IndexError:
			print(pathList + ' IndexError')

	for floder in allFloder:
		if floder != 'tmp':
			splitFromAtlas(path + '\\' + floder)

splitFromAtlas('.')
