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

        Open("notepad");
        Write("alex lundberg", "Text Editor");
        Console.Write(Read("Text Editor"));
        Append(" is my name ", "Text Editor");
        //Console.Write(Read("Text Editor"));

        Open("calc");
        Click("One");
        Close("Untitled - Notepad");
        Close();
        
        Open("cmd");
        SendKey("cmd input");
        Close();
        }

    } 

    

