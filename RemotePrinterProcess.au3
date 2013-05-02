#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <Date.au3>

; kill other instances
If WinExists('RemotePrinterProcess') Then
	WinKill('RemotePrinterProcess')
EndIf
AutoItWinSetTitle('RemotePrinterProcess')

; startup message
Debug('INIT')

; endless loop
While 1
   For $spool In Spools()
	  If UrlCount($spool) Then
		 For $url In UrlList($spool)
			ProcessUrl($spool, $url)
		 Next
	  EndIf
   Next
   CleanupWindows()
   Sleep(Setting('RemotePrinter', 'sleep')*1000)
WEnd

; download and print a url
Func ProcessUrl($spool, $url)
   Debug('ProcessUrl: ' & $spool & ' ' & $url)
   If $url Then
	  Local $parts = StringSplit($url, '/', 1)
	  Local $file = $parts[UBound($parts)-1]
	  UrlDownload($spool, $url, $file)
	  PrintFile($spool, $file)
	  InetRead(StringReplace($url, '/download/', '/delete/'), 1)
   EndIf
EndFunc

; print a file
Func PrintFile($spool, $file)
   Debug('PrintFile: '&$spool&' '&$file)
   Local $type = FileType($file)
   If Not $type Then
	  Debug('ERROR: unknown file type: '&$spool&' '&$file)
	  Return False
   EndIf
   Local $printer = Setting($spool, $type)
   If Not $printer Then
	  Debug('NOTICE: printer config missing: '&$spool&' '&$file)
	  ;Return False
   EndIf
   Switch $type
	  Case 'pdf'
		 PrintPdf($printer, $file)
	  Case 'label'
		 PrintLabel($printer, $file)
	  Case 'html'
		 PrintHtml($printer, $file)
	  Case 'image'
		 PrintImage($printer, $file)
   EndSwitch
   Return True
EndFunc

; get the file type
Func FileType($file)
   Debug('FileType: '&$file)
   If StringLower(StringRight($file,3)) = 'pdf' Then
	  Return 'pdf'
   ElseIf StringLower(StringRight($file,5)) = 'label' Then
	  Return 'label'
   ElseIf StringLower(StringRight($file,3)) = 'htm' Then
	  Return 'html'
   ElseIf StringLower(StringRight($file,4)) = 'html' Then
	  Return 'html'
   ElseIf StringLower(StringRight($file,3)) = 'bmp' Then
	  Return 'image'
   ElseIf StringLower(StringRight($file,3)) = 'gif' Then
	  Return 'image'
   ElseIf StringLower(StringRight($file,3)) = 'jpg' Then
	  Return 'image'
   ElseIf StringLower(StringRight($file,4)) = 'jpeg' Then
	  Return 'image'
   ElseIf StringLower(StringRight($file,3)) = 'png' Then
	  Return 'image'
   EndIf
EndFunc

; print pdf
Func PrintPdf($printer, $file)
   Local $script=Setting('RemotePrinter', 'adobereader')
   Local $params='/t "' & @ScriptDir & '\data\' & $file & '" "' & $printer & '"'
   Debug('PrintPdf: ' & $script & ' ' & $params)
   ShellExecute($script, $params, @SW_HIDE)
   WinWait($file)
EndFunc

; print label
Func PrintLabel($printer, $file)
   Local $script=Setting('RemotePrinter', 'printlabel')
   Local $params='/printer "' & $printer & '" "' & @ScriptDir & '\data\' & $file & '"'
   Debug('PrintLabel: ' & $script & ' ' & $params)
   ShellExecuteWait($script, $params, @SW_HIDE)
   ;ShellExecute($script, $params, @SW_HIDE)
EndFunc

; print html
Func PrintHtml($printer, $file)
   Local $script=Setting('RemotePrinter', 'printhtml')
   Local $params='printername "' & $printer & '" file="' & @ScriptDir & '\data\' & $file & '"'
   Debug('PrintHtml: ' & $script & ' ' & $params)
   ShellExecuteWait($script, $params, @SW_HIDE)
EndFunc

; print image
Func PrintImage($printer, $file)
   Local $script=Setting('RemotePrinter', 'irfanview')
   Local $params='"' & @ScriptDir & '\data\' & $file & '" /print="' & $printer & '"'
   Debug('PrintImage: ' & $script & ' ' & $params)
   ShellExecute($script, $params, @SW_HIDE)
EndFunc

; get the spools
Func Spools()
   Debug('Spools')
   Return StringSplit(Setting('RemotePrinter', 'spools'), ',', 2)
EndFunc

; count the urls that need to be downloaded
Func UrlCount($spool)
   Debug('UrlCount: '&$spool)
   Local $url = Setting('RemotePrinter', 'url') & '/printSpool/count/spool/' & $spool
   Return BinaryToString(InetRead($url, 1))
EndFunc

; get the urls that need to be downloaded
Func UrlList($spool)
   Debug('UrlList: '&$spool)
   Local $url = Setting('RemotePrinter', 'url') & '/printSpool/view/spool/' & $spool
   Return StringSplit(BinaryToString(InetRead($url, 1)), ' ', 2)
EndFunc

; downloads a file from a url
Func UrlDownload($spool, $url, $file)
   Debug('UrlDownload: '&$spool&' '&$url&' '&$file)
   If DirGetSize(@ScriptDir & '\data') = -1 Then
	  DirCreate(@ScriptDir & '\data')
   EndIf
   InetGet($url, @ScriptDir & '\data\' & $file)
EndFunc

; cleanup any windows that are left open
Func CleanupWindows()
   WinKill('Adobe Reader')
EndFunc
   
; get a setting
Func Setting($section, $key)
   return IniRead(@ScriptDir&'\RemotePrinter.ini', $section, $key, '')
EndFunc

; write to debug log
Func Debug($message)
   If Setting('RemotePrinter', 'debug')=="0" Then
	  Return
   EndIf
   ConsoleWrite($message & @CRLF)
   If DirGetSize(@ScriptDir & '\log') = -1 Then
	  DirCreate(@ScriptDir & '\log')
   EndIf
   FileWriteLine(@ScriptDir & '\log\' & @YEAR & '-' & @MON & '-' & @MDAY & '.txt', _NowCalc() & ' - ' & $message)
EndFunc
