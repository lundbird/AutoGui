import clr
import os
clr.AddReference(os.path.abspath("../bin/GUILibrary.dll"))
from GUILibrary import GUILibraryClass as gl

class SimpleGUI:
    def click(self,id):
        gl.Click(id)
    def write(self,value,id):
        gl.Write(value,id)
    def setWindow(self,id):
        gl.setWindow(id)
    def append(self,value,id):
        gl.Append(value,id)
    def rightclick(self,value,id):
        gl.RightClick(value,id)
    def sendkey(self,key):
        gl.SendKey(key)
    def read(self,id):
        return gl.Read()