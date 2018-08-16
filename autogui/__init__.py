import clr
import os
import sys

clr.AddReference(sys.prefix + r'\Lib\site-packages\autogui\bin\GUILibrary.dll')
from GUILibrary import GUILibraryClass as gl

def click(id):
    gl.Click(id)
def write(value,id):
    gl.Write(value,id)
def setWindow(id):
    gl.setWindow(id)
def append(value,id):
    gl.Append(value,id)
def rightclick(value,id):
    gl.RightClick(value,id)
def sendkey(key):
    gl.SendKey(key)
def read(id):
    return gl.Read(id)