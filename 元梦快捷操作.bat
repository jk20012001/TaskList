@echo off
@echo ��ѡ��:
@echo lua:			Push LUA�ű��Ե���Ԫ���ֻ���, ��Ҫ�ȸ�����Ҫ���͵��ļ��б�������
@echo lua3:			�޸Ĳ�Push�����̶�LUA�ű����ֻ������б���Cook�İ�
@echo cmdline:		ѡ��Push UE4CommandLine��Ԫ��
@echo ui:			ִ��UnrealInsight
@echo ios:			�޸�IOS��DefaultEngine, ��Ҫ��ini����%~dp0��
@echo initproj:		Ԫ���¹��̳�ʼ��, ��Ҫ�������ļ����ϵ�bat��
@echo cleanproj:	�������ͷſռ�, ��Ҫ�������ļ����ϵ�bat��
@echo initandroid:	��Ӱ�׿�������Ļ�������
set /p choice=������:


setlocal enabledelayedexpansion
set PackageName=com.tencent.letsgo
set ProjectName=LetsGo
set EXEC=C:\goldapps\DLLFunc.exe goldfx.dll

if "%choice%"=="lua"    	call %EXEC% UEMobilePushStarPLUAScriptsInClipboard %PackageName%
if "%choice%"=="lua3"    	call %EXEC% UEMobilePushStarPLUAScriptsForDebug
if "%choice%"=="cmdline"   call %EXEC% UEMobilePushCommandLine 0 %PackageName% %ProjectName%
if "%choice%"=="ui"		call %EXEC% UEMobileExecUnrealInsight
if "%choice%"=="ios"		call %EXEC% UEModifyDefaultEngineIOSRuntime %~dp0DefaultEngine.ini & pause

if "%choice%"=="initproj"	(
	cd /d %1\ue4_tracking_rdcsp\
	setup.bat --threads=16 --cache=E:\ue4_caches
	cd ..\LetsGo\Tools\FeatureTool\
	MakeSubDirSymbolicLinks.bat
	pause
)
if "%choice%"=="cleanproj"	(
	cd /d %1\ue4_tracking_rdcsp\Engine
	if exist Intermediate rd /s /q Intermediate
	cd ..\..\LetsGo
	if exist Intermediate rd /s /q Intermediate
	D:\Tools\Tools\File\Everything\Everything_x64.exe -filename %1\*.pdb
	pause
)
if "%choice%"=="initandroid"	(
	%EXEC% toolSetUserEnvironmentValue AGDE_JAVA_HOME "C:\Program Files\Java\jdk-20\"
	%EXEC% toolSetUserEnvironmentValue ANDROID_HOME C:\Users\eugenejin\AppData\Local\Android\Sdk
	%EXEC% toolSetUserEnvironmentValue ANDROID_SDK_ROOT C:\Users\eugenejin\AppData\Local\Android\Sdk
	%EXEC% toolSetUserEnvironmentValue JAVA_HOME "D:\Program Files\TencentKona-11.0.14.b1"
	%EXEC% toolSetUserEnvironmentValue NDK_HOME C:\Users\eugenejin\AppData\Local\Android\Sdk\ndk\21.4.7075529
	%EXEC% toolSetUserEnvironmentValue NDK_ROOT C:\Users\eugenejin\AppData\Local\Android\Sdk\ndk\21.4.7075529
	%EXEC% toolSetUserEnvironmentValue UGIT_HOME C:\Users\eugenejin\AppData\Local\UGit\app-5.20.1
	pause
)