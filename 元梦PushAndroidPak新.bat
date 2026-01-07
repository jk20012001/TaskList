@echo off
rem 参数1是apk路径
setlocal enabledelayedexpansion
set CONSOLETOOLS=C:\goldapps\ConsoleTools.exe
set ZIPTOOLS=D:\Tools\Compress\Compressor\7-Zip\7z.exe

%CONSOLETOOLS% IsPathHasUnicodeChar "%~1"
rem 路径中绝对不能包含括号等, 会导致zip解压失败
rem if not %ERRORLEVEL%==0 echo 路径中不能包含中文! & pause & exit

set UNZIP_DIR=%~dp1%~n1\
set SRC_DIR=%UNZIP_DIR%LetsGo\Content\Paks\
if not exist "%SRC_DIR%" (
	%ZIPTOOLS% x -y "%~1" -o"%UNZIP_DIR%" -bso0
	%ZIPTOOLS% x -y "%UNZIP_DIR%assets\main.obb.png" -o"%UNZIP_DIR%" -bso0
)

%CONSOLETOOLS% GetADBDeviceID	
for /f %%i in (c:\templog\envvar.txt)  Do set %%i
echo 即将复制到机器: %ADBDEVICEID%

set DEST_DIR=/storage/emulated/0/Android/data/com.tencent.letsgo/files/UE4Game/LetsGo/LetsGo/Content/Paks

if not exist "%SRC_DIR%" echo 未能成功解压%UNZIP_DIR%assets\main.obb.png, 无法找到%UNZIP_DIR%LetsGo\Content\Paks\ & pause & exit
for /r "%SRC_DIR%" %%I in (res_base-Android_ASTCClient.pak) do echo 请保证本地代码(尤其是Starp/LetsGoCommon/Engine仓库)也得是%%~tI这个时间的, 否则会出现Global Shader找不到等崩溃

adb -s !ADBDEVICEID! shell "mkdir -p %DEST_DIR%"
for /r "%SRC_DIR%" %%I in (*) do adb -s !ADBDEVICEID! push "%%I" "%DEST_DIR%"
rem rd %UNZIP_DIR% /s /q
echo Done! & pause