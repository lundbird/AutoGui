using System;
using System.Collections.Generic;
using System.Windows.Forms;
using System.Drawing;
using System.Windows.Automation;
using static System.Windows.Automation.AutomationElement;
using System.Threading;
using System.Diagnostics;
using Microsoft.Test.Input;
using System.Text.RegularExpressions;

namespace GUILibrary
{
    //TODO. keep searching if there are child elements that are hidden by parents like in pluralsight course.
    //TODO. Validate if actions on a control are succesfull.
    //TODO. Unit testing :(
    /// <summary>
    /// Contains high level user functions for GUI Automation. User inputs what window they want to perform GUI automation using setWindow(selector). 
    /// Then the user can use methods such as Click(selector),Write(text, selector),or Read(selector) to perform actions on control elements
    /// This class is essentially a wrapper on AutomationElement.FindAll(). GUIAutomation is performed via selector search, not pixel coordinates, and not tree heirachy.
    /// </summary>
    public static class GUILibraryClass
    {
        /// <summary>
        /// Contains the mappings of user selector strings to AutomationElement Property Conditions 
        /// </summary>
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
        private static AutomationElement activeWindow { get; set; }

        /// <summary>
        /// User method that Reads the text from the control of interest
        /// </summary>
        /// <param name="selector">AutomationElement for which to find the text of</param>        
        /// <param name="child">AutomationElement for which to find the text of</param>
        /// <param name="timeout">time to search for the element before throwing an error </param>       
        public static string Read(string selector, int child = 0, double timeout = 5)
        {
            ValidateInput(selector, "", child,timeout);
            AutomationElement control = Search(selector, child);
            return getElementText(control);
        }

        /// <summary>
        /// Validates the Input on any function that is open to the end user.
        /// </summary>
        /// <param name="selector">users inputed selector. Validation is minimal and currently only checks for null input</param>        
        ///<param name="inputText">users inputed text for write methods</param>        
        /// <param name="child">users entered child parameter</param>
        /// <param name="timeout">users entered timeout </param>    
        private static void ValidateInput(string selector, string inputText, int child=0,double timeout=5)
        {
            if (selector == null)
            {
                throw new ArgumentException("selector string cannot be null. Must be in format of property1:value1,property2:value2...");
            }
            if (inputText == null)
            {
                throw new ArgumentException("inputText cannot be null");
            }
            if (child<0)
            {
                throw new ArgumentException("Invalid child number: " + child);
            }
            if (timeout<0 || timeout > 30)
            {
                throw new ArgumentException("invalid timeout: " + timeout + " is only valid between 0 and 30 seconds");
            }
        }

        /// <summary>
        /// Helper method of Search that calls the AutomationElement.FindFirst or FindAll method which searches the tree for the matching element.
        /// </summary>
        /// <param name="window">selector for the window to perform ui automtion actions on</param>
        /// <param name="timeout">time to search for the element before throwing an error </param>       
        /// <returns>AutomationElement if succesfull </returns>
        public static void setWindow(string window,double timeout=5)
        {
            ValidateInput(window,"",0, timeout);
            activeWindow = RootElement;
            AutomationElement windowElement = Search(window, 0, timeout);
            windowElement.SetFocus();
            activeWindow = windowElement;
        }


        /// <summary>                
        /// Performs the search of the element by adding conditions based on the parsed conditions then calling FindWithTimeout
        /// </summary>
        /// <param name="selector">AutomationElement for which to find the text of</param>        
        /// <param name="child">AutomationElement for which to find the text of</param>
        /// <param name="timeout">time to search for the element before throwing an error</param>
        /// <returns>AutomationElement if succesfull </returns>
        private static AutomationElement Search(string selector, int child = 0, double timeout=5)
        {

            List<PropertyCondition> conditionList = new List<PropertyCondition>();  //contains the list of conditions that we will search with
            Dictionary<string, string> valueParameter = new Dictionary<string, string>();  //used if the user does a search based on value

            //if user chooses to search by value then we search by value only. This is to keep code simple
            if (selector.Contains("value"))
            {
                return FindByValue(selector,timeout);
            }

            Dictionary<AutomationProperty, string> searchParameters = ParseSelector(selector); //parse users input
            
            //Add all the parameters returned from the parsing into our list of conditions
            foreach (KeyValuePair<AutomationProperty, string> entry in searchParameters)
            {
                conditionList.Add(new PropertyCondition(entry.Key, entry.Value));
            }

            Condition[] conditionsArray = conditionList.ToArray(); //needs to be converted to array to be fed to AutomationElement.FindAll()
            Condition searchConditions = new AndCondition(conditionsArray);

            return FindWithTimeout(selector, searchConditions, child, timeout);

        }

        /// <summary>
        /// Helper method of Search that calls the AutomationElement.FindFirst or FindAll method which searches the tree for the matching element.
        /// Uses a while loop with timeout to wait for element if it is not present or enabled.
        /// </summary>
        /// <param name="selector">AutomationElement for which to find the text of</param>
        /// <param name="searchCondition">AutomationElement for which to find the text of</param>
        /// <param name="child">AutomationElement for which to find the text of</param>
        /// <param name="timeout">time to search for the element before throwing an error</param>   
        /// <returns>AutomationElement if succesfull </returns>
        private static AutomationElement FindWithTimeout(string selector, Condition searchConditions, int child = 0, double timeout = 5)
        {
            AutomationElement searchElement = null;

            Stopwatch searchTime = new Stopwatch();
            searchTime.Start();
            while (searchTime.Elapsed.Seconds < timeout)
            {
                try
                {
                    if (child == 0) //if the user chose to just search for the first element we can use the faster FindFirst rather than FindAll()
                    {
                        if (activeWindow == RootElement)  //if the activeWindow hasnt been set yet then we can only search in the children scope or risk stack overflow
                        {
                            searchElement = activeWindow.FindFirst(TreeScope.Children, searchConditions);
                        }
                        else
                        {
                            searchElement = activeWindow.FindFirst(TreeScope.Descendants, searchConditions);
                        }
                    }
                    else
                    {
                        searchElement = activeWindow.FindAll(TreeScope.Descendants, searchConditions)[child];
                    }

                    if (searchElement != null && (bool)searchElement.GetCurrentPropertyValue(IsEnabledProperty)) //if we were successfull and the element is active we return
                    {
                        searchTime.Stop();
                        return searchElement;
                    }
                }
                catch (NullReferenceException) //null reference is thrown each time Find() cannot find the element.
                {
                }
            }
            searchTime.Stop();

            //in case we couldnt successfully get a value we throw an exception.
            if (searchElement == null)
            {
                throw new ElementNotAvailableException("Cound not find element: " + selector + " in " + activeWindow + " in " + timeout + " seconds");
            }
            else
            {
                throw new ElementNotAvailableException("Element was found but not enabled: " + selector + " in " + activeWindow + " in " + timeout + " seconds");
            }

        }

        /// <summary>
        /// Helper method of search() that finds an element if the user wants to select by value. 
        /// </summary>
        /// <param name="selector">property1:value1,property2:value2...</param>
        /// <param name="timeout">time to search before timing out</param>
        /// <returns>automation element if successfull</returns>
        private static AutomationElement FindByValue(string selector,double timeout)
        {
            int firstIndex = selector.IndexOf(":") + 1;  //I ignore all other user input if the user wants to search by value
            string controlValue = selector.Substring(firstIndex, selector.Length - firstIndex); 

            Stopwatch searchTime = new Stopwatch();
            searchTime.Start();
            while (searchTime.Elapsed.Seconds < timeout)
            {
                try
                {
                    // Use ControlViewCondition to retrieve all control elements then manually search each one.
                    AutomationElementCollection elementCollectionControl = activeWindow.FindAll(TreeScope.Subtree, Automation.ControlViewCondition);
                    foreach (AutomationElement autoElement in elementCollectionControl)
                    {
                        if (getElementText(autoElement) == controlValue) //we have to manually check each element to see if the elements value or text is what we want
                        {
                            searchTime.Stop();
                            return autoElement;
                        }
                    }
                }catch (NullReferenceException) { }
            }
            //if unsucessfull then throw error
            searchTime.Stop();
            throw new ElementNotAvailableException("Could not find an element with value: " + controlValue);
        }


        /// <summary>
        /// Helper method of FindByValue() and Read() that returns the value or text of the element depending on which is presend
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
                return valuePattern.Current.Value;
            }
            else if (hasText)
            {
                TextPattern textPattern = (TextPattern)element.GetCurrentPattern(ValuePattern.Pattern);
                return textPattern.DocumentRange.GetText(-1).TrimEnd('\r'); // often there is an extra '\r' hanging off the end.
            }

            return null;
        }

        /// <summary>
        /// Helper method of Search() that parses the users input string and matches it with the properties in propertyMap dictionary.
        /// </summary>
        /// <param name="selector">user input selector string to parse</param>
        /// <returns>Dictionary giving the AutomationProperty with the corresponding value</returns>
        private static Dictionary<AutomationProperty, string> ParseSelector(string selector)
        {
            Dictionary<AutomationProperty, string> selectorDict = new Dictionary<AutomationProperty, string>(); //contains selectors with their values
            string[] props = selector.Split(',');
            foreach (string prop in props)
            {
                string[] propWithValues = prop.Split(':'); //split the property with values the user entered on the :

                //if we cannot split the string then we assume that the user meant to use the name property
                if (propWithValues.Length == 1)
                {
                    selectorDict.Add(NameProperty, propWithValues[0]);
                    return selectorDict;
                }

                AutomationProperty Automationprop = propertyMap[propWithValues[0]]; //map the string name to the AutomationProperty
                selectorDict.Add(Automationprop, propWithValues[1]);
                System.Diagnostics.Debug.WriteLine(propWithValues[1]);
            }
            return selectorDict;
        }

        ///--------------------------------------------------------------------
        /// <summary>
        /// Clicks on the control of interest.
        /// </summary>
        /// <param name="selector">expression to match a control.</param>
        /// <param name="child">Which child to choose if multiple controls are chosen</param>
        /// <param name="timeout">time to search before timing out</param>
        ///--------------------------------------------------
        public static void Click(string selector, int child = 0,double timeout=5)
        {
            ValidateInput(selector,"",child, timeout);

            AutomationElement control = Search(selector, child,timeout); //get the control of interest

            //we check if object is invokable since this is a faster way to click than moving our mouse to the control
            var isInvokable = (bool)control.GetCurrentPropertyValue(IsInvokePatternAvailableProperty);
            if (isInvokable)
            {
                var invokePattern = control.GetCurrentPattern(InvokePattern.Pattern) as InvokePattern;
                invokePattern.Invoke();
            }
            else
            {
                //click manually by moving mouse and clicking left mouse button
                System.Drawing.Point p = control.GetClickablePoint();
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
            SendKeys.SendWait(keys);
        }

        ///---------------------------------------------------------------------
        /// <summary>
        /// Right Clicks the Control
        /// </summary>
        /// <param name="selector">selector string to search for control. format is in </param>
        /// <param name="child">selector to find the text control</param>
        /// <param name="timeout">time to search before timing out</param>
        ///--------------------------------------------------------------------
        public static void RightClick(string selector,int child=0,double timeout=5)
        {
            ValidateInput(selector,"",child, timeout);

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
        /// <param name="selector">selector to find the text control</param>
        /// <param name="timeout">time to search before timing out</param>
        /// <param name="mode">whether or not to overwrite the text in the control</param>
        ///--------------------------------------------------------------------
        public static void Append(string inputText,string selector,int child=0,double timeout=5)
        {
            ValidateInput(selector, inputText, child, timeout);
            Write(inputText, selector, child, timeout, "Append"); //uses the Write method but does not delete the text before insertion
        }

        ///--------------------------------------------------------------------
        /// <summary>
        /// Inserts a string into each text control of interest.
        /// </summary>
        /// <param name="value">String to be inserted</param>
        /// <param name="selector">selector to find the text control</param>
        /// <param name="timeout">time to search before timing out</param>
        /// <param name="mode">whether or not to overwrite the text in the control</param>
        ///--------------------------------------------------------------------
        public static void Write(string value, string selector, int child = 0, double timeout=5,string mode="overwrite")
        {
            AutomationElement element = Search(selector, child);  //finds the element to write to

            ValidateInput(value, selector, child, timeout);
            if (mode!="overwrite" && mode != "Append")
            {
                throw new ArgumentException("Invalid argument for write mode. Use mode=overwrite or mode=Append");
            }

                // A series of basic checks prior to attempting an insertion.
                //
                // Check #1: Is control enabled?
                // An alternative to testing for static or read-only controls 
                // is to filter using 
                // PropertyCondition(AutomationElement.IsEnabledProperty, true) 
                // and exclude all read-only text controls from the collection.
                if (!element.Current.IsEnabled)
                {
                    throw new InvalidOperationException(
                        "The control with an AutomationID of "
                        + element.Current.AutomationId.ToString()
                        + " is not enabled.\n\n");
                }

                // Check #2: Are there styles that prohibit us 
                //           from sending text to this control?
                if (!element.Current.IsKeyboardFocusable)
                {
                    throw new InvalidOperationException(
                        "The control with an AutomationID of "
                        + element.Current.AutomationId.ToString()
                        + "is read-only.\n\n");
                }


                // Once you have an instance of an AutomationElement,  
                // check if it supports the ValuePattern pattern.
                object valuePattern = null;

                // Control does not support the ValuePattern pattern 
                // so use keyboard input to insert content.
                //
                // NOTE: Elements that support TextPattern 
                //       do not support ValuePattern and TextPattern
                //       does not support setting the text of 
                //       multi-line edit or document controls.
                //       For this reason, text input must be simulated
                //       using one of the following methods.
                //       
                if (!element.TryGetCurrentPattern(
                    ValuePattern.Pattern, out valuePattern))
                {
                    Debug.WriteLine("The control with an AutomationID of ");
                    Debug.Write(element.Current.AutomationId.ToString());
                    Debug.Write(" does not support ValuePattern.");
                    Debug.Write(" Using keyboard input.\n");

                    // Set focus for input functionality and begin.
                    element.SetFocus();

                    // Pause before sending keyboard input.
                    Thread.Sleep(100);

                    if (mode == "overwrite")
                    {
                        //Delete existing content in the control
                        SendKeys.SendWait("^{HOME}");   // Move to start of control
                        SendKeys.SendWait("^+{END}");   // Select everything
                        SendKeys.SendWait("{DEL}");     // Delete selection
                    }

                    //insert new content.
                    SendKeys.SendWait(value);
                }
                // Control supports the ValuePattern pattern so we can 
                // use the SetValue method to insert content.
                else
                {
                    Debug.WriteLine("The control with an AutomationID of ");
                    Debug.Write(element.Current.AutomationId.ToString());
                    Debug.Write((" supports ValuePattern."));
                    Debug.Write(" Using ValuePattern.SetValue().\n");

                    // Set focus for input functionality and begin.
                    element.SetFocus();

                    ((ValuePattern)valuePattern).SetValue(value); //sets the value
                }
        }
    }
}
