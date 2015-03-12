@echo off
rem setlocal enabledelayedexpansion

:: Does powershell.exe exist within %PATH%?
for %%I in (powershell.exe) do if "%%~$PATH:I" neq "" (
    rem set chooser=powershell "Add-Type -AssemblyName System.windows.forms|Out-Null;$f=New-Object System.Windows.Forms.OpenFileDialog;$f.InitialDirectory='%cd%';$f.Filter='Text Files (*.txt)|*.txt|All Files (*.*)|*.*';$f.showHelp=$true;$f.ShowDialog()|Out-Null;$f.FileName"
	set chooser=powershell "Add-Type -AssemblyName System.windows.forms|Out-Null;$f=New-Object System.Windows.Forms.OpenFileDialog;$f.InitialDirectory='K:\clData\ERM_Financial_Tool';$f.Title='Please select your data file.';$f.Filter='Excel Files (*.xlsx)|*.xlsx|All Files (*.*)|*.*';$f.showHelp=$true;$f.ShowDialog()|Out-Null;$f.FileName"

) else (
rem :: If not, compose and link C# application to open file browser dialog
    set chooser=%temp%\chooser.exe
    >"%temp%\c.cs" echo using System;using System.Windows.Forms;
    >>"%temp%\c.cs" echo class dummy{
    >>"%temp%\c.cs" echo public static void Main^(^){
    >>"%temp%\c.cs" echo OpenFileDialog f=new OpenFileDialog^(^);
    >>"%temp%\c.cs" echo f.InitialDirectory=Environment.CurrentDirectory;
    rem >>"%temp%\c.cs" echo f.Filter="Text Files (*.txt)|*.txt|All Files (*.*)|*.*";
	>>"%temp%\c.cs" echo f.Filter="Excel Files (*.xlsx)|*.xlsx|All Files (*.*)|*.*";
    >>"%temp%\c.cs" echo f.ShowHelp=true;
    >>"%temp%\c.cs" echo f.ShowDialog^(^);
    >>"%temp%\c.cs" echo Console.Write^(f.FileName^);}}
    for /f "delims=" %%I in ('dir /b /s "%windir%\microsoft.net\*csc.exe"') do (
        if not exist "!chooser!" "%%I" /nologo /out:"!chooser!" "%temp%\c.cs" 2>NUL
    )
    del "%temp%\c.cs"
    if not exist "!chooser!" (
        echo Error: Please install .NET 2.0 or newer, or install PowerShell.
        goto :EOF
    )
)

:: capture choice to a variable
for /f "delims=" %%I in ('%chooser%') do set "filename=%%I"

rem echo You chose %filename%

:: Clean up the mess
REM del "%temp%\chooser.exe" 2>NUL
REM goto :EOF

rem XCOPY /y "K:\clData\ERM_Financial_Tool\2012 pledges and contributions.xlsx" .
XCOPY /y "%filename%" .

XCOPY /y code\ERM_Financial_Report_offline.Rnw .

echo set WshShell = WScript.CreateObject("WScript.Shell") > %tmp%\tmp.vbs
echo WScript.Quit (WshShell.Popup( "Your report is being produced. Please be patient" ,2 ,"ERM Financial Report", 0)) >> %tmp%\tmp.vbs
cscript /nologo %tmp%\tmp.vbs
REM if %errorlevel%==1 (
REM echo You Clicked OK
REM ) else (
REM echo The Message timed out.
REM )
del %tmp%\tmp.vbs

SET PATH=%PATH%;"LaTeX\miktex\bin";"R-Portable\App\R-Portable\bin"

rem Rscript -e "library(knitr); knit('ERM_Financial_Report_offline.Rnw')"
Rscript -e "if(!require(knitr)) {install.packages("knitr"); require(knitr)}; knit('ERM_Financial_Report_online.Rnw')"
pdflatex ERM_Financial_Report_offline.tex

:: fchooser.bat
:: launches a folder chooser and outputs choice to the console

@echo off
rem setlocal enabledelayedexpansion

:: Does powershell.exe exist within %PATH%?
for %%I in (powershell.exe) do if "%%~$PATH:I" neq "" (
    rem set chooser=powershell -sta "Add-Type -AssemblyName System.windows.forms|Out-Null;$f=New-Object System.Windows.Forms.FolderBrowserDialog;$f.SelectedPath='%cd%';$f.Description='Please choose a folder.';$f.ShowNewFolderButton=$true;$f.ShowDialog();$f.SelectedPath"
	set chooser=powershell -sta "Add-Type -AssemblyName System.windows.forms|Out-Null;$f=New-Object System.Windows.Forms.FolderBrowserDialog;$f.SelectedPath='K:\clData\ERM_Financial_Tool';$f.Description='Please choose where you would like to save the report.';$f.ShowNewFolderButton=$true;$f.ShowDialog();$f.SelectedPath"
) else (
rem :: If not, compose and link C# application to open folder browser dialog
    set chooser=%temp%\fchooser.exe
    if exist !chooser! del !chooser!
    >"%temp%\c.cs" echo using System;using System.Windows.Forms;
    >>"%temp%\c.cs" echo class dummy{[STAThread]
    >>"%temp%\c.cs" echo public static void Main^(^){
    >>"%temp%\c.cs" echo FolderBrowserDialog f=new FolderBrowserDialog^(^);
    >>"%temp%\c.cs" echo f.SelectedPath=System.Environment.CurrentDirectory;
    >>"%temp%\c.cs" echo f.Description="Please choose a folder.";
    >>"%temp%\c.cs" echo f.ShowNewFolderButton=true;
    >>"%temp%\c.cs" echo if^(f.ShowDialog^(^)==DialogResult.OK^){Console.Write^(f.SelectedPath^);}}}
    for /f "delims=" %%I in ('dir /b /s "%windir%\microsoft.net\*csc.exe"') do (
        if not exist "!chooser!" "%%I" /nologo /out:"!chooser!" "%temp%\c.cs" 2>NUL
    )
    del "%temp%\c.cs"
    if not exist "!chooser!" (
        echo Error: Please install .NET 2.0 or newer, or install PowerShell.
        goto :EOF
    )
)

:: capture choice to a variable
for /f "delims=" %%I in ('%chooser%') do set "folder=%%I"

rem echo You chose %folder%

rem XCOPY /y ERM_Financial_Report_offline.pdf K:\clData\ERM_Financial_Tool\
ren "ERM_Financial_Report_offline.pdf" "ERM_Financial_Report_%DATE:~6,4%%DATE:~3,2%%DATE:~0,2%.pdf"
XCOPY /y ERM_Financial_Report_%DATE:~6,4%%DATE:~3,2%%DATE:~0,2%.pdf "%folder%"

rem del ERM_Financial_Report.* "2012 pledges and contributions.xlsx" framed.sty figure\fig_pop-1.pdf
del ERM_Financial_Report* framed.sty figure\fig_pop-1.pdf

rem explorer K:\clData\ERM_Financial_Tool 
rem explorer K:\clData\ERM_Financial_Tool\ERM_Financial_Report.pdf
explorer "%folder%"
explorer "%folder%\ERM_Financial_Report_%DATE:~6,4%%DATE:~3,2%%DATE:~0,2%.pdf"