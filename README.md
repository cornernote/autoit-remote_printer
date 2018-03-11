# Remote Printer


## About

Remote Printer allows a Windows PC to poll and download assets from a web spool and then send them to a local or network printer.

This allows the web application to simply write files into a folder, which will then be printed.

The software was developed using [AutoIt](https://www.autoitscript.com/), which offers a free code editor and compiler.


## Installation

Copy the entire folder to a windows PC.

Install the following:

* [autoit-v3-setup.exe](https://www.autoitscript.com/files/autoit3/autoit-v3-setup.exe)
* [DYMO_Label_v.8_SDK_Installer.exe](http://download.dymo.com/dymo/Software/SDK/DYMO_Label_v.8_SDK_Installer.exe)
* [DLS8Setup.8.5.3.exe](http://download.dymo.com/dymo/Software/Win/DLS8Setup.8.7.exe)
* [Adobe Reader](http://get.adobe.com/reader/)
* [IrfanView](http://www.irfanview.com/)
* [PrintHTML](http://www.printhtml.com/)

Alter `RemotePrinter.ini` to suit.

Compile `RemotePrinter.au3` and `RemotePrinterProcess.au3` (right click > compile).

Add a shortcut to `RemotePrinter.exe` to the startup folder (run `shell:startup`).
 
