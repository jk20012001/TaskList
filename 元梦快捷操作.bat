@echo off
@echo ��ѡ��:
@echo lua:			Push LUA�ű��Ե���Ԫ���ֻ���, ��Ҫ�ȸ�����Ҫ���͵��ļ��б�������(���ļ���), ���Զ�ִ��lua3
@echo lua3:			�޸Ĳ�Push�����̶�LUA�ű����ֻ������б���Cook�İ�
@echo runcook:		Push��׿����cook����Դ�������̶�LUA�ű����ֻ�, ��������Ϸ
@echo cmdline:		ѡ��Push UE4CommandLine����׿�ֻ�, Insight��renderdoc����Ҫ
@echo renderdoc:		�޸ı��ش����Ա㰲׿���ץ֡, ����com.tencent.letsgo/com.epicgames.ue4.GameActivityExt
@echo ui:			ִ��UnrealInsight
@echo ios:			�޸�IOS��DefaultEngine, ��Ҫ��ini����%~dp0��
@echo editor:			�����༭���͹���, ��Ҫ�������ļ����ϵ�bat��
@echo initproj:		Ԫ���¹��̳�ʼ��, ��Ҫ�������ļ����ϵ�bat��
@echo cleanproj:		�������ͷſռ�, ��Ҫ�������ļ����ϵ�bat��
@echo initandroid:		��Ӱ�׿�������Ļ�������
@echo ugitpath:		��ugit�������·����������, ת��Ϊcopy.bat���ݴ��������
@echo xlspath:		�����Ŀ¼
set /p choice=������:


setlocal enabledelayedexpansion
set PackageName=com.tencent.letsgo
set ProjectName=LetsGo
set EXEC=C:\goldapps\DLLFunc.exe goldfx.dll


if "%choice%"=="lua"    	call %EXEC% UEMobilePushStarPLUAScriptsInClipboard %PackageName% & pause & exit
if "%choice%"=="lua3"    	call %EXEC% UEMobilePushStarPLUAScriptsForDebug & pause & exit
if "%choice%"=="cmdline"   call %EXEC% UEMobilePushCommandLine 0 %PackageName% %ProjectName% & pause & exit
if "%choice%"=="renderdoc" call %EXEC% UEMobileModifyCodeForRenderDoc & pause & exit
if "%choice%"=="ui"		call %EXEC% UEMobileExecUnrealInsight & pause & exit
if "%choice%"=="ios"		call %EXEC% UEModifyDefaultEngineIOSRuntime %~dp0DefaultEngine.ini & pause & exit
if "%choice%"=="ugitpath"	call %EXEC% StarPConvertUGitPathToBatContent pause & exit
if "%choice%"=="initandroid"	(
	%EXEC% toolSetUserEnvironmentValue AGDE_JAVA_HOME "C:\Program Files\Java\jdk-20\"
	%EXEC% toolSetUserEnvironmentValue ANDROID_HOME C:\Users\eugenejin\AppData\Local\Android\Sdk
	%EXEC% toolSetUserEnvironmentValue ANDROID_SDK_ROOT C:\Users\eugenejin\AppData\Local\Android\Sdk
	%EXEC% toolSetUserEnvironmentValue JAVA_HOME "D:\Program Files\TencentKona-11.0.14.b1"
	%EXEC% toolSetUserEnvironmentValue NDK_HOME C:\Users\eugenejin\AppData\Local\Android\Sdk\ndk\21.4.7075529
	%EXEC% toolSetUserEnvironmentValue NDK_ROOT C:\Users\eugenejin\AppData\Local\Android\Sdk\ndk\21.4.7075529
	%EXEC% toolSetUserEnvironmentValue UGIT_HOME C:\Users\eugenejin\AppData\Local\UGit\app-5.20.1
	pause & exit
)


rem ���¶�����Ҫ�ṩ����·����
set RECORDFILE=%temp%\starpengine.txt
set PROJECTDIR=%1
if not exist "%1" (
	if exist "%RECORDFILE%" (
		for /f %%i in (%RECORDFILE%)  Do echo set %%i
	)
)
if not exist "%PROJECTDIR%" (
	echo ���뽫��Ŀ�ļ����ϵ�bat�ϣ�
	pause && exit
)
echo %PROJECTDIR% >"%RECORDFILE%"
call c:\goldapps\consoletools echocolor 02 "��ǰѡ�����Ŀ�ļ���Ϊ%PROJECTDIR%"

if "%choice%"=="xlspath"	explorer "%PROJECTDIR%\letsgo_common\excel\xls\SPGame\" && pause & exit
if "%choice%"=="runcook"	(
	set SRC_DIR=%PROJECTDIR%\output\Patch\1.0.8.1\Android\1.0.8.1\
	set DEST_DIR=/storage/emulated/0/Android/data/com.tencent.letsgo/files/UE4Game/LetsGo/LetsGo/Content/Paks
	adb shell "mkdir -p %DEST_DIR%"
	adb push "%FILE_TO_PUSH%" "%DEST_DIR%"
	adb push "%SRC_DIR%\ShaderPak\p_shaders-Android_ASTCClient.pak" "%DEST_DIR%"
	for %%I in ("%SRC_DIR%\Chunk\*") do adb push "%%I" "%DEST_DIR%"
	echo �������, ׼������ && pause
	call %EXEC% UEMobilePushStarPLUAScriptsForDebug "%PROJECTDIR%\LetsGo\Content\"
	adb shell am start -n %PackageName%/com.epicgames.ue4.GameActivityExt
)
if "%choice%"=="editor"	(
	cd /d %PROJECTDIR%\ue4_tracking_rdcsp\Engine\Binaries\Win64
	start "" UE4Editor "%PROJECTDIR%\LetsGo\LetsGo.uproject" -skipcompile
)
if "%choice%"=="initproj"	(
	cd /d %PROJECTDIR%\ue4_tracking_rdcsp\
	setup.bat --threads=16 --cache=E:\ue4_caches
	cd ..\LetsGo\Tools\FeatureTool\
	MakeSubDirSymbolicLinks.bat
	pause
)
if "%choice%"=="cleanproj"	(
	cd /d %PROJECTDIR%\ue4_tracking_rdcsp\Engine
	if exist Intermediate rd /s /q Intermediate
	cd ..\..\LetsGo
	if exist Intermediate rd /s /q Intermediate
	del /s /q /f "%PROJECTDIR%\ue4_tracking_rdcsp\Engine\Binaries\*.pdb"
	del /s /q /f "%PROJECTDIR%\ue4_tracking_rdcsp\Engine\Plugins\*.pdb"
	del /s /q /f "%PROJECTDIR%\LetsGo\Binaries\*.pdb"
	del /s /q /f "%PROJECTDIR%\LetsGo\Plugins\*.pdb"
	rem D:\Tools\Tools\File\Everything\Everything_x64.exe -filename %PROJECTDIR%\*.pdb
	pause
)
