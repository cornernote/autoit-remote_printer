#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <Date.au3>

; kill other instances
Local $title = Setting('RemotePrinter', 'title')
If WinExists($title  & 'Monitor') Then
	WinKill($title  & 'Monitor')
EndIf
AutoItWinSetTitle($title  & 'Monitor')

; endless loop
While 1
   CheckRestart()
   Sleep(10000)
WEnd

; check if we should restart
Func CheckRestart()
   If LastRun() > 60 Then
	  Restart()
   ElseIf Not RemotePrinterExists() Then
	  Restart()
   EndIf
EndFunc

; read from debug log
Func LastRun()
   Local $line = FileReadLine(@ScriptDir & '\log\' & @YEAR & '-' & @MON & '-' & @MDAY & '.txt', -1)
   Local $message = StringSplit($line, " - ", 1)
   Return _DateDiff('s', $message[1], _NowCalc())
EndFunc

; restart print process
Func Restart()
   WinKill($title & 'Process')
   Run(@ScriptDir & '\RemotePrinterProcess.exe')
EndFunc

; check if print process is running
Func RemotePrinterExists()
   If WinExists($title & 'Process') Then
	  Return True
   EndIf
   Sleep(10000)
   If WinExists($title & 'Process') Then
	  Return True
   EndIf
   Return False
EndFunc

; get a setting
Func Setting($section, $key)
   return IniRead(@ScriptDir&'\RemotePrinter.ini', $section, $key, '')
EndFunc
