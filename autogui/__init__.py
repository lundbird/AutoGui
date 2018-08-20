import clr
import os
import sys

clr.AddReference(sys.prefix + r'\Lib\site-packages\autogui\bin\GUILibrary.dll')
from GUILibrary import GUILibraryClass as gl

#these are a complete copy-paste of the method definitions in the dll.
#With IronPthon the dll methods can be used directly: from GUILibrary.GUILibraryClass import *
def click(id,child=0,timeout=gl.timeout):
    gl.Click(id,child,timeout)
def write(value,id,child=0,timeout=gl.timeout):
    gl.Write(value,id,child,timeout)
def setWindow(id,contains=False,timeout=gl.timeout):
    gl.setWindow(id,contains,timeout)
def append(value,id,child=0,timeout=gl.timeout):
    gl.Append(value,id,child,timeout)
def rightclick(id,child=0,timeout=gl.timeout):
    gl.RightClick(id,child,timeout)
def sendkey(key):
    gl.SendKey(key)
def read(id,child=0,timeout=gl.timeout):
    return gl.Read(id,child,timeout)
def open(app,setActive=True):
    gl.Open(app,setActive)
def close(window="activeWindow"):
    gl.Close(window)

#convenience methods to get and set the default timeout.
def setTimeout(time):
    gl.timeout=time
def getTimeout():
    return gl.timeout
    