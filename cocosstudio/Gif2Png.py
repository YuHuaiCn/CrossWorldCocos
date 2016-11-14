# function: Get Frames from Gifs and storage into floders recursively. 
#           The floder and Gif are in the same path.
from PIL import Image
from os import mkdir, listdir
from os.path import exists, isdir
from string import index

# get Gifs' names in current path and storage them in FileList
def getAllGifNames(path):
	existGifs = []
	for fileName in listdir(path):
		try:
			fileName.index('.gif')
			existGifs.append(fileName[:-4])
		except ValueError:
			continue
	return existGifs

# get Pngs' names in current path and storage them in FileList
def getAllPngNames(path):
	existPngs = []
	for fileName in listdir(path):
		try:
			fileName.index('.png')
			existPngs.append(fileName[:-4])
		except ValueError:
			continue
	return existPngs

def getAllFloderNames(path):
	existFloders = []
	for floderName in listdir(path):
		if isdir(path + '\\' + floderName):
			existFloders.append(floderName)
	return existFloders

# create pngs from Gifs and remove background then save pngs in 'name' floder
# if in 'name' floder target png is already exists this function will not creat it again
def createFrames(path, gifName):
	existPngs = []
	if exists(path + '\\' + gifName) == False:
		mkdir(path + '\\' + gifName)
	else:
		# get Pngs' names in 'gifName' floder
		existPngs = getAllPngNames('%s\\%s' % (path, gifName))

	im = Image.open(path + '\\' + gifName + '.gif')
	tmpCol = im.convert('RGBA').getpixel((0, 0))
	x, y = im.size

	try:
		for n in range(0, 999):
			pngName = '%s%03d' % (gifName, n)
			# if exist png then continue
			if pngName in existPngs:
				pass
				#print pngName + ' exists'
			else:
				# convert this png
				last_frame = im.convert('RGBA')
				for i in range(0, x):
		 			for j in range(0, y):
		 				if tmpCol == last_frame.getpixel((i, j)):
		 					last_frame.putpixel((i, j), (0, 0, 0, 0))
				last_frame.save('%s\\%s\\%s.png' % 
					            (path, gifName, pngName))
			im.seek(im.tell() + 1)
	except EOFError:
	    pass

# convert all gifs to pngs recursively
def gif2Png(path):
	existGifs = getAllGifNames(path)
	existFloder = getAllFloderNames(path)
	# deal with gifs in 'path'
	for gifName in existGifs:
		createFrames(path, gifName)
	# deal with sub path of 'path'
	for floderName in existFloder:
		if floderName != 'tmp':
			gif2Png(path + '\\' + floderName)

gif2Png('.')
