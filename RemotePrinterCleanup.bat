@echo off

echo cleaning data
forfiles /p %~dp0%data /s /m *.* /D -1 /C "cmd /c del @PATH"

echo cleaning log
forfiles /p %~dp0%log /s /m *.* /D -7 /C "cmd /c del @PATH"

echo reboot
shutdown /r /t 0
