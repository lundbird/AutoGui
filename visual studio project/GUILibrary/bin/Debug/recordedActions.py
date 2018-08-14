import clr
import os
clr.AddReference(os.path.abspath("GUILibrary.dll"))
from GUILibrary import GUILibraryClass as sg

sg.setWindow("SG6801(#1) - S&C IntelliLink Setup Software [611.23]")
sg.Click("Setup")