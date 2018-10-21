This file was written by richard.boettcher@sandc.com, let me know if you have any questions I can answer.
### How do I get set up? ###

This was Built using VS 2017 pro.
Language: C#
It produces a GUILibrary.dll which is wrapped with a Python pip install for easy GUI manipulation using Robot FrameWork. 

### Summary of set up and Build ###
- Clone the GIT
- Load \autogui\src\GUILibrary.sln in VS
- Make sure the following References are loaded:
- Interoop.UIAutomationClient
- System
- System.Drawing
- System.Windows.Forms
- TestApiCore
- UIAComWrapper
- WindowsBase

Right Click GUILibrary and Select Build

- OUTPUT:
- 1>------ Build started: Project: GUILibrary, Configuration: Release Any CPU ------
- 1>  GUILibrary -> C:\GITwork\AutoGui\autogui\src\GUILibrary\bin\Release\GUILibrary.dll
- ========== Build: 1 succeeded, 0 failed, 0 up-to-date, 0 skipped ==========

TODO: Integrate this into a Buildserver and have it auto build the dll, place files in the right location to auto integrate with https://pypi.org/project/autogui/, to include version number updates.



Currently SimpleGuiTester and ConsolApp1 are broken, I'm not exactly sure what is going on there, perhaps Alex Lundbird can provide some insight.

* Configuration
* Dependencies
* Database configuration
* How to run tests
* Deployment instructions

### Contribution guidelines ###

* Writing tests
* Code review
* Other guidelines
