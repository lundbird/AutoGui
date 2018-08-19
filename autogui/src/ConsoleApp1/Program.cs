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
        Open("calc.exe");
        //setWindow("calc", true);
        Click("One");
        Close();
        Open("notepad");
        Write("alex lundberg", "Text Editor");
        Close();
        }

    } 

    

