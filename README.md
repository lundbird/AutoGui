AutoGui is a GUI Automation/Test tool giving the user high level keywords to automate WPF and winform applications.

install using pip install autogui

To use, generate scripts using RecorderSpy.exe in tools folder. Use ctrl-r to start recording, ctrl-e to end recording, and ctrl-w to select a GUI element during recording.

Methods available.
	string Read(string selector, int child = 0, double timeout = 5)  
	setWindow(string window,boolean contains=false,double timeout=5)  
	Click(string selector, int child = 0,double timeout=5)  
	SendKey(string keys)  
	RightClick(string selector,int child=0,double timeout=5)  
	Append(string inputText,string selector,int child=0,double timeout=5)  
	Write(string value, string selector, int child = 0, double timeout=5,string mode="overwrite")  
	Open(string app, boolean setActive=true)  
	Close()  

example:  
	from autogui import *  
	open("notepad")  
	write("My name is Alex Lundberg","Text Editor")  
	close()  
	open("calc")
	click("One")
	click("Two")
	close();
	
	
	
	
	
