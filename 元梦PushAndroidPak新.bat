@echo off
rem ����1��apk·��
setlocal enabledelayedexpansion
set CONSOLETOOLS=C:\goldapps\ConsoleTools.exe
set ZIPTOOLS=D:\Tools\Compress\Compressor\7-Zip\7z.exe

%CONSOLETOOLS% IsPathHasUnicodeChar "%~1"
if %ERRORLEVEL%==1 echo ·���в��ܰ�������! & pause & exit

set UNZIP_DIR=%~dp1%~n1\
set SRC_DIR=%UNZIP_DIR%LetsGo\Content\Paks\
if not exist "%SRC_DIR%" (
	%ZIPTOOLS% x -y "%~1" -o"%UNZIP_DIR%" -bso0
	%ZIPTOOLS% x -y %UNZIP_DIR%assets\main.obb.png -o"%UNZIP_DIR%" -bso0
)

%CONSOLETOOLS% GetADBDeviceID	
for /f %%i in (c:\templog\envvar.txt)  Do set %%i

set DEST_DIR=/storage/emulated/0/Android/data/com.tencent.letsgo/files/UE4Game/LetsGo/LetsGo/Content/Paks

if not exist "%SRC_DIR%" echo δ�ܳɹ���ѹ%UNZIP_DIR%assets\main.obb.png, �޷��ҵ�%UNZIP_DIR%LetsGo\Content\Paks\ & pause & exit
for /r "%SRC_DIR%" %%I in (res_base-Android_ASTCClient.pak) do echo �뱣֤���ش���(������Starp/LetsGoCommon/Engine�ֿ�)Ҳ����%%~tI���ʱ���, ��������Global Shader�Ҳ����ȱ���

adb -s !ADBDEVICEID! shell "mkdir -p %DEST_DIR%"
for /r "%SRC_DIR%" %%I in (*) do adb -s !ADBDEVICEID! push "%%I" "%DEST_DIR%"
rem rd %UNZIP_DIR% /s /q
echo Done! & pause