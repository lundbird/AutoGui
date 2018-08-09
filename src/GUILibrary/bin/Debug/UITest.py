import clr
clr.AddReference(r"C:\Users\Alex.Lundberg\SimpleGUI\src\GUILibrary\bin\Debug\GUILibrary.dll")
from GUILibrary import GUILibrary
driver = GUILibrary()
driver.setWindow("SC IntelliShell Remote")
#driver.setWindow("Untitled - Notepad")
