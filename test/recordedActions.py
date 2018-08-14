import clr
import os
clr.AddReference(os.path.abspath("../bin/GUILibrary.dll"))
from GUILibrary import GUILibraryClass as sg

sg.setWindow("Calculator - Calculator")
sg.Click("id:num1Button")
sg.Click("id:num2Button")