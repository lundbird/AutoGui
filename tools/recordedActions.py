import clr
import os
clr.AddReference(os.path.abspath("../bin/GUILibrary.dll"))
from GUILibrary import GUILibraryClass as sg

sg.setWindow("SG6801(#1) - S&C IntelliLink Setup Software [611.23]")
sg.Click("Setup")
sg.Click("General")
sg.Click("Fault Detection")
sg.Click("value:=800")
sg.Click("Validate")
sg.Click("value:=Settings Validation Successful")
sg.Click("Apply")
sg.Click("value:=Settings Applied Successfully")