import clr
import os
#clr.AddReference(r"C:\Users\Alex.Lundberg\SimpleGUI\src\GUILibrary\bin\Debug\GUILibrary.dll")
clr.AddReference(os.path.abspath("../bin/GUILibrary.dll"))
from GUILibrary import GUILibraryClass as sg
import time

sg.setWindow("Calculator - Calculator")
sg.Click("Clear")
sg.Click("id:num1Button")
sg.Click("id:num2Button")
sg.Click("id:num3Button")