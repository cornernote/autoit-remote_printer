#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <FileConstants.au3>

; html file that will be run
Global $htmlFile = @ScriptDir & '\RemotePrinterSetup.html'

; remove existing file
If FileExists($htmlFile) Then
   FileDelete($htmlFile)
EndIf

; write the file
_Write('<html><body>')
_Write('<form action="' & _GetServer() & '/setup" method="post">')
_Write('<textarea name="config" style="display:none;">')
_Write('printpdf=' & '"' & _GetInstalledPath("adobe reader") & 'AcroRd32.exe' & '"')
_Write('printimage=' & '"' & _GetInstalledPath("irfanview") & 'i_view32.exe' & '"')
_Write('printlabel=' & '"' & _GetInstalledPath("DYMO Label v.8 SDK") & '\DLS SDK\Samples\High Level COM\Visual C++ (CommandLine)\PrintLabel.exe' & '"')
_Write('printhtml=' & '"' & _GetInstalledPath("printhtml") & 'printhtml.exe' & '"')
_Write('printers=' & '"' & _GetAllPrinters() & '"')
_Write('</textarea>')
_Write('<textarea name="ini" style="display:none;">' & _GetIniFile() & '</textarea>')
_Write('</form>')
_Write('<script>window.onload = function(){ document.forms[0].submit(); }</script>')
_Write('</body></html>')

; run the file
ShellExecute('file://' & $htmlFile)

; get all printers
Func _GetAllPrinters()
  Local $PrtList
  $oWSN	= ObjCreate("WScript.Network")
  $oPrt	= $oWSN.EnumPrinterConnections
  For $i = 0 To $oPrt.Count-1 Step 2
	  $PrtList = $PrtList & $oPrt($i+1) & ','
  Next
  return StringTrimRight($PrtList,1)
EndFunc

; get installed path of program
Func _GetInstalledPath($sProgamName, $fExtendedSearchFlag = True, $fSlidingSearch = True)
   Local $sInstalledPath = _GetInstalledPath_3264($sProgamName, $fExtendedSearchFlag, $fSlidingSearch) ; try 32bit
   If $sInstalledPath Then
	  Return $sInstalledPath
   EndIf
   Return _GetInstalledPath_3264($sProgamName, $fExtendedSearchFlag, $fSlidingSearch, "HKEY_LOCAL_MACHINE64\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\") ; try 64bit
EndFunc

; get installed path 32 or 64 bit
Func _GetInstalledPath_3264($sProgamName, $fExtendedSearchFlag = True, $fSlidingSearch = True, $sBasePath = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\")
   Local $sCurrentKey ; Holds current key during search
   Local $iCurrentKeyIndex ; Index to current key
   Local $sInstalledPath = RegRead($sBasePath & $sProgamName, "InstallLocation")
   If @error Then
	  If @error = -1 Then
		 ;Unable To open InstallLocation so unable to find path
		 Return SetError(2, 0, "") ; Path Not found
	  EndIf
	  ;Key not found
	  If $fExtendedSearchFlag Then
		 $iCurrentKeyIndex = 1
		 While 1
			$sCurrentKey = RegEnumKey($sBasePath, $iCurrentKeyIndex)
			If @error Then
			   ;No keys left
			   Return SetError(1, 0, "") ; Path Not found
			EndIf
			If ($fSlidingSearch And StringInStr(RegRead($sBasePath & $sCurrentKey, "DisplayName"), $sProgamName)) Or (RegRead($sBasePath & $sCurrentKey, "DisplayName") = $sProgamName) Then
			   ;Program name found in DisplayName
			   $sInstalledPath = RegRead($sBasePath & $sCurrentKey, "InstallLocation")
			   If @error Then
				  ;Unable To open InstallLocation so unable to find path
				  Return SetError(2, 0, "") ; Path Not found
			   EndIf
			   ExitLoop
			EndIf
			$iCurrentKeyIndex += 1
		 WEnd
	  Else
		 Return SetError(1, 0, "") ; Path Not found
	  EndIf
   EndIf
   Return $sInstalledPath
EndFunc

; get ini file contents
Func _GetIniFile()
    Local $hFileOpen = FileOpen(@ScriptDir&'\RemotePrinter.ini', $FO_READ)
    If $hFileOpen = -1 Then
        Return ''
    EndIf
    Local $sFileRead = FileRead($hFileOpen)
    FileClose($hFileOpen)
    Return $sFileRead
EndFunc

; get server url
Func _GetServer()
    Local $aServers = StringSplit(_Setting('RemotePrinter', 'servers'), ',', 2)
    Local $sServer = $aServers[0]
    $sServer = StringReplace($sServer, "nocdn.", "")
    $sServer = StringReplace($sServer, "http://", "https://")
    return $sServer
EndFunc

; write to the file
Func _Write($message)
   FileWriteLine($htmlFile, $message)
EndFunc

; get a setting
Func _Setting($section, $key)
   return IniRead(@ScriptDir&'\RemotePrinter.ini', $section, $key, '')
EndFunc
