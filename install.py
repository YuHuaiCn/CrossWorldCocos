import os

os.system("cocos run -p android")
os.system('C:\Cocos\\tools\\ant\bin\\ant clean debug -f frameworks\\runtime-src\\proj.android\\build.xml -Dsdk.dir="C:\\Cocos\\tools\\Android-SDK"')
os.system('adb uninstall org.cocos2dx.CrossWorld')
os.system('adb install frameworks\\runtime-src\\proj.android\\bin\\CrossWorld-debug.apk')
