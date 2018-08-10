using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using GUILibrary;

namespace GUILibrary
{
    public class Class1
    {
        static void Main()
        {
            GUILibrary t = new GUILibrary();
            t.setWindow("Calculator");
            t.Click("Eight");
            t.Click("Seven");
            t.Click("Four");
        }

    }
}
