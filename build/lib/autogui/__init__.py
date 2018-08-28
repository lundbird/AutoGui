import clr
import os
import sys

dir_path = os.path.dirname(os.path.realpath(__file__))
clr.AddReference(dir_path + r'\src\GUILibrary\bin\Release\GUILibrary.dll')
from GUILibrary import GUILibraryClass as gl

timeout = 3
#these are a complete copy-paste of the method definitions in the dll.
#With IronPthon the dll methods can be used directly: from GUILibrary.GUILibraryClass import *
def click(id,child=0,timeout=timeout):
    gl.Click(id,child,timeout)
def write(value,id,child=0,timeout=timeout):
    gl.Write(value,id,child,timeout)
def setWindow(id,contains=True,timeout=timeout):
    gl.setWindow(id,contains,timeout)
def append(value,id,child=0,timeout=timeout):
    gl.Append(value,id,child,timeout)
def rightclick(id,child=0,timeout=timeout):
    gl.RightClick(id,child,timeout)
def sendkey(key):
    gl.SendKey(key)
def read(id,child=0,timeout=timeout):
    return gl.Read(id,child,timeout)
def open(app,setActive=True,timeout=timeout):
    gl.Open(app,setActive)
def close(window="activeWindow"):
    gl.Close(window)
def getActiveWindow():
    return gl.GetActiveWindow()
    