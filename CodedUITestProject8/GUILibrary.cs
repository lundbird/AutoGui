using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using System.Windows.Input;
using System.Windows.Forms;
using System.Drawing;
using Keyboard = Microsoft.VisualStudio.TestTools.UITesting.Keyboard;
using Mouse = Microsoft.VisualStudio.TestTools.UITesting.Mouse;
using System.Windows.Automation;
using static System.Windows.Automation.AutomationElement;
using System.Threading;
using RGiesecke.DllExport;
using System.Runtime.InteropServices;

internal class GUILibrary
{
    //TODO allow selection by event properties.
    /*
{"AsyncContentLoadedEvent",AsyncContentLoadedEvent},
{"AutomationFocusChangedEvent",AutomationFocusChangedEvent},
{"AutomationChangedEvent",AutomationPropertyChangedEvent},
{"MenuClosedEvent",MenuClosedEvent},
{"MenuOpenedEvent",MenuOpenedEvent},
{"LayoutInvalidatedEvent",LayoutInvalidatedEvent},
{"NotSupported",NotSupported},
{"StructureChangedEvent",StructureChangedEvent},
{"ToolTipClosedEvent",ToolTipClosedEvent},
{"ToolTipOpenedEvent",ToolTipOpenedEvent},
*/
    //TODO get element by value
    private static Dictionary<string, AutomationProperty> propertyMap = new Dictionary<string, AutomationProperty>()
    {
        {"AutomationId",AutomationIdProperty},
        {"Id",AutomationIdProperty},
        {"Name",NameProperty},
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

    private AutomationElement activeWindow;

    public GUILibrary()
    {
    }

    [DllExport("setWindow", CallingConvention = CallingConvention.Cdecl)]
    public void setWindow(string window)
    {
        //finds the window by regular expression - NEEDS MORE TESTING.
        //var windowMatch = TopLevelWindowUtils.FindWindow(wh => wh.GetWindowText().Contains(window));
        //Condition apptitle = new PropertyCondition(NameProperty, windowMatch.GetWindowText());

        //finds the window, sets focus and makes it the users active window.
        Condition apptitle = new PropertyCondition(NameProperty, window);
        AutomationElement activeWindow = RootElement.FindFirst(TreeScope.Children, apptitle);
        activeWindow.SetFocus();
        this.activeWindow = activeWindow;
    }

    private AutomationElement search(string selector, int child = 0)
    {
        //if user chooses to search by value then we search by value only. This is to keep code simple
        if (selector.Contains("value"))
        {
            return FindByValue(selector);
        }

        List<PropertyCondition> conditionList = new List<PropertyCondition>();
        Dictionary<string, string> valueParameter = new Dictionary<string, string>();

        Dictionary<AutomationProperty, string> searchParameters = ParseSelector(selector);
        foreach (KeyValuePair<AutomationProperty, string> entry in searchParameters)
        {
            conditionList.Add(new PropertyCondition(entry.Key, entry.Value));
        }

        Condition[] conditionsArray = conditionList.ToArray();
        Condition searchConditions = new AndCondition(conditionsArray);

        return activeWindow.FindAll(TreeScope.Descendants, searchConditions)[child];
    }

    /// <summary>
    /// Helper method of search() that finds an element if the user wants to select by value. 
    /// </summary>
    /// <param name="selector"></param>
    /// <returns>automation element if successfull</returns>
    private AutomationElement FindByValue(string selector)
    {

        int firstIndex = selector.IndexOf(":")+1;
        string  controlValue = selector.Substring(firstIndex, selector.Length - firstIndex);

        // Use ControlViewCondition to retrieve all control elements.
        AutomationElementCollection elementCollectionControl = activeWindow.FindAll(TreeScope.Subtree, Automation.ControlViewCondition);
        foreach (AutomationElement autoElement in elementCollectionControl)
        {
            if (getElementText(autoElement) == controlValue)
            {
                return autoElement;
            }
        }
        throw new ElementNotAvailableException("Could not find an element with value: " + controlValue);
    }

    private string getElementText(AutomationElement element)
    {
        object patternObj;
        if (element.TryGetCurrentPattern(ValuePattern.Pattern, out patternObj))
        {
            var valuePattern = (ValuePattern)patternObj;
            return valuePattern.Current.Value;
        }
        else if (element.TryGetCurrentPattern(TextPattern.Pattern, out patternObj))
        {
            var textPattern = (TextPattern)patternObj;
            return textPattern.DocumentRange.GetText(-1).TrimEnd('\r'); // often there is an extra '\r' hanging off the end.
        }

        return null;
    }

    private Dictionary<AutomationProperty, string> ParseSelector(string selector)
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
    ///--------------------------------------------------
    [DllExport("Click", CallingConvention = CallingConvention.Cdecl)]
    public void Click(string selector, int child = 0)
    {
        AutomationElement control = search(selector, child);

        var isInvokable = (bool)control.GetCurrentPropertyValue(IsInvokePatternAvailableProperty);
        if (isInvokable)
        {
            var invokePattern = control.GetCurrentPattern(InvokePattern.Pattern) as InvokePattern;
            invokePattern.Invoke();
        }
        else
        {
            System.Drawing.Point p = control.GetClickablePoint(); //TODO add exception handling here.
            System.Windows.Forms.Cursor.Position = new System.Drawing.Point((int)p.X, (int)p.Y);
            Mouse.Click();
        }
    }

    ///--------------------------------------------------------------------
    /// <summary>
    /// Inserts a string into each text control of interest.
    /// </summary>
    /// <param name="value">String to be inserted</param>
    /// <param name="selector">selector to find the text control</param>
    /// <param name="child">which child to choose if multiple controls are chosen</param>
    ///--------------------------------------------------------------------
    [DllExport("Write", CallingConvention = CallingConvention.Cdecl)]
    public void Write(string value, string selector, int child = 0)
    {
        AutomationElement element = search(selector, child);  //finds the element to write to

        try
        {
            // Validate arguments / initial setup
            if (value == null)
                throw new ArgumentNullException(
                    "String parameter must not be null.");

            if (element == null)
                throw new ArgumentNullException(
                    "AutomationElement parameter must not be null");


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
                Console.WriteLine("The control with an AutomationID of ");
                Console.Write(element.Current.AutomationId.ToString());
                Console.Write(" does not support ValuePattern.");
                Console.Write(" Using keyboard input.\n");

                // Set focus for input functionality and begin.
                element.SetFocus();

                // Pause before sending keyboard input.
                Thread.Sleep(100);

                // Delete existing content in the control and insert new content.
                SendKeys.SendWait("^{HOME}");   // Move to start of control
                SendKeys.SendWait("^+{END}");   // Select everything
                SendKeys.SendWait("{DEL}");     // Delete selection
                SendKeys.SendWait(value);
            }
            // Control supports the ValuePattern pattern so we can 
            // use the SetValue method to insert content.
            else
            {
                Console.WriteLine("The control with an AutomationID of ");
                Console.Write(element.Current.AutomationId.ToString());
                Console.Write((" supports ValuePattern."));
                Console.Write(" Using ValuePattern.SetValue().\n");

                // Set focus for input functionality and begin.
                element.SetFocus();

                ((ValuePattern)valuePattern).SetValue(value);
            }
        }
        catch (ArgumentNullException exc)
        {
            Console.WriteLine(exc.Message);
        }
        catch (InvalidOperationException exc)
        {
            Console.WriteLine(exc.Message);
        }
    }
}