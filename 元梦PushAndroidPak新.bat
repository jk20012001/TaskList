rem 参数1是apk路径
@echo off
setlocal enabledelayedexpansion
set CONSOLETOOLS=C:\goldapps\ConsoleTools.exe
set ZIPTOOLS=D:\Tools\Compress\Compressor\7-Zip\7z.exe

%CONSOLETOOLS% IsPathHasUnicodeChar "%~1"
if %ERRORLEVEL%==1 echo 路径中不能包含中文! & pause & exit

set UNZIP_DIR=%~dp1%~n1\
%ZIPTOOLS% x -y "%~1" -o"%UNZIP_DIR%"
%ZIPTOOLS% x -y %UNZIP_DIR%assets\main.obb.png -o"%UNZIP_DIR%"

%CONSOLETOOLS% GetADBDeviceID	
for /f %%i in (c:\templog\envvar.txt)  Do set %%i

set SRC_DIR=%UNZIP_DIR%LetsGo\Content\Paks\
set DEST_DIR=/storage/emulated/0/Android/data/com.tencent.letsgo/files/UE4Game/LetsGo/LetsGo/Content/Paks

if not exist "%SRC_DIR%" echo 未能成功解压%UNZIP_DIR%assets\main.obb.png, 无法找到%UNZIP_DIR%LetsGo\Content\Paks\ & pause & exit

adb -s !ADBDEVICEID! shell "mkdir -p %DEST_DIR%"
adb -s !ADBDEVICEID! push "%FILE_TO_PUSH%" "%DEST_DIR%"
for /r "%SRC_DIR%" %%I in (*) do adb -s !ADBDEVICEID! push "%%I" "%DEST_DIR%"
rem rd %UNZIP_DIR% /s /q
echo Done! & pause