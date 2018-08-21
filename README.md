AutoGui is a GUI Automation/Test tool giving the user high level keywords to automate WPF and winform applications.

install using pip install autogui

To use, generate scripts using RecorderSpy.exe in tools folder. Use ctrl-r to start recording, ctrl-e to end recording, and ctrl-w to select a GUI element during recording.

Methods available.  
	string Read(string selector, int child = 0, double timeout = 3)  
	setWindow(string window,boolean contains=false,double timeout=3)  
	Click(string selector, int child = 0,double timeout=3)  
	SendKey(string keys)  
	RightClick(string selector,int child=0,double timeout=3)  
	Append(string inputText,string selector,int child=0,double timeout=3)  
	Write(string value, string selector, int child = 0, double timeout=3,string mode="overwrite")  
	Open(string app, boolean setActive=false)  
	Close(string window="activeWindow")  

One can choose to setWindow based on a partial match by setting the contains keyword to true. This can be useful if you don't know the title of your application until runtime.  

One can choose to Open and application and set it to the activeWindow. This is by default true, but will fail for certain applications. This is because the initial application will launch a subprocess with a different title. If this fails, just set the flag to false.  

example:  
	from autogui import *  
	open("notepad")  
	write("My name is Alex Lundberg","Text Editor")  
	close()  
	open("calc")  
	click("One")  
	click("Two")  
	close()  
	
	
	
	
	
