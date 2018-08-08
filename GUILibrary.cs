using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using System.Windows.Input;
using System.Windows.Forms;
using System.Drawing;
using Keyboard = Microsoft.VisualStudio.TestTools.UITesting.Keyboard;
using System.Windows.Automation;


public class GUILibrary
{
	public GUILibrary(string window)
	{
        this.window = window;
	}

    public Action(string selector,string action,string window)
    {
        search(selector, window);

        Condition apptitle = new PropertyCondition(AutomationElement.NameProperty, "Untitled - Notepad");
        AutomationElement window = AutomationElement.RootElement.FindFirst(TreeScope.Children, apptitle);
        window.SetFocus();

        Condition menutitle = new PropertyCondition(AutomationElement.NameProperty, "Format");
        //new System.Windows.Automation.PropertyCondition(AutomationElement.ControlTypeProperty, "MenuItem"));

        AutomationElementCollection editbar = window.FindAll(TreeScope.Descendants, menutitle);
        //editbar.SetFocus();

        var isInvokable = (bool)editbar[0].GetCurrentPropertyValue(AutomationElement.IsInvokePatternAvailableProperty);
        if (isInvokable)
        {
            var invokePattern = editbar[0].GetCurrentPattern(InvokePattern.Pattern) as InvokePattern;
            invokePattern.Invoke();
        }
        else
        {
            System.Drawing.Point p = editbar[0].GetClickablePoint();
            System.Windows.Forms.Cursor.Position = new System.Drawing.Point((int)p.X, (int)p.Y);
            Mouse.Click();
        }
    }
}
