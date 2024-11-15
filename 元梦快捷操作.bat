@echo off
@echo ��ѡ��:
@echo lua:			Push LUA�ű��Ե���Ԫ���ֻ���, ��Ҫ�ȸ�����Ҫ���͵��ļ��б�������(���ļ���)
@echo lua3:			�޸Ĳ�Push�����̶�LUA�ű����ֻ������б���Cook�İ�
@echo cmdline:		ѡ��Push UE4CommandLine����׿�ֻ�, Insight��renderdoc����Ҫ
@echo shipping:		�޸ı��ش����Ա����Shipping����Դ
@echo renderdoc:		�޸ı��ش����Ա㰲׿���ץ֡, ����com.tencent.letsgo/com.epicgames.ue4.GameActivityExt
@echo console:		���Ϳ���̨�����׿�ֻ�, �ֺŷָ�
@echo runui:			ѡ��Trace��CommandLine��ִ��UnrealInsight
@echo ios:			�޸�IOS��DefaultEngine, ��Ҫ��ini����%~dp0��, ������������Generate����, ֱ�ӱ��뼴��
@echo initandroid:		��Ӱ�׿�������Ļ�������
@echo dumplog:		dump��׿log
@echo editor:			�����༭���͹���, ��Ҫ�������ļ����ϵ�bat��
@echo runcook:		Push��׿����cook����Դ�������̶�LUA�ű����ֻ�, ��������Ϸ, ��Ҫ�������ļ����ϵ�bat��
@echo initproj:		Ԫ���¹��̳�ʼ��, ��Ҫ�������ļ����ϵ�bat��
@echo checklink:		��鹤���Ƿ��Ѿ�����������������bat(�����淨����), ��Ҫ�������ļ����ϵ�bat��
@echo relink:			ǿ������������������bat(�����淨����), ��Ҫ�������ļ����ϵ�bat��
@echo cleanproj:		�������ͷſռ�, ��Ҫ�������ļ����ϵ�bat��
@echo xlspath:		�����Ŀ¼, ��Ҫ�������ļ����ϵ�bat��
@echo commandlet:		����commandlet, ��Ҫ�������ļ����ϵ�bat��
@echo rockhlod:		��Ҫ�������ļ����ϵ�bat��
set /p choice=������:


setlocal enabledelayedexpansion
set PackageName=com.tencent.letsgo
set ProjectName=LetsGo
set EXEC=C:\goldapps\DLLFunc.exe goldfx.dll
set CONSOLETOOLS=C:\goldapps\ConsoleTools.exe


if "%choice%"=="lua"		call %EXEC% UEMobilePushStarPLUAScriptsInClipboard %PackageName% & pause & exit
if "%choice%"=="lua3"		call %EXEC% UEMobilePushStarPLUAScriptsForDebug 1 & pause & exit
if "%choice%"=="cmdline"	call %EXEC% UEMobilePushCommandLine 0 %PackageName% %ProjectName% & pause & exit
if "%choice%"=="console"	call %EXEC% UESendConsoleString 0 & pause & exit  rem r.MeshDrawCommands.UseCachedCommands 0
if "%choice%"=="runui"		call %EXEC% UEMobilePushCommandLine 0 %PackageName% %ProjectName% & call %EXEC% UEMobileExecUnrealInsight & pause & exit
if "%choice%"=="ios"		call %EXEC% UEModifyDefaultEngineIOSRuntime %~dp0DefaultEngine.ini & pause & exit
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
if "%choice%"=="dumplog"	(
	rd "%TEMP%\Saved\" /s /q
	%CONSOLETOOLS% GetADBDeviceID
	for /f %%i in (c:\templog\envvar.txt)  Do set %%i
	adb -s !ADBDEVICEID! pull "/storage/emulated/0/Android/data/%PackageName%/files/UE4Game/LetsGo/LetsGo/Saved/" "%TEMP%\Saved"
	if exist "%TEMP%\Saved\Logs\" explorer "%TEMP%\Saved\Logs\"
	pause & exit
)

rem ���¶�����Ҫ�ṩ����·����
set RECORDFILE=%temp%\starpengine.txt
set PROJECTDIR=%1
if not exist "%1" (
	if exist "%RECORDFILE%" (
		for /f %%i in (%RECORDFILE%)  Do set PROJECTDIR=%%i
	)
)
if not exist "%PROJECTDIR%" (
	echo ���뽫��Ŀ�ļ����ϵ�bat�ϣ�
	pause && exit
)
echo %PROJECTDIR% >"%RECORDFILE%"
call %CONSOLETOOLS% echocolor ff0000ff "��ǰѡ�����Ŀ�ļ���Ϊ%PROJECTDIR%"

if "%choice%"=="shipping"	call %EXEC% UEMobileModifyCodeForShippingPak "%PROJECTDIR%" & echo �޸����, ��Ҫ���±��빤�� & pause & exit
if "%choice%"=="renderdoc"	call %EXEC% UEMobileModifyCodeForRenderDoc "%PROJECTDIR%" & echo �޸����, ��Ҫ���±��빤�� & pause & exit
if "%choice%"=="xlspath"	explorer "%PROJECTDIR%\letsgo_common\excel\xls\SPGame\" && pause & exit
if "%choice%"=="runcook"	(
	set SRC_DIR=%PROJECTDIR%\output\Patch\1.0.8.1\Android\1.0.8.1\
	set DEST_DIR=/storage/emulated/0/Android/data/com.tencent.letsgo/files/UE4Game/LetsGo/LetsGo/Content/Paks
	%CONSOLETOOLS% GetADBDeviceID
	for /f %%i in (c:\templog\envvar.txt)  Do set %%i
	echo ѡ���ֻ� !ADBDEVICEID!
	adb -s !ADBDEVICEID! shell "mkdir -p !DEST_DIR!"
	adb -s !ADBDEVICEID! push ""!SRC_DIR!Base\res_base-Android_ASTCClient.pak"" "!DEST_DIR!"
	for %%I in ("!SRC_DIR!\Chunk\*") do adb -s !ADBDEVICEID! push "%%I" "!DEST_DIR!"
	echo �������, ׼������ && pause
	call %EXEC% UEMobilePushStarPLUAScriptsForDebug "%PROJECTDIR%\LetsGo\Content\"
	adb -s !ADBDEVICEID! shell am start -n %PackageName%/com.epicgames.ue4.GameActivityExt
)
if "%choice%"=="editor"	(
	cd /d %PROJECTDIR%\ue4_tracking_rdcsp\Engine\Binaries\Win64
	start "" UE4Editor "%PROJECTDIR%\LetsGo\LetsGo.uproject" -skipcompile
)
if "%choice%"=="initproj"	(
	cd /d %PROJECTDIR%\ue4_tracking_rdcsp\
	call setup.bat --threads=16 --cache=E:\ue4_caches
	if %PROCESSOR_ARCHITECTURE%=="x86" (
		echo �����64λ��Դ��������ִ��, ����������û�����ѭ��
		pause & exit
	)
	cd ..\LetsGo\
	call MakeLinkForExportDir.bat
	cd ..\LetsGo\Tools\FeatureTool\
	call MakeSubDirSymbolicLinks.bat
	pause
)
if "%choice%"=="checklink"	(
	%CONSOLETOOLS% IsPathLink "%PROJECTDIR%\LetsGo\Content\Feature\StarP\Script\Export\pbin\"
	if not !ERRORLEVEL! == 1 (
		rd "%PROJECTDIR%\LetsGo\Content\Feature\StarP\Script\Export\pbin\"
		echo δ����淨���룬��ִ��bat���ٸ��²ֿ�
		explorer /select, "%PROJECTDIR%\LetsGo\Tools\FeatureTool\MakeSubDirSymbolicLinks.bat" & pause
	)
	%CONSOLETOOLS% IsPathLink "%PROJECTDIR%\LetsGo\Content\LetsGo\Script\Export\"
	if not !ERRORLEVEL! == 1 (
		rd "%PROJECTDIR%\LetsGo\Content\LetsGo\Script\Export\"
		echo δִ��MakeLinkForExportDir.bat����ִ��bat���ٸ��²ֿ�
		explorer /select, "%PROJECTDIR%\LetsGo\MakeLinkForExportDir.bat" & pause
	)
	echo ������淨�����ִ�й�MakeLinkForExportDir.bat & pause
	exit
)
if "%choice%"=="relink" (
	rd "%PROJECTDIR%\LetsGo\Content\Feature\StarP\Script\Export\pbin\"
	rd "%PROJECTDIR%\LetsGo\Content\LetsGo\Script\Export\"
	explorer /select, "%PROJECTDIR%\LetsGo\Tools\FeatureTool\MakeSubDirSymbolicLinks.bat"
	explorer /select, "%PROJECTDIR%\LetsGo\MakeLinkForExportDir.bat"
	echo ���ڵ������ļ�����ִ��bat���ٸ��²ֿ� & pause
)
if "%choice%"=="cleanproj" (
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
if "%choice%"=="commandlet" (
	set /p COMMANDLET=����������: 
	%PROJECTDIR%\ue4_tracking_rdcsp\Engine\Binaries\Win64\UE4Editor.exe %PROJECTDIR%\LetsGo\LetsGo.uproject -skipcompile %COMMANDLET%
)
set CMDLETEXEC=%PROJECTDIR%\ue4_tracking_rdcsp\Engine\Binaries\Win64\UE4Editor.exe %PROJECTDIR%\LetsGo\LetsGo.uproject -skipcompile
set ROCKDIR=%PROJECTDIR%\LetsGo\Content\Feature\StarP\Scenes\StarP_Runtime\Rock\
if "%choice%"=="rockhlod" (
	echo ��ɾ���������ļ��� & explorer "%ROCKDIR%" & pause
	echo ִ�к���Commandlet...
	%CMDLETEXEC% -run=HlodCommandlet CleanHlodCommon %PROJECTDIR%\LetsGo\Content\Feature\StarP\Scenes\StarP_Runtime Normal -graphicsadapter=0 -RunningUnattendedScript -Unattended -AllowCommandletRendering
	%CMDLETEXEC% -run=ExportStreamingLevelsCommandlet CutWorld /Game/Feature/StarP/Scenes/StarP_Runtime /Game/Feature/StarP/Scenes/StarP_World/StarP -graphicsadapter=0 -RunningUnattendedScript -Unattended -AllowCommandletRendering
	%CMDLETEXEC% -run=HlodCommandlet BuildLevelLODs /Game/Feature/StarP/Scenes/StarP_Runtime/StarP_Optimize StarP -graphicsadapter=0 -RunningUnattendedScript -Unattended -AllowCommandletRendering
	%CMDLETEXEC% -run=HlodCommandlet BuildRockHlod /Game/Feature/StarP/Scenes/StarP_Runtime/StarP_Optimize StarP -graphicsadapter=0 -RunningUnattendedScript -Unattended -AllowCommandletRendering
	%CMDLETEXEC% -run=HlodCommandlet BuildRockFarProxy /Game/Feature/StarP/Scenes/StarP_Runtime/StarP_Optimize -graphicsadapter=0 -RunningUnattendedScript -Unattended -AllowCommandletRendering
)