import clr
clr.AddReference(r"C:\Users\Alex.Lundberg\SimpleGUI\src\GUILibrary\bin\Debug\GUILibrary.dll")
from GUILibrary import GUILibrary

class GUILibraryPy:
    def __init__(self):
        self.driver = GUILibrary()
    def click(self,id):
        self.driver.Click(id)
    def write(self,value,id):
        self.driver.Write(value,id)
    def setWindow(self,id):
        self.driver.setWindow(id)
    def append(self,value,id):
        self.driver.Append(value,id)
    def read(self,id):
        return self.driver.Read()
