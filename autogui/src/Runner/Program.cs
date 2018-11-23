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
        Console.Write(GetActiveWindow());
        GUILibrary.GUILibraryClass.Open("notepad");
        Console.Write(GUILibrary.GUILibraryClass.GetProperty("Edit","Name"));
        Console.Write(GUILibrary.GUILibraryClass.GetProperty("File", "Id"));
        Console.Write(GUILibrary.GUILibraryClass.GetProperty("Format", "class"));
        Console.Write(GUILibrary.GUILibraryClass.Exists("Format"));
        Console.Write(GUILibrary.GUILibraryClass.Exists("BadName"));

    }
}

    

