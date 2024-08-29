@echo off
@echo 请选择:
@echo lua:			Push LUA脚本以调试元梦手机包, 需要先复制需要推送的文件列表到剪贴板
@echo lua3:			修改并Push三个固定LUA脚本到手机以运行本地Cook的包
@echo cmdline:		选择并Push UE4CommandLine到元梦
@echo ui:			执行UnrealInsight
@echo ios:			修改IOS的DefaultEngine, 需要将ini拷到%~dp0下
@echo initproj:		元梦新工程初始化, 需要将工程文件夹拖到bat上
@echo cleanproj:	清理工程释放空间, 需要将工程文件夹拖到bat上
@echo initandroid:	添加安卓打包所需的环境变量
set /p choice=请输入:


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