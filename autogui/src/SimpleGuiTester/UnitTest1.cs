using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Windows.Automation;
using static System.Windows.Automation.AutomationElement;
using static GUILibrary.GUILibraryClass;
using System.Collections.Generic;

namespace SimpleGuiTester
{
    [TestClass]
    /// <summary>
    /// Unit tests the methods of GUILibrary.
    /// </summary>
    public class UnitTest1
    {

        [TestMethod]
        public void TestValidateInput()
        {
            Assert.ThrowsException<ArgumentException>(()=>ValidateInput(null,"",1,1));
            Assert.ThrowsException<ArgumentException>(() => ValidateInput("", null, 1, 1));
            Assert.ThrowsException<ArgumentException>(() => ValidateInput("", "", -1, 1));
            Assert.ThrowsException<ArgumentException>(() => ValidateInput("", "", 1, -1));
            Assert.ThrowsException<ArgumentException>(() => ValidateInput("", "", 101, 1));
            Assert.ThrowsException<ArgumentException>(() => ValidateInput("", "", 1, 100));
            Assert.ThrowsException<ArgumentException>(() => ValidateInput(null, null, -1, 100));
        }

        [TestMethod]
        public void TestParseSelector()
        {
            Dictionary<AutomationProperty, string> testDict = new Dictionary<AutomationProperty, string>();

            testDict.Add(NameProperty, "Calculator");
            CollectionAssert.AreEqual(testDict, ParseSelector("Calculator"));

            testDict.Clear();
            testDict.Add(AutomationIdProperty, "idvalue");
            CollectionAssert.AreEqual(testDict, ParseSelector("id:idvalue"));

            testDict.Clear();
            testDict.Add(ClassNameProperty, "classvalue");
            CollectionAssert.AreEqual(testDict, ParseSelector("class:classvalue"));

            testDict.Clear();
            testDict.Add(NameProperty, "namevalue");
            testDict.Add(AutomationIdProperty, "idvalue");
            testDict.Add(ClassNameProperty, "classvalue");
            CollectionAssert.AreEqual(testDict, ParseSelector("name:namevalue,id:idvalue,class:classvalue"));

        }
    }
}
