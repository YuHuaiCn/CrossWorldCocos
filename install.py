import os, sys

NDK_ROOT = "C:\\Cocos\\tools\\android-ndk-r10e"
os.system("cocos run -p android -j 4")
os.system('C:\Cocos\\tools\\ant\\bin\\ant clean debug -f frameworks\\runtime-src\\proj.android\\build.xml -Dsdk.dir="C:\\Cocos\\tools\\Android-SDK"')
#os.system('adb uninstall org.cocos2dx.CrossWorld')
os.system('adb install -r frameworks\\runtime-src\\proj.android\\bin\\AppActivity-debug.apk')
