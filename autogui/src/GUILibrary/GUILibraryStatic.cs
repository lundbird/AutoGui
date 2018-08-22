using System;
using System.Collections.Generic;
using System.Windows.Forms;
using System.Drawing;
using System.Windows.Automation;
using static System.Windows.Automation.AutomationElement;
using System.Diagnostics;
using Microsoft.Test.Input;

namespace GUILibrary
{
    /// <summary>
    /// Contains high level user functions for GUI Automation. User inputs what window they want to perform GUI automation using setWindow(selector). 
    /// Then the user can use methods such as Click(selector),Write(text, selector),or Read(selector) to perform actions on control elements
    /// This class is essentially a wrapper on AutomationElement.FindAll(). GUIAutomation is performed via selector search, not pixel coordinates, and not tree heirachy.
    /// </summary>
    public static class GUILibraryClass
    {
        /// <summary>sets the default seconds to timeout if we cant find an element </summary>
        public const double timeout = 3;

        /// <summary>Contains the mappings of user selector strings to AutomationElement Property Conditions </summary>
        private static Dictionary<string, AutomationProperty> propertyMap = new Dictionary<string, AutomationProperty>(StringComparer.InvariantCultureIgnoreCase)
    {
        {"AutomationId",AutomationIdProperty},
        {"Id",AutomationIdProperty},
        {"Name",NameProperty},
        {"Title",NameProperty},
        {"Class",ClassNameProperty},
        {"ClassName",ClassNameProperty},
        {"AcceleratorKey",AcceleratorKeyProperty},
        {"AccessKey",AccessKeyProperty},
        {"BoundingRectangle",BoundingRectangleProperty},
        {"ClickablePoint",ClickablePointProperty},
        {"ControlType",ControlTypeProperty},
        {"Culture",CultureProperty},
        {"FrameworkId",FrameworkIdProperty},
        {"HasKeyboardFocus",HasKeyboardFocusProperty},
        {"HelpText",HelpTextProperty},
        {"IsContentElement",IsContentElementProperty},
        {"IsControlElement",IsControlElementProperty},
        {"IsDockPatternAvailable",IsDockPatternAvailableProperty},
        {"IsEnabled",IsEnabledProperty},
        {"IsExpandCollapsePatternAvailable",IsExpandCollapsePatternAvailableProperty},
        {"IsGridItemPatternAvailable",IsGridItemPatternAvailableProperty},
        {"IsGridPatternAvailable",IsGridPatternAvailableProperty},
        {"IsInvokePatternAvailable",IsInvokePatternAvailableProperty},
        {"IsItemContainerPatternAvailable",IsItemContainerPatternAvailableProperty},
        {"IsKeyboardFocusable",IsKeyboardFocusableProperty},
        {"IsMultipleViewPatternAvailable",IsMultipleViewPatternAvailableProperty},
        {"IsOffscreen",IsOffscreenProperty},
        {"IsPassword",IsPasswordProperty},
        {"IsRangeValuePatternAvailable",IsRangeValuePatternAvailableProperty},
        {"IsRequiredForForm",IsRequiredForFormProperty},
        {"IsScrollItemPatternAvailable",IsScrollItemPatternAvailableProperty},
        {"IsScrollPatternAvailable",IsScrollPatternAvailableProperty},
        {"IsSelectionItemPatternAvailable",IsSelectionItemPatternAvailableProperty},
        {"IsSelectionPatternAvailable",IsSelectionPatternAvailableProperty},
        {"IsSynchronizedInputPatternAvailable",IsSynchronizedInputPatternAvailableProperty},
        {"IsTableItemPatternAvailable",IsTableItemPatternAvailableProperty},
        {"IsTablePatternAvailable",IsTablePatternAvailableProperty},
        {"IsTextPatternAvailable",IsTextPatternAvailableProperty},
        {"IsTogglePatternAvailable",IsTogglePatternAvailableProperty},
        {"IsTransformPatternAvailable",IsTransformPatternAvailableProperty},
        {"IsValuePatternAvailable",IsValuePatternAvailableProperty},
        {"IsVirtualizedItemPatternAvailable",IsVirtualizedItemPatternAvailableProperty},
        {"IsWindowPatternAvailable",IsWindowPatternAvailableProperty},
        {"ItemStatus",ItemStatusProperty},
        {"ItemType",ItemTypeProperty},
        {"LabeledBy",LabeledByProperty},
        {"LocalizedControlType",LocalizedControlTypeProperty},
        {"ProcessId",ProcessIdProperty},
        {"NativeWindowHandle",NativeWindowHandleProperty},
        {"Orientation",OrientationProperty},
        {"RuntimeId",RuntimeIdProperty},
    };

        /// <summary>
        /// holds the active window for which gui automation actions are performed on
        /// </summary>
        private static AutomationElement activeWindow; 

        /// <summary>
        /// Returns the title of the activeWindow
        /// </summary>
        /// <returns></returns>
        public static string GetActiveWindow()
        {
            if (activeWindow == null)
            {
                activeWindow = RootElement;
            }
            return activeWindow.GetCurrentPropertyValue(NameProperty).ToString();
        }

        /// <summary>
        /// User method that Reads the text from the control of interest
        /// </summary>
        /// <param name="selector">user input selector string to parse in format property1:value1,property2:value2..</param>      
        /// <param name="child">AutomationElement for which to find the text of</param>
        /// <param name="timeout">time to search for the element before throwing an error </param>       
        public static string Read(string selector, int child = 0, double timeout = timeout)
        {
            ValidateInput(selector, " ", child, timeout);
            AutomationElement control = Search(selector, child);
            return getElementText(control);
        }

        /// <summary>
        /// Validates the Input on any function that is open to the end user.
        /// </summary>
        /// <param name="selector">user input selector string to parse in format property1:value1,property2:value2..</param>   
        ///<param name="inputText">users inputed text for write methods</param>        
        /// <param name="child">Allows the user to select which control to use if there are several matching input conditions</param>
        /// <param name="timeout">users entered timeout </param>  
        /// <param name="needsWindow">whether or not the action needs a window to operate</param>  
        private static void ValidateInput(string selector, string inputText, int child = 0, double timeout = timeout, Boolean needsWindow = true)
        {
            if (selector == null || selector == "")
            {
                throw new ArgumentException("selector string cannot be null or empty. Must be in format of property1:=value1,property2:=value2...");
            }
            if (inputText == null || inputText == "")
            {
                throw new ArgumentException("inputText cannot be null or empty");
            }
            if (child < 0 || child > 100)
            {
                throw new ArgumentException("Invalid child number: " + child);
            }
            if (timeout < 0 || timeout > 30)
            {
                throw new ArgumentException("invalid timeout: " + timeout + " is only valid between 0 and 30 seconds");
            }
            if (needsWindow)
            {
                if (activeWindow == null)
                {
                    throw new ArgumentException("No Active Window was selected. Use setWindow to set the window to run on");
                }

                activeWindow.SetFocus(); //sets the activewindow for users actions
            }
        }

        /// <summary>
        /// Helper method of Search that calls the AutomationElement.FindFirst or FindAll method which searches the tree for the matching element.
        /// </summary>
        /// <param name="contains">find window based on a partial title match.</param>
        /// <param name="window">selector for the window to perform ui automation actions on. Slower </param>
        /// <param name="timeout">time to search for the element before throwing an error </param>       
        /// <returns>AutomationElement if succesfull </returns>
        public static void setWindow(string window, Boolean contains = true, double timeout = timeout)
        {
            ValidateInput(window, " ", 0, timeout, false);
            activeWindow = RootElement;
            AutomationElement windowElement;

            if (contains) //do a search on a partial title match. Slightly Slower but basically just as fast
            {
                windowElement = SearchTopWindows(window, timeout);
            }
            else
            {
                windowElement = Search(window, 0, timeout);
            }

            windowElement.SetFocus();
            activeWindow = windowElement;
            Debug.WriteLine("active window was set to " + windowElement.GetCurrentPropertyValue(NameProperty));
        }

        /// <summary>
        /// Opens a process
        /// </summary>
        /// <param name="app">filepath of the app to launch. Inherits from users PATH variable</param>
        /// <param name="setActive">optionally choose to set the opened window to the activeWindow. set to false if the function cannot find the window</param>
        /// <param name="timeout">time to search for the active window before timing out</param>
        public static void Open(string app,Boolean setActive=true,double timeout=timeout) //automically tries to find the activeWindow, if it cant user must call with setActive=False;
        {
            Process process = new Process();
            process.StartInfo.FileName = app;
            try
            {
                process.Start();
            }
            catch (System.ComponentModel.Win32Exception)  //cannot find the file
            {
                throw new ArgumentException("Could not find an application with location " + app);
            }

            try
            {
                process.WaitForInputIdle();  //wait until the process opens and can accept input
            }
            catch (System.InvalidOperationException) { }  //if the app doesnt have a GUI we cant wait for input idle

            if (setActive) //if user chose to setActive then we try to find the process that contains the process name
            {
                setWindow(process.ProcessName,true,timeout); //sometimes the original process dies and spawns a new one with a similar title so we do a search with contains.
            }
        }
        /// <summary>
        /// Closes the process that is the active window
        /// </summary>
        /// <param name="window">select the process to kill by passing its title</param>
        public static void Close(string window = "activeWindow") 
        {
            string killProcessTitle;
            if (window == "activeWindow")
            {
                if (activeWindow == null)
                {
                    throw new NullReferenceException("No active application was set to close ");
                }

                //set the process to kill to be the currently active window
                killProcessTitle = activeWindow.GetCurrentPropertyValue(NameProperty).ToString(); ;
            }
            else
            {
                killProcessTitle = window;
            }

            foreach (Process proc in Process.GetProcesses())
            {
                if (proc.MainWindowTitle==killProcessTitle) //must be an exact match for safety.
                {
                    Debug.WriteLine("Successfully closed process with title: " + proc.MainWindowTitle);
                    proc.Kill();
                    return;
                }
            }
            //if we cannot find the window we do not throw an exception.
            Console.WriteLine("Unable to find a process with a title " + activeWindow.GetCurrentPropertyValue(NameProperty).ToString() + " to kill ");
        }

        /// <summary>
        /// finds a match if the window of interest contains a string. Useful if you dont know the full title of the application until runtime
        /// </summary>
        /// <param name="window">the partial window title to search for</param>
        /// <param name="timeout">time to search before timing out</param>
        /// <returns></returns>
        private static AutomationElement SearchTopWindows(string window, double timeout=timeout)
        {
            Stopwatch searchTime = new Stopwatch();
            searchTime.Start();
            while (searchTime.Elapsed.Seconds < timeout)
            {
                // Use ControlViewCondition to retrieve all control elements then manually search each one.
                AutomationElementCollection elementCollectionControl = RootElement.FindAll(TreeScope.Children, Automation.ControlViewCondition);
                foreach (AutomationElement autoElement in elementCollectionControl)
                {
                    string searchString = autoElement.GetCurrentPropertyValue(NameProperty).ToString();

                    //we have to manually check each element to see if the elements value or text is what we want
                    if (searchString.IndexOf(window,StringComparison.OrdinalIgnoreCase)>=0 && (bool)autoElement.GetCurrentPropertyValue(IsEnabledProperty))
                    {
                        Debug.WriteLine("Found the title : " + searchString);
                        searchTime.Stop();
                        return autoElement;
                    }
                }
            }
            throw new ElementNotAvailableException("Could not find element with partial title: " + window);
        }


        /// <summary>                
        /// Performs the search of the element by adding conditions based on the parsed conditions then calling FindWithTimeout
        /// </summary>
        /// <param name="selector">user input selector string to parse in format property1:value1,property2:value2..</param>    
        /// <param name="child">Allows the user to select which control to use if there are several matching input conditions</param>
        /// <param name="timeout">time to search for the element before throwing an error</param>
        /// <returns>AutomationElement if succesfull </returns>
        private static AutomationElement Search(string selector, int child = 0, double timeout = timeout)
        {

            List<Condition> conditionList = new List<Condition>();  //contains the list of conditions that we will search with
            Dictionary<string, string> valueParameter = new Dictionary<string, string>();  //used if the user does a search based on value

            //if user chooses to search by value then we search by value only. This is to keep code simple
            if (selector.Contains("value"))
            {
                Debug.WriteLine("Doing a search by value. Ignoring other conditions in input selector");
                return FindByValue(selector, timeout);
            }

            Dictionary<AutomationProperty, string> searchParameters = ParseSelector(selector); //parse users input

            //Add all the parameters returned from the parsing into our list of conditions
            foreach (KeyValuePair<AutomationProperty, string> entry in searchParameters)
            {
                conditionList.Add(new PropertyCondition(entry.Key, entry.Value));
            }

            Debug.WriteLine("Condition List contains: " + conditionList.ToString());

            conditionList.Add(Automation.ControlViewCondition);  //only view control elements

            Condition[] conditionsArray = conditionList.ToArray(); //needs to be converted to array to be fed to AutomationElement.FindAll()
            Condition searchConditions = new AndCondition(conditionsArray);

            return FindWithTimeout(selector, searchConditions, child, timeout);

        }

        /// <summary>
        /// Helper method of Search that calls the AutomationElement.FindFirst or FindAll method which searches the tree for the matching element.
        /// Uses a while loop with timeout to wait for element if it is not present or enabled.
        /// </summary>
        /// <param name="selector">user input selector string to parse in format property1:value1,property2:value2..</param>
        /// <param name="searchCondition">AutomationElement for which to find the text of</param>
        /// <param name="child">Allows the user to select which control to use if there are several matching input conditions</param>
        /// <param name="timeout">time to search for the element before throwing an error</param>   
        /// <returns>AutomationElement if succesfull </returns>
        private static AutomationElement FindWithTimeout(string selector, Condition searchConditions, int child = 0, double timeout = 5)
        {
            AutomationElement searchElement = null;

            Stopwatch searchTime = new Stopwatch();
            searchTime.Start();
            Debug.WriteLine("Begining the search for " + selector + " with child: " + child + "and timeout: " + timeout);

            while (searchTime.Elapsed.Seconds < timeout)
            {
                try
                {
                    if (child == 0) //if the user chose to just search for the first element we can use the faster FindFirst rather than FindAll()
                    {
                        if (activeWindow == RootElement)  //if the activeWindow hasnt been set yet then we can only search in the children scope or risk stack overflow
                        {
                            searchElement = activeWindow.FindFirst(TreeScope.Children, searchConditions);  //set to descendants temporarily for calculator bug
                        }
                        else
                        {
                            searchElement = activeWindow.FindFirst(TreeScope.Descendants, searchConditions);
                        }
                    }
                    else
                    {
                        AutomationElementCollection elements = activeWindow.FindAll(TreeScope.Descendants, searchConditions);
                        if (child > elements.Count)
                        {
                            throw new IndexOutOfRangeException("Only " + elements.Count + " elements meeting the conditions exist. You chose to select element: " + child);
                        }
                        searchElement = elements[child];
                    }

                    if (searchElement != null && (bool)searchElement.GetCurrentPropertyValue(IsEnabledProperty)) //if we were successfull and the element is active we return
                    {
                        Debug.WriteLine("AutomationElement was found");
                        searchTime.Stop();
                        if (activeWindow == RootElement)  //avoids bug where a subwindow with the same name is set as active window
                        {
                            return searchElement;
                        }

                        return CheckChildren(searchElement, searchConditions); //checks if we have an inner element with the same selector
                    }
                }catch (ElementNotAvailableException) { } //sometimes the Find() method throws an elementNotAvailable exception.
            }

            searchTime.Stop();

            //in case we couldnt successfully get a value we exit the program.
            if (searchElement == null)
            {
                throw new ElementNotAvailableException("Cound not find element: " + selector + " in window " + activeWindow.GetCurrentPropertyValue(NameProperty) + " in " + timeout + " seconds");
            }
            else
            {
                throw new ElementNotAvailableException("Element was found but not enabled: " + selector + " in " + timeout + " seconds");
            }
        }



        /// <summary>
        ///Checks if there is an inner element that meets the conditions as often clickable elements are hidden under controls with the same titles.
        /// </summary>
        /// <param name="searchCondition">search conditions to use in AutomationElement.FindFirst()</param>
        /// <param name="activeParent">the current parent in the recursive search</param>   
        /// <returns>the child AutomationElement if available and the parent if not.</returns>
        private static AutomationElement CheckChildren(AutomationElement parent, Condition searchConditions)
        {
            AutomationElement searchElement = null;
            searchElement = parent.FindFirst(TreeScope.Children, searchConditions); //only search in the direct children.
            if (searchElement == null)
            {
                return parent;
            }
            Debug.WriteLine("A child element was found with the same selector.");
            return searchElement;
        }

        /// <summary>
        /// Helper method of search() that finds an element if the user wants to select by value. 
        /// </summary>
        /// <param name="selector">user input selector string to parse in format property1:value1,property2:value2..</param>
        /// <param name="timeout">time to search before timing out</param>
        /// <returns>automation element if successfull</returns>
        private static AutomationElement FindByValue(string selector, double timeout)
        {
            int firstIndex = selector.IndexOf(":=") + 2;  //I ignore all other user input if the user wants to search by value
            string controlValue = selector.Substring(firstIndex, selector.Length - firstIndex);

            Stopwatch searchTime = new Stopwatch();
            searchTime.Start();
            while (searchTime.Elapsed.Seconds < timeout)
            {
                // Use ControlViewCondition to retrieve all control elements then manually search each one.
                AutomationElementCollection elementCollectionControl = activeWindow.FindAll(TreeScope.Subtree, Automation.ControlViewCondition);
                foreach (AutomationElement autoElement in elementCollectionControl)
                {
                    //we have to manually check each element to see if the elements value or text is what we want
                    if (getElementText(autoElement) == controlValue && (bool)autoElement.GetCurrentPropertyValue(IsEnabledProperty))
                    {
                        Debug.WriteLine("Found the element using a search by value");
                        searchTime.Stop();
                        return autoElement;
                    }
                }
            }
            //if unsucessfull then throw error
            searchTime.Stop();
            throw new ElementNotAvailableException("Could not find an element with value: " + controlValue + " in window " + activeWindow.GetCurrentPropertyValue(NameProperty));
        }


        /// <summary>
        /// Helper method of FindByValue() and Read() that returns the value or text of the element depending on which is present
        /// </summary>
        /// <param name="element">AutomationElement for which to find the text of</param>
        private static string getElementText(AutomationElement element)
        {
            var hasValue = (bool)element.GetCurrentPropertyValue(IsValuePatternAvailableProperty);
            var hasText = (bool)element.GetCurrentPropertyValue(IsTextPatternAvailableProperty);

            //elements usually only have either a text pattern or a value pattern so we check for both
            if (hasValue)
            {
                ValuePattern valuePattern = (ValuePattern)element.GetCurrentPattern(ValuePattern.Pattern);
                Debug.WriteLine("element is a value pattern element");
                return valuePattern.Current.Value;
            }
            else if (hasText)
            {
                TextPattern textPattern = (TextPattern)element.GetCurrentPattern(ValuePattern.Pattern);
                Debug.WriteLine("element is a text pattern element");
                return textPattern.DocumentRange.GetText(-1).TrimEnd('\r'); // often there is an extra '\r' hanging off the end.
            }

            return null;
        }

        /// <summary>
        /// Helper method of Search() that parses the users input string and matches it with the properties in propertyMap dictionary.
        /// </summary>
        /// <param name="selector">user input selector string to parse in format property1:value1,property2:value2..</param>
        /// <returns>Dictionary giving the AutomationProperty with the corresponding value</returns>
        private static Dictionary<AutomationProperty, string> ParseSelector(string selector)
        {
            Dictionary<AutomationProperty, string> selectorDict = new Dictionary<AutomationProperty, string>(); //contains selectors with their values
            string[] separator = { ":=" };

            string[] props = selector.Split(',');
            foreach (string prop in props)
            {
                //split the property with values the user entered on the :=
                string[] propWithValues = prop.Split(separator, System.StringSplitOptions.RemoveEmptyEntries);

                //if we cannot split the string then we assume that the user meant to use the name property
                if (propWithValues.Length == 1)
                {
                    Debug.WriteLine("User only entered one parameter for which to search, assuming text property");
                    selectorDict.Add(NameProperty, propWithValues[0]);
                    return selectorDict;
                }

                if (propertyMap.ContainsKey(propWithValues[0])) //make sure the users entered key exists in our dictionary
                {
                    AutomationProperty Automationprop = propertyMap[propWithValues[0]]; //map the string name to the AutomationProperty
                    selectorDict.Add(Automationprop, propWithValues[1]);
                    Debug.WriteLine("Added " + propWithValues[1] + " to property " + propWithValues[0] + " for search conditions");
                }
                else //if not we just skip the property and move on to the next.
                {
                    Debug.WriteLine("property: " + propWithValues[0] + " Does not exist in Dictionary. Skipping it");   
                }
            }
            return selectorDict;
        }

        ///--------------------------------------------------------------------
        /// <summary>
        /// Clicks on the control of interest.
        /// </summary>
        /// <param name="selector">user input selector string to parse in format property1:value1,property2:value2..</param>
        /// <param name="child">Allows the user to select which control to use if there are several matching input conditions</param>
        /// <param name="timeout">time to search before timing out</param>
        ///--------------------------------------------------
        public static void Click(string selector, int child = 0, double timeout = timeout)
        {
            ValidateInput(selector, " ", child, timeout);

            AutomationElement control = Search(selector, child, timeout); //get the control of interest

            //we check if object is invokable since this is a faster way to click than moving our mouse to the control
            var isInvokable = (bool)control.GetCurrentPropertyValue(IsInvokePatternAvailableProperty);
            if (isInvokable)
            {
                Debug.WriteLine("the automation element was invokable. Now Clicking element");
                var invokePattern = control.GetCurrentPattern(InvokePattern.Pattern) as InvokePattern;
                invokePattern.Invoke();
            }
            else
            {
                //click manually by moving mouse and clicking left mouse button
                Debug.WriteLine("the automation element was NOT invokable. Manually moving mouse over and clicking");
                Point p = control.GetClickablePoint();
                Mouse.MoveTo(p);
                Mouse.Click(MouseButton.Left);
            }
        }

        ///--------------------------------------------------------------------
        /// <summary>
        /// Sends the keyboard keys
        /// </summary>
        /// <param name="keys">available keys here:"https://msdn.microsoft.com/en-us/library/system.windows.forms.sendkeys(v=vs.110).aspx" </param>
        ///--------------------------------------------------
        public static void SendKey(string keys)
        {
            activeWindow.SetFocus();
            SendKeys.SendWait(keys);
        }

        ///---------------------------------------------------------------------
        /// <summary>
        /// Right Clicks the Control
        /// </summary>
        /// <param name="selector">user input selector string to parse in format property1:value1,property2:value2..</param>
        /// <param name="child">selector to find the text control</param>
        /// <param name="timeout">time to search before timing out</param>
        ///--------------------------------------------------------------------
        public static void RightClick(string selector, int child = 0, double timeout = timeout)
        {
            ValidateInput(selector, " ", child, timeout);

            AutomationElement control = Search(selector, child, timeout);

            //we cannot invoke on a right click so we move our mouse over and click
            Point p = control.GetClickablePoint();
            Mouse.MoveTo(p);
            Mouse.Click(MouseButton.Right);
        }


        ///--------------------------------------------------------------------
        /// <summary>
        /// Appends string into each text control of interest.
        /// </summary>
        /// <param name="value">String to be inserted</param>
        /// <param name="selector">user input selector string to parse in format property1:value1,property2:value2..</param>
        /// <param name="timeout">time to search before timing out</param>
        /// <param name="mode">whether or not to overwrite the text in the control</param>
        ///--------------------------------------------------------------------
        public static void Append(string inputText, string selector, int child = 0, double timeout = timeout)
        {
            ValidateInput(selector, inputText, child, timeout);
            Write(inputText, selector, child, timeout, "Append"); //uses the Write method but does not delete the text before insertion
        }

        ///--------------------------------------------------------------------
        /// <summary>
        /// Inserts a string into each text control of interest.
        /// </summary>
        /// <param name="value">String to be inserted</param>
        /// <param name="selector">user input selector string to parse in format property1:value1,property2:value2..</param>
        /// <param name="timeout">time to search before timing out</param>
        /// <param name="mode">whether or not to overwrite the text in the control</param>
        ///--------------------------------------------------------------------
        public static void Write(string value, string selector, int child = 0, double timeout = timeout, string mode = "overwrite")
        {
            ValidateInput(value, selector, child, timeout);

            AutomationElement element = Search(selector, child);  //finds the element to write to

            if (mode != "overwrite" && mode != "Append")
            {
                throw new ArgumentException("Invalid argument for write mode. Use mode=overwrite or mode=Append");
            }

            // Are there styles that prohibit us from sending text to this control?
            if (!element.Current.IsKeyboardFocusable)
            {
                throw new ElementNotEnabledException("The control with an AutomationID of " + element.Current.AutomationId.ToString() + "is read-only.\n\n");
            }

            object valuePattern = null;

            //if the element does not support value pattern or we are in append mode we must change value by sending keys
            if (!element.TryGetCurrentPattern(ValuePattern.Pattern, out valuePattern) || mode == "Append")
            {
                Debug.WriteLine("The control does not support ValuePattern. Using keyboard input.\n");

                element.SetFocus();

                if (mode == "overwrite")
                {
                    //Delete existing content in the control
                    SendKeys.SendWait("^{HOME}");   // Move to start of control
                    SendKeys.SendWait("^+{END}");   // Select everything
                    SendKeys.SendWait("{DEL}");     // Delete selection
                }

                //insert new content.
                SendKeys.SendWait("{END}");
                SendKeys.SendWait(value);
            }
            // Control supports the ValuePattern pattern so we can use the SetValue method to insert content which is faster
            else
            {
                Debug.WriteLine("The control with supports ValuePattern. Using ValuePattern.SetValue().\n");

                element.SetFocus();

                //despite checking that the element was enabled in Search(), sometimes we get an exception on setting the value
                try
                {
                    ((ValuePattern)valuePattern).SetValue(value); //sets the value
                }
                catch (ElementNotAvailableException)
                {
                    SendKeys.SendWait("^{HOME}");   // Move to start of control
                    SendKeys.SendWait("^+{END}");   // Select everything
                    SendKeys.SendWait("{DEL}");     // Delete selection
                    SendKeys.SendWait(value);
                }
            }
        }
    }
}