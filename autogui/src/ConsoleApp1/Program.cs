using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using static GUILibrary.GUILibraryClass;

public class Class1
{
    static void Main()
    {
        Open("notepad",true);

        Write("My name is Alex Lundberg", "Text Editor");

        Close();

        Open("calc");
        setWindow("Calculator - Calculator");

        Click("One");

        Click("Two");

        Close();

    }
}

    

