# AutoGui

AutoGui is a GUI Automation/Test tool giving the user high level keywords to automate WPF and winform applications.

## Installing

Install using pip:  
`pip install autogui`

## Getting Started
I recommend using a spy tool such RecorderSpy.exe in the tools folder or my RecorderSpy repo. Use ctrl-r to start recording, ctrl-e to end recording, and ctrl-w to select a GUI element during recording. This generates both a python and robot script of your steps.  
Any other Windows Spy tool, such as Microsofts inspect.exe tool will help out in finding locator properties of elements. Most of the time you can use just the default selector(name/title) to find your element.


### Examples
```
from autogui import * 
open("calc")  
click("One")  
click("Two")  
close()  
```

```
from autogui import *  
open("notepad")  
write("My name is Alex Lundberg","Text Editor")
sendkey("{ENTER}")
append(" and this AutoGui","Text Editor")
print(read("Text Editor"))
close()  
```

```
from autogui import * 
open("calc")
print(getActiveWindow())
open("notepad")
print(getActiveWindow())
setWindow("calculator")
print(getActiveWindow())
click("One",0)  #clicks on the first element that matches title = "One"
#with selectors other than title you will need to use := with the property value to match
click("One,controltype:=button,id:=num1Button,class=Button")  
close("Untitled - Notepad")
close() #closes calculator window
'''

### Methods
click(id,child=0,timeout=timeout)  
write(value,id,child=0,timeout=timeout)  
setWindow(id,contains=True,timeout=timeout)  
append(value,id,child=0,timeout=timeout)  
rightclick(id,child=0,timeout=timeout)  
sendkey(key)  
read(id,child=0,timeout=gl.timeout)  
open(app,setActive=True)  
close(window="activeWindow")  
getActiveWindow()  

### Selectors
To select elements, try using any of the following:  
id  
name  
class  
controltype  
[Full list of available properties](https://docs.microsoft.com/en-us/dotnet/api/system.windows.automation.automationelement)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

	
	
	
	
	
