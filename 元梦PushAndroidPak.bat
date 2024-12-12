rem 参数1给1的话就是push本地cook的所有pak
@echo off
setlocal enabledelayedexpansion
set CONSOLETOOLS=C:\goldapps\ConsoleTools.exe

%CONSOLETOOLS% IsPathHasUnicodeChar "%1"
if %ERRORLEVEL%==1 echo 路径中不能包含中文! & pause & exit

%CONSOLETOOLS% GetADBDeviceID	
for /f %%i in (c:\templog\envvar.txt)  Do set %%i

set FILE_TO_PUSH="%1\Paks\res_base-Android_ASTCClient.pak"

set DEST_DIR=/storage/emulated/0/Android/data/com.tencent.letsgo/files/UE4Game/LetsGo/LetsGo/Content/Paks

if not exist "%FILE_TO_PUSH%" (
    echo Error: File not found - %FILE_TO_PUSH%
	pause
    exit /b 1
)

adb -s !ADBDEVICEID! shell "mkdir -p %DEST_DIR%"
if %1==1 (
	for %%I in ("%1\Paks\*") do adb -s !ADBDEVICEID! push "%%I" "%DEST_DIR%"
)else (
	adb -s !ADBDEVICEID! push "%FILE_TO_PUSH%" "%DEST_DIR%"
)
echo Done!

pause