SimpleGUI is a GUI Automation/Test tool giving the user high level keywords to automate WPF and winform applications.

To use, generate scripts using RecorderSpy.exe in tools folder. Use ctrl-r to start recording, ctrl-e to end recording, and ctrl-w to select a GUI element during recording.

When you finish recording, robot and python scripts are generated which use the c# compiled SimpleGUI.dll in the bin folder.

To use this tool to make GUI test cases, use robot and make sure to have the SimpleGUI.py file in the same directory as the robot script.

The full list of available methods in python using the SimpleGUI.dll. All methods are static and void:
	string Read(string selector, int child = 0, double timeout = 5)
	setWindow(string window,double timeout=5)
	Click(string selector, int child = 0,double timeout=5)
	SendKey(string keys)
	RightClick(string selector,int child=0,double timeout=5)
	Append(string inputText,string selector,int child=0,double timeout=5)
	Write(string value, string selector, int child = 0, double timeout=5,string mode="overwrite")
	